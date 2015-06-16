//
//  CustomActivityItemProvider2.m
//  Rented
//
//  Created by Cristian Olteanu on 5/18/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "CustomActivityItemProvider2.h"

@implementation CustomActivityItemProvider2

-(id)initWithDefaultString:(NSString *)string andEmailString:(NSString *)emailString{
    self = [super initWithPlaceholderItem:string];
    if ( self )
    {
        self.emailString = emailString;
    }
    return self;
}

- (id)item
{
    if ( [self.placeholderItem isKindOfClass:[NSString class]] )
    {
        NSString *outputSring = [self.placeholderItem copy];
        
        if ( self.activityType == UIActivityTypeMail)
        {
            outputSring = self.emailString;
        }
        
        return outputSring;
    }
    
    return self.placeholderItem;
}

@end
