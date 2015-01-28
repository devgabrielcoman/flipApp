//
//  RequestsBuilder.m
//  RentedAddApartment
//
//  Created by Lucian Gherghel on 30/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "RequestsBuilder.h"
#import <AFNetworking.h>

#define AFNRequestsManager [AFHTTPRequestOperationManager manager]


@implementation RequestsBuilder

+ (void)addRequestOnQueue:(NSString *)url
               httpMethod:(NSString *)httpMethod
               parameters:(NSDictionary *)parameters
        completionHandler:(void (^) (BOOL success, id JSON))completionHandler
{
    NSMutableURLRequest *requestData = [AFNRequestsManager.requestSerializer requestWithMethod:httpMethod
                                                                                     URLString:url
                                                                                    parameters:parameters
                                                                                         error:nil];
    
    requestData.timeoutInterval = RequestTimeoutInterval;
    
    AFHTTPRequestOperation *afnRequest = [[AFHTTPRequestOperation alloc] initWithRequest:requestData];
    
    
    afnRequest.responseSerializer = [AFJSONResponseSerializer serializer];
    AFNRequestsManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [afnRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if(responseObject)
                                        {
                                            completionHandler(YES, responseObject);
                                        }
                                        else
                                            completionHandler(NO, nil);
                                        }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          completionHandler(YES, nil);
                                        }];
    
    [AFNRequestsManager.operationQueue addOperation:afnRequest];
}

@end
