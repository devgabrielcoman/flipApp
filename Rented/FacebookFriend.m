//
//  FacebookFriend.m
//  Rented
//
//  Created by Gherghel Lucian on 12/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "FacebookFriend.h"

@implementation FacebookFriend

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    FacebookFriend *otherFr = object;
    if([self.userId isEqualToString:otherFr.userId])
        return YES;
    
    return NO;
}

@end
