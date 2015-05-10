//
//  CustomActivityItemProvider.m
//  Rented
//
//  Created by Cristian Olteanu on 4/6/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "CustomActivityItemProvider.h"

@implementation CustomActivityItemProvider

- (id)initWithDefaultUrl:(NSURL*) url andFBURL:(NSURL*)fburl;
{
    self = [super initWithPlaceholderItem:url];
    if ( self )
    {
        self.fbURL = fburl;
    }
    return self;
}

- (id)item
{
    if ( [self.placeholderItem isKindOfClass:[NSURL class]] )
    {
        NSURL *outputURL = [self.placeholderItem copy];
        
        if ( self.activityType == UIActivityTypePostToFacebook || YES)
        {
            outputURL = self.fbURL;
        }
        
        return outputURL;
    }
    
    return self.placeholderItem;
}

@end