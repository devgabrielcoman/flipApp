//
//  MapUtils.h
//  RentedAddApartment
//
//  Created by Lucian Gherghel on 30/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapUtils : NSObject

+ (void)zoomToFitMarkersOnMap:(MKMapView *)map;

@end
