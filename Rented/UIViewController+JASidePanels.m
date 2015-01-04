//
//  UIViewController+JASidePanels.m
//  Rented
//
//  Created by Lucian Gherghel on 03/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "UIViewController+JASidePanels.h"
#import <JASidePanelController.h>

@implementation UIViewController (JASidePanels)

- (JASidePanelController *)sidePanelController {
    UIViewController *iter = self.parentViewController;
    while (iter) {
        if ([iter isKindOfClass:[JASidePanelController class]]) {
            return (JASidePanelController *)iter;
        } else if (iter.parentViewController && iter.parentViewController != iter) {
            iter = iter.parentViewController;
        } else {
            iter = nil;
        }
    }
    return nil;
}

@end
