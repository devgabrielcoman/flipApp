//
//  RentedPanelController.m
//  Rented
//
//  Created by Lucian Gherghel on 23/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "RentedPanelController.h"

@implementation RentedPanelController

- (void)stylePanel:(UIView *)panel
{
    panel.layer.cornerRadius = 0.0f;
    panel.clipsToBounds = YES;
}

- (void)styleContainer:(UIView *)container animate:(BOOL)animate duration:(NSTimeInterval)duration {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:container.bounds cornerRadius:0.0f];
    if (animate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        animation.fromValue = (id)container.layer.shadowPath;
        animation.toValue = (id)shadowPath.CGPath;
        animation.duration = duration;
        [container.layer addAnimation:animation forKey:@"shadowPath"];
    }
    container.layer.shadowPath = shadowPath.CGPath;
    container.layer.shadowColor = [UIColor blackColor].CGColor;
    container.layer.shadowRadius = 2.0f;
    container.layer.shadowOpacity = 0.25f;
    container.clipsToBounds = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(UIBarButtonItem *)leftButtonForCenterPanel
{
    PFInstallation* installation = [PFInstallation currentInstallation];
    
    if (installation.badge ==0 || !installation)
    {
        self.imageName = @"menu";
    }
    else
    {
        self.imageName = @"notificationMenu";
    }
    
    UIImage *image = [UIImage imageNamed:self.imageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(toggleLeftPanel:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;

}


-(void) updateMenuButtonWithNumber:(NSInteger)badgeNumber
{

    
    [self _placeButtonForLeftPanel];
}


@end
