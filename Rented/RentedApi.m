//
//  RentedApi.m
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "RentedApi.h"
#import "UserApi.h"
#import "ApartmentApi.h"

@implementation RentedApi

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _userApi = [UserApi new];
        _apartmentApi = [ApartmentApi new];
    }
    return self;
}

@end
