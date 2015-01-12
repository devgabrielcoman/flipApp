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
    [query includeKey:@"owner"];
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
    [query whereKey:@"visible" equalTo:@1];
    
    //include user preferences in search clauses
    [query whereKey:@"renewaldays" greaterThanOrEqualTo:[NSNumber numberWithInteger:DEP.userPreferences.minRenewalDays]];
    [query whereKey:@"renewaldays" lessThanOrEqualTo:[NSNumber numberWithInteger:DEP.userPreferences.maxRenewalDays]];
    
    if (DEP.userPreferences.vacancyTypes && DEP.userPreferences.vacancyTypes.count)
        [query whereKey:@"vacancy" containedIn:DEP.userPreferences.vacancyTypes];
    
    if(DEP.userPreferences.minRent > 0)
        [query whereKey:@"rent" greaterThanOrEqualTo:[NSNumber numberWithInteger:DEP.userPreferences.minRent]];
    
    if(DEP.userPreferences.maxRent > 0)
        [query whereKey:@"rent" lessThanOrEqualTo:[NSNumber numberWithInteger:DEP.userPreferences.maxRent]];

    if(DEP.userPreferences.minSqFt > 0)
        [query whereKey:@"area" greaterThanOrEqualTo:[NSNumber numberWithInteger:DEP.userPreferences.minSqFt]];
    
    if(DEP.userPreferences.maxSqFt > 0)
        [query whereKey:@"area" lessThanOrEqualTo:[NSNumber numberWithInteger:DEP.userPreferences.maxSqFt]];

    if (DEP.userPreferences.rooms && DEP.userPreferences.rooms.count > 0)
        [query whereKey:@"rooms" containedIn:DEP.userPreferences.rooms];
    
    
    [query includeKey:@"owner"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error)
        {
            NSMutableArray *mutableArray = [NSMutableArray new];
            
            for(PFObject *ap in objects)
            {
                RTLog(@"%li", (long)[ap[@"visible"] integerValue]);
                
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

- (void)addApartmentToFavorites:(PFObject *)apartment completion:(void (^)(BOOL succeeded))completionHandler
{
    PFQuery *query = [PFQuery queryWithClassName:@"Favorites"];
    [query whereKey:@"apartment" equalTo:apartment];
    [query whereKey:@"user" equalTo:DEP.authenticatedUser];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error)
        {
            
            if(objects.count>0)
                completionHandler(YES);
            else
            {
                PFObject *favoriteApartment = [PFObject objectWithClassName:@"Favorites"];
                favoriteApartment[@"apartment"] = apartment;
                favoriteApartment[@"user"] = DEP.authenticatedUser;
                
                [favoriteApartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    completionHandler(succeeded);
                }];
            }
        }
        else
            completionHandler(NO);
    }];
}

- (void)getListOfFavoritesApartments:(void (^)(NSArray *favoriteApartments, BOOL succeeded))completionHandler
{
    PFQuery *query = [PFQuery queryWithClassName:@"Favorites"];
    [query whereKey:@"user" equalTo:DEP.authenticatedUser];
    [query includeKey:@"user"];
    [query includeKey:@"apartment"];
    [query includeKey:@"apartment.owner"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error)
        {
            NSMutableArray *favorites = [NSMutableArray new];
            
            for(PFObject *favAp in objects)
            {
                PFObject *apart = favAp[@"apartment"];
                
                PFQuery *imgQuery = [PFQuery queryWithClassName:@"ApartmentPhotos"];
                [imgQuery whereKey:@"apartment" equalTo:apart];
                
                Apartment *apartment = [Apartment new];
                apartment.apartment = apart;
                apartment.images = [imgQuery findObjects];
                
                
                [favorites addObject:apartment];
            }
            
            completionHandler(favorites, YES);
        }
        else
            completionHandler(@[], NO);
    }];
}

- (void)makeApartmentLive:(PFObject *)apartment completion:(void (^)(BOOL succeeded))completionHandler
{
    apartment[@"visible"] = [NSNumber numberWithInteger:1];
    
    [apartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionHandler(succeeded);
    }];
}

@end
