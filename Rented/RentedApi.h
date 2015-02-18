//
//  RentedApi.h
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRentedUser.h"
#import "IRentedApartment.h"

// API communication interface
// Contain objects that implements specific interfaces for specialized endpoints communication.
// In this case: userApi - implements all endpoint calls to user related calls
//               apartmentApi - implementes endpoints related to apartments

@interface RentedApi : NSObject

@property id<IRentedUser> userApi;
@property id<IRentedApartment> apartmentApi;

@end
