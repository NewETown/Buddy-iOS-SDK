//
//  JAGPropertyConverter+BPJSONConverter.m
//  BuddySDK
//
//  Created by Erik.Kerber on 3/4/14.
//
//

#import "JAGPropertyConverter+BPJSONConverter.h"
#import "BPSize.h"
#import "BPCoordinate.h"

@implementation JAGPropertyConverter (BPJSONConverter)

+(JAGPropertyConverter *)bp_converter
{
    static JAGPropertyConverter *c;
    if(!c)
    {
        c = [JAGPropertyConverter new];
        
        c.identifyDict = ^Class(NSDictionary *dict) {
            if ([dict valueForKey:@"lat"]) {
                return [BPCoordinate class];
            } else if ([dict valueForKey:@"h"]) {
                return [BPSize class];
            }
            return nil;
        };
    }
    return c;
}

@end
