//
//  BPModelSearch.m
//  BuddySDK
//
//  Created by Nick Ambrose on 7/17/14.
//
//

#import "BPModelSearch.h"
#import "BPModelBase.h"

@implementation BPModelSearch

-(NSArray*) convertPageResultsToType:(Class)clazz
{
    return [BPModelBase convertArrayOfDict:self.pageResults toType:clazz];
}
@end
