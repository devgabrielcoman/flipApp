//
//  DependencyContainer.h
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RentedApi.h"

#define DEP [DependencyContainer sharedInstance]

@interface DependencyContainer : NSObject

+(DependencyContainer *)sharedInstance;

@property PFUser *authenticatedUser;
@property RentedApi *api;

@end
