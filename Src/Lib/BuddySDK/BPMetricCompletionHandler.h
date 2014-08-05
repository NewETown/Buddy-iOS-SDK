//
//  BPMetrics.h
//  BuddySDK
//
//  Created by Erik Kerber on 2/2/14.
//
//

#import <Foundation/Foundation.h>

#import "BuddyCallbacks.h"
#import "BPRestProvider.h"

@interface BPMetricCompletionHandler : NSObject

- (instancetype)initWithMetricId:(NSString *)metricId andClient:(id<BPRestProvider>)restProvider;

- (void)signalComplete:(BuddyTimedMetricResult)callback __attribute__ ((deprecated));

- (void)finishMetric:(BuddyTimedMetricResult)callback;


@end


