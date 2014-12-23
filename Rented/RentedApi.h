//
//  RentedApi.h
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRentedUser.h"

@interface RentedApi : NSObject

@property id<IRentedUser> userApi;

@end
