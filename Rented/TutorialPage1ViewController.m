//
//  TutorialPage1ViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 5/11/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "TutorialPage1ViewController.h"
#import "TutorialPage2ViewController.h"

@interface TutorialPage1ViewController ()

@end

@implementation TutorialPage1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
 
    UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
}

-(IBAction)swipeLeft:(id)sender
{
    TutorialPage2ViewController* page2VC =[TutorialPage2ViewController new];
    [self.navigationController pushViewController:page2VC animated:YES];
}

-(IBAction)swipeRight:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)cancelButtonTapped:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)nextButtonTapped:(id)sender
{
    TutorialPage2ViewController* page2VC =[TutorialPage2ViewController new];
    [self.navigationController pushViewController:page2VC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
