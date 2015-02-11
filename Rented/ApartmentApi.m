//
//  ApartmentApi.m
//  Rented
//
//  Created by Gherghel Lucian on 05/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ApartmentApi.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Apartment.h"
#import <MBProgressHUD.h>


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
                imgQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
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
    
#warning relational query sucks in parse. didn't found a better solution for the moment
    
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
    
//    if (DEP.userPreferences.address)
//    {
//        [query whereKey:@"locationName" containsString:DEP.userPreferences.address];
//    }
    
    if (DEP.userPreferences.zipCode && ![DEP.userPreferences.zipCode isEqualToString:@""])
    {
        [query whereKey:@"zipcode" equalTo:DEP.userPreferences.zipCode];
    }

    
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
    
//    [query setLimit:5];
    [query orderByDescending:@"createdAt"];
    
    [query includeKey:@"owner"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error)
        {
            
            if(DEP.userPreferences.showRentalsInUserNetwork )
            {
                [DEP.api.userApi getCurrentUsersFacebookFriends:^(NSArray *friends, BOOL succeeded) {
                    if(succeeded)
                        DEP.userFacebookFriends = friends;
                    
                     [self completeListOfApartmentsForFeed:objects filterOnlyFromNetwork:YES completion:completionHandler];
                }];
            }
            else
            {
                [self completeListOfApartmentsForFeed:objects filterOnlyFromNetwork:NO completion:completionHandler];
            }
        }
        else
            completionHandler(@[], NO);
    }];
    
}

- (void)completeListOfApartmentsForFeed:(NSArray *)apartments filterOnlyFromNetwork:(BOOL)shouldFilter completion:(void (^)(NSArray *apartments, BOOL succeeded))completionHandler
{
    NSMutableArray *mutableArray = [NSMutableArray new];
    
    for(PFObject *ap in apartments)
    {
        PFUser *owner = ap[@"owner"];
        
        PFQuery *imgQuery = [PFQuery queryWithClassName:@"ApartmentPhotos"];
        imgQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        [imgQuery whereKey:@"apartment" equalTo:ap];
        
        Apartment *apartment = [Apartment new];
        apartment.apartment = ap;
        apartment.images = [imgQuery findObjects];
        
        NSArray * currentUserFacebookFriends = [PFUser currentUser][@"facebookFriends"];
        
        if(shouldFilter)
        {
            if([currentUserFacebookFriends containsObject:owner[@"facebookID"]])
                [mutableArray addObject:apartment];
        }
        else
            [mutableArray addObject:apartment];
    }
    
    completionHandler(mutableArray, YES);
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
                imgQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
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

- (void)hideLiveApartment:(PFObject *)apartment completion:(void (^)(BOOL succeeded))completionHandler
{
    apartment[@"visible"] = [NSNumber numberWithInteger:0];
    
    [apartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionHandler(succeeded);
    }];
}


- (void)addApartmentToGetRequests:(PFObject *)apartment completion:(void (^)(BOOL succeeded))completionHandler
{
    PFObject *request = [PFObject objectWithClassName:@"ApartmentRequests"];
    request[@"apartment"] = apartment;
    request[@"user"] = DEP.authenticatedUser;
    
    [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionHandler(succeeded);
    }];
}

- (void)userHasRequestForApartment:(PFObject *)apartment completion:(void (^)(NSArray *objects, BOOL succeeded))completionHandler
{
    PFQuery *query = [PFQuery queryWithClassName:@"ApartmentRequests"];
    [query whereKey:@"user" equalTo:DEP.authenticatedUser];
    [query whereKey:@"apartment" equalTo:apartment];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error)
            completionHandler(objects, YES);
        else
            completionHandler(@[], NO);
    }];
}

- (void)removeApartmentRequest:(PFObject *)apartment completion:(void (^)(BOOL succeeded))completionHandler
{
    PFQuery *query = [PFQuery queryWithClassName:@"ApartmentRequests"];
    [query whereKey:@"user" equalTo:DEP.authenticatedUser];
    [query whereKey:@"apartment" equalTo:apartment];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error)
        {
            PFObject *request = [objects firstObject];
            [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                completionHandler(succeeded);
            }];
        }
        else
            completionHandler(NO);
    }];
}

