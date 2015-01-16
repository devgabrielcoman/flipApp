//
//  RentedPanelController.h
//  Rented
//
//  Created by Lucian Gherghel on 23/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "JASidePanelController.h"

@interface RentedPanelController : JASidePanelController

@property BOOL hideLeftButton;

- (UIBarButtonItem *)getLeftButton;

@end
