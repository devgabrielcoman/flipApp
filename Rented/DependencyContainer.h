//
//  DependencyContainer.h
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RentedApi.h"
#import "UserSearchPreferences.h"

#define DEP [DependencyContainer sharedInstance]

@interface DependencyContainer : NSObject

+(DependencyContainer *)sharedInstance;

@property PFUser *authenticatedUser;
@property RentedApi *api;
@property UserSearchPreferences *userPreferences;
@property NSArray *userFacebookFriends;
@property NSMutableArray *favorites;
@property NSMutableDictionary *facebookFriendsInfo;

- (void)saveUserPreferences;

@end
