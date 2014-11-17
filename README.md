# Buddy iOS SDK
These release notes are for the Buddy Platform iOS SDK.

Please refer to [buddyplatform.com/docs](https://buddyplatform.com/docs) for more details on the iOS SDK.

**NOTE**: The iOS SDK has recently been updated! Please see the [iOS 3.0 Migration](http://buddyplatform.com/docs/iOS%20SDK%203.0%20Migration) page for a quickstart guide.

## Introduction

We realized most app developers end up writing the same code over and over again: user management, photo management, geolocation, checkins, metadata, and other basic features. Buddy enables developers to build cloud-connected apps without having to write, test, manage or scale server-side code and infrastructure.

Buddy's easy-to-use, scenario-focused APIs let you spend more time building your app and less time worrying about backend infrastructure.

The iOS SDK handles the following functionality:

* Building and formatting requests
* Managing authentication
* Parsing responses
* Loading and saving credentials

## Getting Started

To get started with the Buddy Platform SDK, please reference the _Getting Started_ series of documents at [buddyplatform.com/docs](https://buddyplatform.com/docs). You will need an App ID and Key before you can use the SDK. The _Getting Started_ documents will walk you through obtaining everything you need and show you where to find the SDK for your platform.

Application IDs and Keys are obtained at the Buddy Developer Dashboard at [buddyplatform.com](https://buddyplatform.com/login).

Full documentation for Buddy's services are available at [buddyplatform.com/docs](https://buddyplatform.com/docs).

## Installing the SDK

### Prerequisites

* iOS 6.0 or greater
* Xcode 5.1 or greater

### Install from Cocoapods

We recommend using Cocoapods to install the BuddySDK because it's fast and easy and makes it much easier to keep up to date with SDK releases.  If you're new to Cocoapods, see install instructions [here](http://guides.cocoapods.org/using/getting-started.html#installation).

To create a new project using the Buddy SDK:

1) Create a new Xcode project 

2) In a Terminal window

    cd <project-dir>

3) Create a Podfile 

    touch Podfile

4) Open the file with your favorite editor and add:

    platform :ios, '6.0'
    pod 'BuddySDK'

5) Save the Podfile

6) In your terminal run

    pod install

### Install Locally

#### Install from GitHub

1) Clone this repository

    git clone https://github.com/BuddyPlatform/Buddy-iOS-SDK.git

2) Build the project (for specific build instructions see our [iOS documentation](https://buddyplatform.com/docs/iOS%20SDK))

3) Include the BuddySDK.framework into the Frameworks section of your project in Xcode

4) Ensure the following Frameworks are linked to your project

    * CoreLocation
    * MobileCoreServices
    * SystemConfiguration
    * CFNetwork

## Using the iOS SDK

