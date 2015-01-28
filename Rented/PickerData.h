//
//  PickerData.h
//  RentedAddApartment
//
//  Created by Lucian Gherghel on 30/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PickerData : NSObject

@property NSString *displayName;
@property id value;

-(instancetype)initWithDisplayName:(NSString *)displayName andValue:(id)value;

@end
