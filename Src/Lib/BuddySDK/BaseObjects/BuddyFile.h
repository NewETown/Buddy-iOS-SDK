//
//  BuddyFile.h
//  BuddySDK
//
//  Created by Nick Ambrose on 7/15/14.
//
//

#import <Foundation/Foundation.h>

@interface BuddyFile : NSObject

@property (nonatomic,strong) NSString *contentType;
@property (nonatomic,strong) NSData *fileData;

@end
