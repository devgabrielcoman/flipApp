//
//  UIViewController+JASidePanels.h
//  Rented
//
//  Created by Lucian Gherghel on 03/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JASidePanelController;

@interface UIViewController (JASidePanels)

@property (nonatomic, weak, readonly) JASidePanelController *sidePanelController;

@end
