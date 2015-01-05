//
//  GalleryNavigationController.m
//  Rented
//
//  Created by Lucian Gherghel on 05/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "GalleryNavigationController.h"

@interface GalleryNavigationController ()

@end

@implementation GalleryNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
