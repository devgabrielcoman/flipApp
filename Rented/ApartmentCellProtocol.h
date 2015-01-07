//
//  ApartmentCellProtocol.h
//  Rented
//
//  Created by Lucian Gherghel on 05/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ApartmentCellProtocol <NSObject>

- (void)displayGalleryForApartmentAtIndex:(NSInteger)index;
- (void)displayFullMapViewForApartmentAtIndex:(NSInteger)index;
- (void)displayMoreInfoForApartmentAtIndex:(NSInteger)index;

@end