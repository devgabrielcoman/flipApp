//
//  TutorialPageView.m
//  Rented
//
//  Created by macmini on 1/12/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "TutorialPageView.h"
#import "AuthenticationViewController.h"
#import "RentedPanelController.h"
#import "AppDelegate.h"

@implementation TutorialPageView


-(void)viewDidLoad
{
    [self setTitle:@" "];
    
    [self.imageView setImage:self.image];
    UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goLeft)];
    swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.imageView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goRight)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.imageView addGestureRecognizer:swipeLeft];
}

-(void)goLeft
{
    if([[self.navigationController.viewControllers objectAtIndex:0] isKindOfClass:[AuthenticationViewController class]] || self.index>1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        AppDelegate* appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate.rootViewController showLeftPanelAnimated:YES];
    }

}

-(void)goRight
{
    if (self.index==1)
    {
        TutorialPageView *page2 = [[TutorialPageView alloc] initWithNibName:@"TutorialPageView" bundle:nil];
        page2.image= [UIImage imageNamed:@"2"];
        page2.index=2;
        
        [self.navigationController pushViewController:page2 animated:YES];
    }
    if (self.index==2)
    {
        TutorialPageView *page3 = [[TutorialPageView alloc] initWithNibName:@"TutorialPageView" bundle:nil];
        page3.image= [UIImage imageNamed:@"3"];
        page3.index=3;
        
        [self.navigationController pushViewController:page3 animated:YES];
    }
    if (self.index==3)
    {
        if([[self.navigationController.viewControllers objectAtIndex:0] isKindOfClass:[AuthenticationViewController class]])
        {
            AuthenticationViewController * authVC = [[AuthenticationViewController alloc] initWithNibName:@"AuthenticationViewController" bundle:nil];
            [self.navigationController pushViewController:authVC animated:YES];
        }
        else
        {
            AppDelegate* appDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate.rootViewController showLeftPanelAnimated:YES];
        }
    }
}

@end
