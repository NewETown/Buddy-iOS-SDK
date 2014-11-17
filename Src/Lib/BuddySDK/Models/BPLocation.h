//
//  BPLocation.h
//  BuddySDK
//
//  Created by Nick Ambrose on 8/26/14.
//
//

#import "BPModelBase.h"
@interface BPLocation : BPModelBase

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *description;
@property (nonatomic,strong) NSString *address1;
@property (nonatomic,strong) NSString *address2;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *country;
@property (nonatomic,strong) NSString *postalCode;
@property (nonatomic,strong) NSString *fax;
@property (nonatomic,strong) NSString *phone;
@property (nonatomic,strong) NSString *website;
@property (nonatomic,strong) NSString *category;
@property (nonatomic,assign) double distanceFromSearch;

@end
