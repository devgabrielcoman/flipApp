//
//  RentedPanelController.h
//  Rented
//
//  Created by Lucian Gherghel on 23/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "JASidePanelController.h"
//    Custom implementation of JASidePanelController to override some of the default behaviour, like central panel shadow or removing rounded corners
@interface RentedPanelController : JASidePanelController

@property BOOL hideLeftButton;
@property (strong, nonatomic) NSString* imageName;

- (UIBarButtonItem *)getLeftButton;
-(void) updateMenuButtonWithNumber:(NSInteger)badgeNumber;
@end
