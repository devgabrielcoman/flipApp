//
//  blocks.h
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Required keys and Ids
#define MixpanelKey @"353feb40be7efb23e3dbaed0732e52f1" //dev
#define ParseApplicationID @"VMdXjz2Ap3XWhyuQ68x9AnTz5gH288hnExnZMWv7"//dev
#define ParseCliendKey @"sUIGwWjMDHjqMODk8XcbC1rY5rV8UoKsfxRTNRSy"//dev
//#define MixpanelKey @"d99817f969beb90f1844938aacd31f45" //prod
//#define ParseApplicationID @"NfeWASdJkljLxheftuqxxdktFxgY0bFItX6TNTT9"//prod
//#define ParseCliendKey @"bQk3rMiqrzuYSDzJbYjfI3iMuF8NfP6bnIlpYEAj"//prod
#define GoogleMapsApiKey @"AIzaSyCO8K6YKBSF9lmZYKB6FzrkQ0lkq7HuOv4"


#define kHostString @"http://54.69.166.166:3000"
#define kImageHostString @"http://s3.amazonaws.com"

#pragma mark - General usage functions
#define hScr            [[UIScreen mainScreen] bounds].size.height
#define wScr            [[UIScreen mainScreen] bounds].size.width
#define statusBarHeight 20.0f
#define ApartmentDetailsViewHeight 267.0f
#define ApartmentDetailsOtherListingViewHeight 614.0f
#define IS_IPHONE       (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5     (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define ASYNC(...) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ __VA_ARGS__ })
#define ASYNC_MAIN(...) dispatch_async(dispatch_get_main_queue(), ^{ __VA_ARGS__ })

#pragma mark - General Display Setup
#define StatusBarBackgroundColor [UIColor blackColor]

#pragma mark - Component rooms standard

#define Studio 0
#define Bedroom1 1
#define Bedrooms2 2
#define Bedrooms3 3
#define Bedrooms4 4

#define MoveOutImmediately  0
#define MoveOutFlexible     1
#define MoveOutExactDate    2

#define VacancyShortTerm 0
#define VacancyLongTerm 1
#define VacancyFlexible 2

#define Fee3percent 0
#define Fee6percent 1
#define Fee9percent 2
#define FeeOtherpercent 3

#define Weekdays 0
#define Weekends 1
#define Anyday 0

#define RentWillChangeYES 0
#define RentWillChangeNO 1
#define RentWillChangeMaybe 2

#define TypeEntirePlace 0
#define TypePrivateRoom 1

#define TypeApartment   0
#define TypeHouse       1

#pragma mark - User listing status
#define ListingNotRequested 0
#define ListingRequested 1
#define ListingAdded 2

#define RequestTimeoutInterval 30.0

#define FeedTextColor @"546a79"
