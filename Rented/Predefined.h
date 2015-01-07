//
//  blocks.h
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Required keys and Ids
#define ParseApplicationID @"NfeWASdJkljLxheftuqxxdktFxgY0bFItX6TNTT9"
#define ParseCliendKey @"bQk3rMiqrzuYSDzJbYjfI3iMuF8NfP6bnIlpYEAj"


#pragma mark - General usage functions
#define hScr            [[UIScreen mainScreen] bounds].size.height
#define wScr            [[UIScreen mainScreen] bounds].size.width
#define statusBarHeight 20.0f
#define ApartmentDetailsViewHeight 227.0f
#define IS_IPHONE       (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5     (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define ASYNC(...) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ __VA_ARGS__ })
#define ASYNC_MAIN(...) dispatch_async(dispatch_get_main_queue(), ^{ __VA_ARGS__ })

#pragma mark - General Display Setup
#define StatusBarBackgroundColor [UIColor blackColor]
