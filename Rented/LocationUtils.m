//
//  LocationUtils.m
//  Rented
//
//  Created by Gherghel Lucian on 05/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "LocationUtils.h"

@implementation LocationUtils

+ (CLLocationCoordinate2D)locationFromPoint:(NSString *)point
{
    NSArray *coordinates = [point componentsSeparatedByString:@"|"];
    
    return CLLocationCoordinate2DMake([coordinates[0] doubleValue], [coordinates[1] doubleValue]);
}

@end
