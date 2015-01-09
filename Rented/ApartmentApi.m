//
//  ApartmentApi.m
//  Rented
//
//  Created by Gherghel Lucian on 05/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ApartmentApi.h"
#import "Apartment.h"

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


- (void)getFeedApartments:(void (^)(NSArray *apartments, BOOL succeeded))completionHandler
{
    
#warning relational query sucks in parse. didn't found a good solution for the moment. should be changed asap
    
//    PFQuery *innerQuery = [PFQuery queryWithClassName:@"Apartment"];
//    [innerQuery whereKey:@"owner" notEqualTo:DEP.authenticatedUser];
//    PFQuery *query = [PFQuery queryWithClassName:@"ApartmentPhotos"];
//    [query whereKey:@"apartment" matchesQuery:innerQuery];
//    query.limit = 5;
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if(!error)
//        {
//            
//            NSMutableArray *aprts = [NSMutableArray new];
//            NSMutableArray *apartments = [NSMutableArray new];
//            
//            for(PFObject *obj in objects)
//            {
//                PFObject *apartment = obj[@"apartment"];
//                if(![apartments containsObject:apartment])
//                    [apartments addObject:apartment];
//            }
//            
//            for(PFObject *apartment in apartments)
//            {
//                NSMutableArray *images = [NSMutableArray new];
//                
//                for(PFObject *img in objects)
//                {
//                    if(img[@"apartment"] == apartment)
//                        [images addObject:img];
//                }
//                
//                Apartment *ap = [Apartment new];
//                ap.apartment = apartment;
//                ap.images = images;
//                
//                [aprts addObject:ap];
//            }
//            
//            completionHandler(aprts, YES);
//            
//        }
//        else
//            completionHandler(@[], NO);
//    }];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Apartment"];
    [query whereKey:@"owner" notEqualTo:DEP.authenticatedUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error)
        {
            NSMutableArray *mutableArray = [NSMutableArray new];
            
            for(PFObject *ap in objects)
            {
                PFQuery *imgQuery = [PFQuery queryWithClassName:@"ApartmentPhotos"];
                [imgQuery whereKey:@"apartment" equalTo:ap];
                
                Apartment *apartment = [Apartment new];
                apartment.apartment = ap;
                apartment.images = [imgQuery findObjects];
                
                [mutableArray addObject:apartment];
            }
            
            completionHandler(mutableArray, YES);
        }
        else
            completionHandler(@[], NO);
    }];
    
}

@end
