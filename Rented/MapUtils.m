//
//  MapUtils.m
//  RentedAddApartment
//
//  Created by Lucian Gherghel on 30/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "MapUtils.h"

@implementation MapUtils

+ (void)zoomToFitMarkersOnMap:(MKMapView *)map
{
    
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithArray:map.annotations];
    
    for (id annotation in annotations){
        if ([annotation class] == [MKUserLocation class]){
            [annotations removeObject:annotation];
            break;
        }
    }
    
    if ([annotations count] == 0) return;
    
    int i = 0;
    MKMapPoint points[[map.annotations count]];
    
    for (id<MKAnnotation> annotation in annotations)
    {
        points[i++] = MKMapPointForCoordinate(annotation.coordinate);
    }
    
    MKPolygon *poly = [MKPolygon polygonWithPoints:points count:i];
    
    MKCoordinateRegion r = MKCoordinateRegionForMapRect([poly boundingMapRect]);
    r.span.latitudeDelta += r.span.latitudeDelta * 0.6;
    r.span.longitudeDelta += r.span.longitudeDelta * 0.6;
    
    if (r.span.latitudeDelta == 0)
        r.span.latitudeDelta = 0.5;
    if (r.span.longitudeDelta == 0)
        r.span.longitudeDelta = 0.5;
    
    [map setRegion: r animated:YES];
}

@end
