//
//  IRentedUser.h
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Predefined.h"

@protocol IRentedUser <NSObject>

- (BOOL)userIsAuthenticated;
- (void)authenticateUserWithFacebook:(void (^)(BOOL authenticated))completionHandler;
- (void)logoutUser;
- (void)getFacebookMutualFriendsWithFriend:(NSString *)userId completionHandler:(void (^)(NSArray *mutualFriends, BOOL succeeded))completion;
- (void)getCurrentUsersFacebookFriends:(void(^)(NSArray *friends, BOOL succeeded))completion;

@end
