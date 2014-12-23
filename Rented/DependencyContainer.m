//
//  DependencyContainer.m
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "DependencyContainer.h"

@implementation DependencyContainer

static DependencyContainer *_instance;

+(void)load
{
    [self initiateDependencies];
}

+(DependencyContainer *)sharedInstance
{
    if(_instance==nil)
        _instance = [DependencyContainer new];
    return _instance;
}

+(void)initiateDependencies
{
    DEP.api = [RentedApi new];
}

@synthesize authenticatedUser = _authenticatedUser;

- (void)setAuthenticatedUser:(PFUser *)user
{
    _authenticatedUser = user;
}

- (PFUser *)authenticatedUser
{
    if([DEP.api.userApi userIsAuthenticated])
        return [PFUser currentUser];
    
    return nil;
}

@end
