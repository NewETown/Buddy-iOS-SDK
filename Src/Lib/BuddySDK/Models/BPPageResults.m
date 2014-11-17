//
//  BPPageResults.m
//  BuddySDK
//
//  Created by Nick Ambrose on 7/17/14.
//
//

#import "BPPageResults.h"
#import "BPModelBase.h"

@implementation BPPageResults

-(NSArray*) convertPageResultsToType:(Class)clazz
{
    return [BPModelBase convertArrayOfDict:self.pageResults toType:clazz];
}
@end