- (void)removeApartmentFromFavorites:(PFObject *)apartment completion:(void (^)(BOOL succeeded))completionHandler
{
    PFQuery *query = [PFQuery queryWithClassName:@"Favorites"];
    [query whereKey:@"user" equalTo:DEP.authenticatedUser];
    [query whereKey:@"apartment" equalTo:apartment];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error)
        {
            PFObject *request = [objects firstObject];
            [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                completionHandler(succeeded);
            }];
        }
        else
            completionHandler(NO);
    }];
}

- (void)saveApartment:(NSDictionary *)apartmentInfo images:(NSArray *)images forUser:(PFUser *)user completion:(void (^)(BOOL succes))completionHandler
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = @"Uploading";
    [hud show:YES];
    
    PFObject *apartment = [PFObject objectWithClassName:@"Apartment"];
    apartment[@"location"] = apartmentInfo[@"location"];
    apartment[@"locationName"] = apartmentInfo[@"locationName"];
    apartment[@"type"] = apartmentInfo[@"type"];
    apartment[@"rooms"] = apartmentInfo[@"rooms"];
    apartment[@"fee"] = apartmentInfo[@"fee"];
    apartment[@"rentWillChange"] = apartmentInfo[@"rentWillChange"];
    apartment[@"vacancy"] = apartmentInfo[@"vacancy"];
    apartment[@"description"] = apartmentInfo[@"description"];
    apartment[@"area"] = [NSNumber numberWithInteger:[apartmentInfo[@"area"] integerValue]];
    apartment[@"renewaldays"] = [NSNumber numberWithInteger:[apartmentInfo[@"renewaldays"] integerValue]];
    apartment[@"rent"] = [NSNumber numberWithInteger:[apartmentInfo[@"rent"] integerValue]];
    apartment[@"visible"] = [NSNumber numberWithInteger:0];
    apartment[@"renewalTimestamp"] = apartmentInfo[@"renewalTimestamp"];
    apartment[@"neighborhood"] = apartmentInfo[@"neighborhood"];
    apartment[@"city"] = apartmentInfo[@"city"];
    apartment[@"state"] = apartmentInfo[@"state"];
    apartment[@"zipcode"] = apartmentInfo[@"zipcode"];

    
    apartment[@"owner"] = user;
    
    [apartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error)
        {
            //apartment has been saved
            [hud hide:YES];
            [self uploadImages:images forApartment:apartment completion:completionHandler];
        }
        else
            completionHandler(NO);
    }];
}

- (void)uploadImages:(NSArray *)images forApartment:(PFObject *)apartment completion:(void (^)(BOOL succes))completionHandler
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = [NSString stringWithFormat:@"Uploading images"];
    [hud show:YES];
    
    ALAsset *asset = [images firstObject];
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    Byte *buffer = (Byte*)malloc(representation.size);
    NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:representation.size error:nil];
    NSData *sourceData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    
    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"image-%lld.jpg", [@(floor([[NSDate new] timeIntervalSince1970] * 1000)) longLongValue]] data:sourceData];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            PFObject *apartmentPhoto = [PFObject objectWithClassName:@"ApartmentPhotos"];
            apartmentPhoto[@"image"] = imageFile;
            apartmentPhoto[@"apartment"] = apartment;
            
            [apartmentPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error)
                {
                    //apartment[@"images"] = apartmentPhoto;
                    
                    NSMutableArray *remainedImages = [NSMutableArray arrayWithArray:images];
                    [remainedImages removeObject:asset];
                    
                    [hud hide:YES];
                    
                    if(remainedImages.count>0)
                        [self uploadImages:remainedImages forApartment:apartment completion:completionHandler];
                    else
                    {
                        completionHandler(YES);
                    }
                }
                else
                {
                    [hud hide:YES];
                    completionHandler(NO);
                }
            }];
        }
        else
        {
            [hud hide:YES];
            RTLog(@"Error uploading file: %@ %@", error, [error userInfo]);
            completionHandler(NO);
        }
    } progressBlock:^(int percentDone) {
        hud.progress = (float)percentDone/100;
    }];
}


@end
