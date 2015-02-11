//
//  PreferencesViewController.m
//  Rented
//
//  Created by Lucian Gherghel on 11/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "PreferencesViewController.h"
#import "PreferencesSeparateView.h"

@interface PreferencesViewController ()

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    PreferencesSeparateView *pfView = [[[NSBundle mainBundle] loadNibNamed:@"PreferencesSeparateView" owner:self options:nil] firstObject];
    [self.scrollViewWrapper addSubview:pfView];
    [self.scrollViewWrapper setContentSize: CGSizeMake(self.scrollViewWrapper.contentSize.width,600)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
