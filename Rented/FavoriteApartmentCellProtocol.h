//
//  FavoriteApartmentCellProtocol.h
//  Rented
//
//  Created by Lucian Gherghel on 23/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FavoriteApartmentCellProtocol <NSObject>

- (void)removeFromApartmentFromFavorites:(NSInteger)apartmentIndex;

@end
