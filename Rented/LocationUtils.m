//
//  LocationUtils.m
//  Rented
//
//  Created by Gherghel Lucian on 05/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "LocationUtils.h"
#import <AFNetworking.h>


@implementation LocationUtils

+ (CLLocationCoordinate2D)locationFromPoint:(NSString *)point
{
    NSArray *coordinates = [point componentsSeparatedByString:@"|"];
    
    return CLLocationCoordinate2DMake([coordinates[0] doubleValue], [coordinates[1] doubleValue]);
}
+(id)pointFromString:(NSString *)string
{
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"address":string, @"sensor":@"false"/*,@"key":@"AIzaSyCZjBYkzsk6AIyFPCpXarhhrahlkSErbIQ"*/};
    
    NSMutableURLRequest *requestData = [requestManager.requestSerializer requestWithMethod:@"GET"
                                                                                 URLString:@"https://maps.googleapis.com/maps/api/geocode/json"
                                                                                parameters:parameters
                                                                                     error:nil];
    
    [requestData setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:requestData returningResponse:&response error:&error];
    
    id JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    if ([JSON objectForKey:@"results"] != nil)
    {
        NSArray *resultsArray = JSON[@"results"];
        if(resultsArray && resultsArray.count > 0)
            return resultsArray[0][@"geometry"][@"location"];
    }
    
    return nil;
}

@end
