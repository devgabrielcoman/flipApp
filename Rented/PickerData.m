//
//  PickerData.m
//  RentedAddApartment
//
//  Created by Lucian Gherghel on 30/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "PickerData.h"

@implementation PickerData

-(instancetype)initWithDisplayName:(NSString *)displayName andValue:(id)value
{
    self = [self init];
    
    if(self)
    {
        self.displayName = displayName;
        self.value = value;
    }
    
    return self;
}

@end
