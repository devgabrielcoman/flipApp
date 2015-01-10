//
//  IRentedApartment.h
//  Rented
//
//  Created by Gherghel Lucian on 05/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IRentedApartment <NSObject>

- (void)userApartment:(void (^)(PFObject *apartment, NSArray *images, BOOL succeeded))completionHandler;
- (void)getFeedApartments:(void (^)(NSArray *apartments, BOOL succeeded))completionHandler;

- (void)addApartmentToFavorites:(PFObject *)apartment completion:(void (^)(BOOL succeeded))completionHandler;
- (void)getListOfFavoritesApartments:(void (^)(NSArray *favoriteApartments, BOOL succeeded))completionHandler;


@end
