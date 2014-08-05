//
//  BPModelBase.h
//  BuddySDK
//
//  Created by Nick Ambrose on 7/16/14.
//
//

#import <Foundation/Foundation.h>

@class BPCoordinate;

@interface BPModelBase : NSObject

@property (nonatomic, strong) BPCoordinate *location;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *lastModified;
@property (nonatomic, strong) NSString *readPermissions;
@property (nonatomic, assign) NSString *writePermissions;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *id;

+(NSArray*) convertArrayOfDict:(NSArray*)dictArr toType:(Class)clazz;


@end
