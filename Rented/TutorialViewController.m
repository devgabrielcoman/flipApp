//
//  TutorialViewController.m
//  Rented
//
//  Created by macmini on 1/12/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "TutorialViewController.h"
#import "TutorialPageView.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height)];
    
    CGRect frame = self.view.frame;
    TutorialPageView *page1 = [[TutorialPageView alloc] initWithImageName:@"1"];
    page1.frame = frame;
    [self.scrollView addSubview:page1];
    
    TutorialPageView *page2 = [[TutorialPageView alloc] initWithImageName:@"2"];
    frame.origin.x += self.view.frame.size.width;
    page2.frame = frame;
    [self.scrollView addSubview:page2];
    
    TutorialPageView *page3 = [[TutorialPageView alloc] initWithImageName:@"3"];
    frame.origin.x += self.view.frame.size.width;
    page3.frame = frame;
    [self.scrollView addSubview:page3];
}


- (IBAction)closeTutorial:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
