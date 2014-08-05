# Buddy iOS SDK

These release notes are for the Buddy Platform iOS SDK.

Please refer to [buddyplatform.com/docs](http://buddyplatform.com/docs) for more details on the iOS SDK.

## Introduction

Buddy enables developers to build engaging, cloud-connected apps without having to write, test, manage or scale server-side code or infrastructure. We noticed that most mobile app developers end up writing the same code over and over again: user management, photo management, geolocation checkins, metadata, and more.  

Buddy's easy-to-use, scenario-focused APIs let you spend more time building your app, and less time worrying about backend infrastructure.  

This SDK is a thin wrapper over the Buddy REST interfaces, but takes care of the hard parts for you:

* Building and formatting requests
* Managing authentication
* Parsing responses
* Loading and saving credentials

What's left is simply making basic calls to the Buddy REST APIs.  

## Features

For developers the Buddy Platform offers turnkey support for features like the following:

* *User Accounts* - create, delete, authenticate users.
* *Photos* - add photos, search photos, share photos with other users.
* *Geolocation* - check in, search for places, list past checkins.
* *Push Notifications* - easily send push notifications to iOS, Android, or Microsoft devices.
* *Messaging* - send messages to other users, create message groups.
* *User Lists* - set up relationships between users.
* *Game Scores, Metadata, and Boards* - keep track of game scores and states for individual users as well as across users.
* *And more* - check out the rest of the offering at [buddy.com](http://buddy.com)

## Getting Started

To get started with the Buddy Platform SDK, please reference the "Getting Started" series of documents at [buddyplatform.com/docs](http://buddyplatform.com/docs). You will need an App ID and Key before you can use the SDK, and these documents will walk you through obtaining those, and installing the SDK.

App IDs and Keys can be obtained at the Buddy Developer Dashboard at [buddyplatform.com](http://buddyplatform.com).

Full documentation for Buddy's services are available at [buddyplatform.com/docs](http://buddyplatform.com/docs).

## Installing the SDK

### Prerequisites

* iOS 6.0 or greater
* Xcode 5.1 or greater

### Install from Cocoapods

We recommend using Cocoapods to install the BuddySDK because it's fast and easy and makes it much easier to keep up to date with SDK releases.  If you're new to Cocoapods, see install instructions [here](http://guides.cocoapods.org/using/getting-started.html#installation).

To create a new project using the Buddy SDK:

* Create a new Xcode project 
* In a Terminal window, type: `cd <project-dir>`
* Create a Podfile `touch Podfile`
* Open the file with your favorite editor and add:

      platform :ios, '6.0'
      pod 'BuddySDK'

* Save the file, then type: `pod install`


### Install Locally

#### Install from Binaries

* Download the [Buddy iOS SDK](http://buddyplatform.com/docs/SDK%20Downloads)
* Unzip the package to a local directory
* Drag BuddySDK.framework into the Frameworks section of your project in Xcode
* Ensure the following Frameworks are linked to your project
    * CoreLocation
    * MobileCoreServices
    * SystemConfiguration
    * CFNetwork

## Using the iOS SDK

After you have created an application at the Buddy Dashboard, note your App ID and App Key.

To initialize the SDK:

    #import "BuddySDK/Buddy.h"
    // ...
    // Create the SDK client
    [Buddy init:@"myAppId" appKey: @"myAppKey"]
    
    
If you want to operatate two clients at once you can use:

    #import "BuddySDK/Buddy.h"
    // ...
    // Create the SDK client
            BPClient* firstClient = [Buddy init:@"myAppId" appKey:@"myAppKey" autoRecordDeviceInfo:TRUE autoRecordLocation:TRUE instanceName:@"firstName"];
            BPClient* secondClient = [Buddy init:@"myAppId" appKey:@"myAppKey" autoRecordDeviceInfo:TRUE autoRecordLocation:TRUE instanceName: @"secondName"];
    [firstClient GET:@"/videos" parameters:@{@"caption": @"caption search string"} callback:^(id json, NSError *error) {
                //Do stuff here
            }];
    [secondClient loginUser:@""username password:@"password" callback:^(id newBuddyObject, NSError *error) {
                //Do stuff
            }];
This allows you to have two users logged in at the same time, or manage multiple of any other thing the SDK tracks ( device information, location, etc.). The Buddy object will always be referencing the last client that was created.


There are some helper functions for creating users, logging in users, and logging out users:  

    // login a user
    [Buddy loginUser:@"username" password:@"password" callback:^(BPModelUser *loggedInUser, NSError *error)
    {
    	if(!error)
    	{
    		// Greet the user
    	}
    }];
    
	
#### Standard REST requests
	  
The majority of the calls map directly to REST.  For all the calls you can either create a wrapper java class such as those found in `Models`, or you can simply pass a type of `[NSDictionary class]` to be returned as the result.

In this example, we'll create a checkin so see the [Create Checkin REST documentation](http://buddyplatform.com/docs/Create%20Checkin/HTTP), then:
	 
 	 // create a checkin
 	 NSDictionary *checkin = @{@"comment":@"my first checkin", @"description":@"This is where I was doing that thing.",@"location":BPCoordinateMake(11.2, 33.4)};
            
     [Buddy POST:@"/checkins" parameters:checkin class:[BPModelCheckin class] callback:^(id obj, NSError *error) {
                
        [[error should] beNil];
        if(error!=nil)
        {
        	// Display an error
        }
                
        BPModelCheckin *checkinResult = (BPModelCheckin*)obj;
        
        // Do something with the Checkin
        
	}];
	
#### Creating Response Objects

Creating strongly typed response objects is simple.  If the REST operation that you intend to call returns a response that's not avaialble in `Models`, you can easily create one by creating an Objective-C object with fields that match the JSON response fields for the operation.

1.  Go to the Buddy Console and try your operation
2.  When the operation completes, note the fields and their types in the response
3.  Create a Java class that derives from `ModelBase` with the appropriate properties.

For example, if the response to **POST /checkins** looks like:


     {
       "status": 201,
       "result": {
         "comment": "h1",
         "userID": "bv.HrcbbDkMPgfn",
         "id": "cb.gBgbvKFkdhnp",
         "location": {
           "lat": 46.2,
            "lng": -120.1
          },
         "created": "2014-07-09T07:07:21.463Z",
         "lastModified": "2014-07-09T07:07:21.463Z"
     },
     "request_id": "53bcea29b32fad0c405372b6",
     "success": true
    }

The corresponding Objective-C object for _the unique fields under **result**_:

	@interface BPModelCheckin : BPModelBase

	@property (nonatomic, copy) NSString *comment;

    @end
    
Note we do not need to specify the default common properties `id`, `userID`, `location`, `created`, or `lastModified`.

We can then call:

    [Buddy GET:[NSString stringWithFormat:@"/checkins/%@",myCheckinId] parameters:nil class: [BPModelCheckin class] callback:^(id getObj,  NSError *error)
	{
	}];

	 
#### Managing Files

For file uploads and downloads, the Buddy iOS SDK handles this for you as well.  The key class is `BuddyFile`, which is a wrapper around NSData along with a MIME content type.

To upload a picture:

	NSMutableDictionary *pic = [NSMutableDictionary new];
        
    [pic setObject:@"Pic from iOS" forKey:@"caption"];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imagePath = [bundle pathForResource:@"test" ofType:@"png"];
            
    BuddyFile *file = [BuddyFile new];
    file.fileData = [[NSFileManager defaultManager] contentsAtPath:imagePath];
    file.contentType = @"image/png";
        
    [pic setObject:file forKey:@"data"];
        
    [Buddy POST:@"/pictures" parameters:pic class:[NSDictionary class] callback:^(id obj, NSError *error)
    {
    	[[error should] beNil];
        if(error!=nil)
	    {
            return;
        }
        
        // Picture was uploaded successfully
    }];

    
Likewise, to download a picture, specify BuddyFile as the operation type:

	[Buddy GET:[NSString stringWithFormat:@"/pictures/%@/file",picId] parameters:nil class:[BuddyFile class] callback:^(id obj, NSError *error)
	{
    	[[error should] beNil];
        if(error!=nil)
        {
        	return;
        }
                  
        BuddyFile *fileData = (BuddyFile*)obj;
    }];

## Contributing Back: Pull Requests

We'd love to have your help making the Buddy SDK as good as it can be!

To submit a change to the Buddy SDK please do the following:

1. Create your own fork of the Buddy SDK
2. Make the change to your fork
3. Before creating your pull request, please sync your repository to the current state of the parent repository: ```git pull origin master```
4. Commit your changes, then [submit a pull request](https://help.github.com/articles/using-pull-requests) for just that commit

## License

#### Copyright (C) 2014 Buddy Platform, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License. You may obtain a copy of
the License at

  [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License.

