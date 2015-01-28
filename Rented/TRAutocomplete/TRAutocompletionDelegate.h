//
//  TRAutocompleteDelegate.h
//  RentedAddApartment
//
//  Created by Lucian Gherghel on 30/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TRAutocompletionDelegate <NSObject>

-(void)didAutocompleteWith:(NSString *)string;

@end