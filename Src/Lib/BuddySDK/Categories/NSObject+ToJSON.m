//
//  NSObject+ToJSON.m
//  BuddySDK
//
//  Created by Erik Kerber on 2/6/14.
//
//

#import "NSObject+ToJSON.h"
#import "BPEnumMapping.h"
#import "NSDate+JSON.h"
#import <objc/runtime.h>

@implementation NSObject (ToJSON)

- (NSDictionary *)parametersFromProperties:(Protocol *)protocol
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    @autoreleasepool {
        unsigned int numberOfProtocols = 0;
        unsigned int numberOfProperties = 0;
        Protocol * __unsafe_unretained *protocolArray = protocol_copyProtocolList(protocol, &numberOfProtocols);
        objc_property_t *propertyArray = protocol_copyPropertyList(protocol, &numberOfProperties);
        for (NSUInteger i = 0; i < numberOfProperties; i++)
        {
            objc_property_t property = propertyArray[i];
            NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
            id val = [self valueForKey:name];
            
            if ([val respondsToSelector:@selector(stringValue)]) {
                val = [val stringValue];
            } else if([[val class] isSubclassOfClass:[NSDate class]]){
                val = [val serializeDateToJson];
            }
            
            if (val) {
                parameters[name] = val;
            }
        }

        // Recurse derived protocols.
        for (NSInteger i = 0; i < numberOfProtocols; i++) {
            [parameters addEntriesFromDictionary:[self parametersFromProperties:protocolArray[i]]];
        }
        
        free(propertyArray);
    }
    return parameters;
}

@end
