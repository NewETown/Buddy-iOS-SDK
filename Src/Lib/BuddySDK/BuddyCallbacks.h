//
//  BuddyCallbacks.h
//  BuddySDK
//
//  Created by Nick Ambrose on 7/30/14.
//
//

#ifndef BuddySDK_BuddyCallbacks_h
#define BuddySDK_BuddyCallbacks_h

@class BPMetricCompletionHandler;

typedef void (^BuddyCompletionCallback)(NSError *error);
typedef void (^BuddyObjectCallback)(id newBuddyObject, NSError *error);
typedef void (^BuddyDeviceCallback)(id response);
typedef void (^BuddyTimedMetricResult)(NSInteger elapsedTimeInMs, NSError *error);
typedef void (^BuddyMetricCallback)(BPMetricCompletionHandler *metricCompletionHandler, NSError *error);

typedef void (^RESTCallback)(id obj, NSError *error);

#endif
