//
//  RequestsBuilder.h
//  RentedAddApartment
//
//  Created by Lucian Gherghel on 30/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestsBuilder : NSObject

+ (void)addRequestOnQueue:(NSString *)url
               httpMethod:(NSString *)httpMethod
               parameters:(NSDictionary *)parameters
        completionHandler:(void (^) (BOOL success, id JSON))completionHandler;

@end
