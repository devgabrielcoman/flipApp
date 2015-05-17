//
//  TutorialPage2ViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 5/11/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "TutorialPage2ViewController.h"
#import "TutorialPage3ViewController.h"

@interface TutorialPage2ViewController ()

@end

@implementation TutorialPage2ViewController

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)swipeLeft:(id)sender
{
    TutorialPage3ViewController* page3VC =[TutorialPage3ViewController new];
    [self.navigationController pushViewController:page3VC animated:YES];
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
    TutorialPage3ViewController* page3VC =[TutorialPage3ViewController new];
    [self.navigationController pushViewController:page3VC animated:YES];
}

@end
