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
#import <AFNetworking.h>
#import "GeneralUtils.h"


@implementation ApartmentApi

/*
 Grab current user apartment
 */
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
                imgQuery.cachePolicy = kPFCachePolicyIgnoreCache;
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

/*
 Get apartments for feed taking into account user preferences
 */
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
    
//    //include user preferences in search clauses
//    [query whereKey:@"renewaldays" greaterThanOrEqualTo:[NSNumber numberWithInteger:DEP.userPreferences.minRenewalDays]];
//    [query whereKey:@"renewaldays" lessThanOrEqualTo:[NSNumber numberWithInteger:DEP.userPreferences.maxRenewalDays]];
    
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

- (void)addApartmentToFavorites:(PFObject *)apartment withNotification:(BOOL)notification completion:(void (^)(BOOL))completionHandler
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
                favoriteApartment[@"timestamp"] = [NSNumber numberWithLong:(long)[[NSDate date] timeIntervalSince1970]];
                
                [favoriteApartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    completionHandler(succeeded);
                }];
                
                if (notification)
                {
                    PFPush* push = [PFPush new];

                    [push setChannel:[NSString stringWithFormat:@"id%@",[(PFUser*)apartment[@"owner"] objectId]]];
                    
                    NSArray * mutualFriendsFacebookIds=[GeneralUtils mutualFriendsInArray1:DEP.authenticatedUser[@"facebookFriends"] andArray2:apartment[@"owner"][@"facebookFriends"]];
                    
                    NSMutableArray* actualFriends =[NSMutableArray new];
                    for (NSString* friend in mutualFriendsFacebookIds)
                    {
                        if ([DEP.facebookFriendsInfo objectForKey:friend])
                        {
                            [actualFriends addObject:friend];
                        }
                    }
                    
                    if (actualFriends.count>0 && ![DEP.authenticatedUser[@"facebookFriends"] containsObject:apartment[@"owner"][@"facebookID"]])
                    {
                        PFQuery* query = [PFUser query];
                        
    
                        [query whereKey:@"facebookID" containedIn:actualFriends];

                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                           
                            if (!error)
                            {
                                NSString* mutualFriendsString;
                                
                                for (int i =0;i<objects.count;i++)
                                {
                                    PFUser* user = [objects objectAtIndex:i];
                                    if (i==0)
                                    {
                                        mutualFriendsString = user[@"firstName"];
                                    }
                                    else
                                    {
                                        if (i==objects.count-1 || i == 2)
                                        {
                                            mutualFriendsString = [NSString stringWithFormat:@"%@ and %@",mutualFriendsString, user[@"firstName"]];
                                            if (i==2)
                                            {
                                                break;
                                            }
                                        }
                                        else
                                        {
                                            mutualFriendsString = [NSString stringWithFormat:@"%@, %@",mutualFriendsString, user[@"firstName"]];
                                        }
                                    }
                                }
                                NSString* alertString = [NSString stringWithFormat:@"%@ (friends with %@) liked your place",DEP.authenticatedUser[@"firstName"], mutualFriendsString];
                                
                                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     alertString, @"alert",
                                                     @"Increment", @"badge",
                                                     nil];
                                [push setData:data];
                                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    
                                }];
                            }

                        }];
                    }
                    else
                    {
                        NSString* alertString = [NSString stringWithFormat:@"%@ liked your place",DEP.authenticatedUser[@"firstName"]];
                        
                        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                              alertString, @"alert",
                                              @"Increment", @"badge",
                                              nil];
                        [push setData:data];
                        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            
                        }];
                    }
                    
                    
                }
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
        if (succeeded)
        {
            [self addApartmentToFavorites:apartment withNotification:NO completion:^(BOOL succeeded) {
                
            }];
            

            PFPush* push = [PFPush new];
            
            [push setChannel:[NSString stringWithFormat:@"id%@",[(PFUser*)apartment[@"owner"] objectId]]];

        
            NSString* alertString = [NSString stringWithFormat:@"%@ requested your place",DEP.authenticatedUser[@"firstName"]];
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  alertString, @"alert",
                                  @"Increment", @"badge",
                                  nil];
            [push setData:data];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
            }];
            
            
        }
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
        {

            completionHandler(objects, YES);
        }
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
    apartment[@"listingType"] = apartmentInfo[@"listingType"];
    apartment[@"propertyType"] = apartmentInfo[@"propertyType"];
    apartment[@"bedrooms"] = apartmentInfo[@"bedrooms"];
    apartment[@"bathrooms"] = apartmentInfo[@"bathrooms"];
    apartment[@"fee"] = apartmentInfo[@"fee"];
    apartment[@"rent"] = apartmentInfo[@"rent"];
    apartment[@"moveOutOption"] = apartmentInfo[@"moveOutOption"];
    apartment[@"renewalTimestamp"] = apartmentInfo[@"renewalTimestamp"];
    apartment[@"moveOutTimestamp"] = apartmentInfo[@"moveOutTimestamp"];
    apartment[@"description"] = apartmentInfo[@"description"];
//    apartment[@"area"] = [NSNumber numberWithInteger:[apartmentInfo[@"area"] integerValue]];
//    apartment[@"renewaldays"] = [NSNumber numberWithInteger:[apartmentInfo[@"renewaldays"] integerValue]];
    apartment[@"visible"] = apartmentInfo[@"visible"];

    apartment[@"neighborhood"] = apartmentInfo[@"neighborhood"];
    apartment[@"city"] = apartmentInfo[@"city"];
    apartment[@"state"] = apartmentInfo[@"state"];
    apartment[@"zipcode"] = apartmentInfo[@"zipcode"];
    apartment[@"directContact"] = apartmentInfo[@"directContact"];
    apartment[@"requested"] = [NSNumber numberWithInteger:0];




    apartment[@"owner"] = user;
    
    [apartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error)
        {
            
            NSString *urlString = [NSString stringWithFormat:@"fb656809821111233://flip/apartment/%@",apartment.objectId];
            apartment[@"shareUrl"]= urlString;
            [apartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {}];
            
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
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = [NSString stringWithFormat:@"Uploading images"];
    [hud show:YES];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kHostString]];
    NSDictionary *parameters = @{@"apartmentId": apartment.objectId};
    AFHTTPRequestOperation *op = [manager POST:@"apartment/image/add" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

        for(int i = 0; i<images.count; i++)
        {
            
            NSData *imageData = UIImageJPEGRepresentation(images[i], 0.8);
            NSString* fileName = [NSString stringWithFormat:@"image%d.jpeg",i];

            [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];
        }

    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        [hud hide:YES];
        completionHandler(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [hud hide:YES];
        RTLog(@"Error uploading file: %@ %@", error, [error userInfo]);
        completionHandler(NO);
    }];
    [op start];
    

}


@end
