//
//  EnterAddressViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 3/5/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "EnterAddressViewController.h"
#import "TRAutocompleteView.h"
#import "TRGoogleMapsAutocompleteItemsSource.h"
#import "TRGoogleMapsAutocompletionCellFactory.h"
#import "TRAutocompletionDelegate.h"
#import "LocationUtils.h"

@interface EnterAddressViewController ()
{
    TRAutocompleteView *locationAutocomplete;
}

@end



@implementation EnterAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneButton setBackgroundColor:[UIColor whiteColor]];
    [doneButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];

    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:doneButton], nil]];
    
    [self.addressTextField becomeFirstResponder];
    [self.addressTextField setText:self.addressString];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!locationAutocomplete)
    {
        
        //configure the autocomplete view
        
        locationAutocomplete = [TRAutocompleteView autocompleteViewBindedTo:self.addressTextField
                                                                usingSource:[[TRGoogleMapsAutocompleteItemsSource alloc] initWithMinimumCharactersToTrigger:2 apiKey:GoogleMapsApiKey]
                                                                cellFactory:[[TRGoogleMapsAutocompletionCellFactory alloc] initWithCellForegroundColor:[UIColor lightGrayColor] fontSize:14]
                                                               presentingIn:self];
        locationAutocomplete.delegate = self;
    }
    
    
}
- (CLLocationCoordinate2D)locationFromString:(NSString *)location
{
    id point = [LocationUtils pointFromString:location];
    
    return CLLocationCoordinate2DMake([point[@"lat"] floatValue], [point[@"lng"] floatValue]);
}

-(void)customiseWithString:(NSString*) string
{
    if(string)
    {
        self.addressString = string;
    }
}
#pragma mark - TRAutocomplete delegate method

- (void)didAutocompleteWith:(NSString *)string
{
    self.apartmentLocation = [self locationFromString:string];
    [self.delegate finishedEnteringAddress:self.apartmentLocation andString:string];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
