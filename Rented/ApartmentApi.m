//
//  ApartmentApi.m
//  Rented
//
//  Created by Gherghel Lucian on 05/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ApartmentApi.h"

@implementation ApartmentApi

- (void)userApartment:(void (^)(PFObject *apartment, NSArray *images, BOOL succeeded))completionHandler
{
    PFQuery *query = [PFQuery queryWithClassName:@"Apartment"];
    [query whereKey:@"owner" equalTo:DEP.authenticatedUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error)
        {
            if(objects.count > 0)
            {
                //each user has only one apartment
                PFObject *apartment = [objects firstObject];
                
                PFQuery *imgQuery = [PFQuery queryWithClassName:@"ApartmentPhotos"];
                [imgQuery whereKey:@"apartment" equalTo:apartment];
                [imgQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if(!error)
                    {
                        RTLog(@"Images: %lu", (unsigned long)objects.count);
                        completionHandler(apartment, objects, YES);
                    }
                    else
                        completionHandler(apartment, @[], NO);
                }];
            }
            else
                //user doesn't have any apartment
                completionHandler(nil, nil, YES);
        }
        else
            completionHandler(nil, nil, NO);
    }];
}

@end
