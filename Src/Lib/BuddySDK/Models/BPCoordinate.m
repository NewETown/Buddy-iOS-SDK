//
//  BPCoordinate.m
//  BuddySDK
//
//  Created by Erik Kerber on 12/9/13.
//
//

#import "BPCoordinate.h"

@implementation BPCoordinate

- (NSString *)stringValue
{
    return [NSString stringWithFormat:@"%.4f,%.4f", self.lat, self.lng];
}

@end

@implementation BPCoordinateRange

- (NSString *)stringValue
{
    return [NSString stringWithFormat:@"%.4f,%.4f,%li", self.lat, self.lng, (long)self.range];
}

@end