Visit the [Buddy Dashboard](https://buddyplatform.com) to obtain your application ID and key.

### Initialize the SDK

    #import "BuddySDK/Buddy.h"
    // ...
    // Create the SDK client
    [Buddy init:@"myAppId" appKey: @"myAppKey"]
    
If you want to utilize multiple clients at once you can use:

    #import "BuddySDK/Buddy.h"
    // ...
    // Create the SDK client
    NSDictionary *options1 = @{@"instanceName": @"firstInstance"};
    NSDictionary *options2 = @{@"instanceName": @"secondInstance"};
    BPClient* firstClient = [Buddy init:@"myAppId" appKey:@"myAppKey" withOptions:options1];
    BPClient* secondClient = [Buddy init:@"myAppId" appKey:@"myAppKey" withOptions:options2];
    [firstClient GET:@"/videos" parameters:@{@"caption": @"caption search string"} callback:^(id json, NSError *error) {
      // Display the video
    }];
    [secondClient loginUser:@"username" password:@"password" callback:^(id newBuddyObject, NSError *error) {
      // Direct user 2 to the video user 1 uploaded
    }];
This allows you to have two users logged in at the same time, or manage multiple of any other thing the SDK tracks ( device information, location, etc.). The Buddy object will always be referencing the last client that was created.

### User Flow

The Buddy iOS SDK handles user creation, login, and logout.

#### Create A User

    // Create a user
    BuddyObjectCallback loginCallback = [self getLoginCallback];
    // Only Username and Password are required
    [Buddy createUser:self.signupUsername.text
           password:self.signupPassword.text
           firstName:self.signupFirstName.text
           lastName:self.signupLastName.text
           email:self.signupEmail.text
           dateOfBirth:nil 
           gender:nil 
           tag:nil 
           callback:loginCallback];

#### User Login

    // Login a user
    [Buddy loginUser:@"username" password:@"password" callback:^(id newBuddyObject, NSError *error)
    {
      if(!error)
      {
        // Greet the user
      }
    }];

#### User Logout

    // Logout a user
    [Buddy logoutUser:^(NSError *error) {
      // Perform some action on logout
    }];
	
### REST Interface
	  
Each SDK provides wrappers that make REST calls to Buddy. Responses can be handled in two ways: you can create your own wrapper classes, similar to those found in the `Models` folder, or you can use a basic `[NSDictionary class]`.

#### POST

In this example we'll create a checkin. Take a look at the [create checkin REST documentation](https://buddyplatform.com/docs/Create%20Checkin/HTTP) then:
	 
 	  // Create a checkin
 	  BPCoordinate *coord = BPCoordinateMake(47.1, -121.292);
    
    NSDictionary *params = @{@"location": coord,
                             @"comment": @"A comment about this awesome place!"};
    
    [Buddy POST:@"/checkins" parameters:params class:[NSDictionary class] callback:^(id obj, NSError *error) {
        if(!error) {
          NSLog(@"Checkin post went as planned");
        } else {
          NSLog(@"%@", error);
        }
    }];

#### GET

We now can call GET to search for the checkin we just created!

    BPCoordinateRange *range = BPCoordinateRangeMake(47.1, -121.292, 2500);
    
    NSDictionary *params = @{@"locationRange": range};
    
    [Buddy GET:@"/checkins" parameters:params class:[BPPageResults class] callback:^(id obj, NSError *error) {
        if(!error) {
          BPPageResults *searchResults = (BPPageResults*)obj
          NSArray *checkins = [searchResults convertPageResultsToType:[BPCheckin class] ];
          NSLog(@"%@", checkins); // Log or do something with the response
        } else {
          NSLog(@"GET checkins was unsuccessful.");
          NSLog(@"%@", error);
        }
    }];

#### PUT/PATCH/DELETE

Each remaining REST verb is available through the Buddy SDK using the same pattern as the POST example.
	 
### Working With Files

Buddy offers support for binary files. The iOS SDK works with files through our REST interface similarly to other API calls. The key class is `BPFile`, which is a wrapper around NSData along with a MIME content type.

**Note:** Responses for files deviate from the standard Buddy response templates. See the [Buddy Platform documentation](https://buddyplatform.com/docs) for more information.

#### Upload A File

Here we demonstrate uploading a picture. All binary files use the same pattern with a different path and different parameters. To upload a picture POST to `"/pictures"`:

    BPFile *file = [[BPFile alloc] init];
    file.contentType = @"image/jpg";
    file.fileData = UIImageJPEGRepresentation(koi, .75);
    
    NSDictionary *parameters = @{@"data": file,
                                 @"caption": @"Koi are awesome fish."};
    
    [Buddy POST:@"/pictures" parameters:parameters class:[NSDictionary class] callback:^(id obj, NSError *error) {
        if (!error) {
          NSLog(@"Image uploaded successfully");
        } else {
          NSLog(@"Image upload went wrong");
          NSLog(@"%@", error);
        }
    }];

#### Download A File

To download a file send a GET request with BPFile as the operation type. This sample downloads the picture we uploaded in the "Upload File" example:

    // Don't forget to store the picture ID in pictureId!

    [Buddy GET:[NSString stringWithFormat:@"/pictures/%@/file", pictureId] parameters:nil class:[BPFile class] callback:^(id obj, NSError *error) {
        
        if(!error)
        {
          BPFile *file = (BPFile*)obj;
            
          UIImage* image = [UIImage imageWithData:file.fileData];
          // Do something with the image!
            
          NSLog(@"Image download successful");
        } else {
          NSLog(@"Something went wrong");
        }
        
    }];

## Contributing Back: Pull Requests

We'd love to have your help making the Buddy SDK as good as it can be!

To submit a change to the Buddy SDK please do the following:

1) Create your own fork of the Buddy SDK

2) Make the change to your fork

3) Before creating your pull request, please sync your repository to the current state of the parent repository: `git pull origin master`

4) Commit your changes, then [submit a pull request](https://help.github.com/articles/using-pull-requests) for just that commit

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