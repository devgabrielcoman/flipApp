//
//  SelectLocationViewController.m
//  RentedAddApartment
//
//  Created by Lucian Gherghel on 30/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "SelectLocationViewController.h"
#import <MapKit/MapKit.h>
#import "AddApartmentViewController.h"

#import "LocationUtils.h"
#import "TRAutocompleteView.h"
#import "TRGoogleMapsAutocompleteItemsSource.h"
#import "TRGoogleMapsAutocompletionCellFactory.h"
#import "TRAutocompletionDelegate.h"
#import "MapUtils.h"

@interface SelectLocationViewController ()<UITextFieldDelegate, TRAutocompletionDelegate>
{
    TRAutocompleteView *locationAutocomplete;
    MKPointAnnotation *locationPin;
    
    CLLocationCoordinate2D apartmentLocation;
    NSString *apartmentLocationName;
}

@property (weak, nonatomic) IBOutlet UITextField *searchLocationTF;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end

@implementation SelectLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Location";
    
    _mapView.layer.borderWidth = 0.5f;
    _mapView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f].CGColor;
    _mapView.layer.cornerRadius = 6.0f;
    
    locationAutocomplete = [TRAutocompleteView autocompleteViewBindedTo:_searchLocationTF
                                                            usingSource:[[TRGoogleMapsAutocompleteItemsSource alloc] initWithMinimumCharactersToTrigger:2 apiKey:GoogleMapsApiKey]
                                                            cellFactory:[[TRGoogleMapsAutocompletionCellFactory alloc] initWithCellForegroundColor:[UIColor lightGrayColor] fontSize:14]
                                                           presentingIn:self];
    locationAutocomplete.delegate = self;
    _searchLocationTF.delegate = self;
    
    apartmentLocation = kCLLocationCoordinate2DInvalid;
    
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(selectLocation)];
    
    locationPin = [MKPointAnnotation new];
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - TRAutocomplete delegate method

- (void)didAutocompleteWith:(NSString *)string
{
    if(locationPin)
        [_mapView removeAnnotation:locationPin];
        
    apartmentLocation = [self locationFromString:string];
    apartmentLocationName = string;
    
    if(CLLocationCoordinate2DIsValid(apartmentLocation))
    {
        [locationPin setCoordinate:apartmentLocation];
        [_mapView addAnnotation:locationPin];
        [MapUtils zoomToFitMarkersOnMap:_mapView];
    }
}

- (CLLocationCoordinate2D)locationFromString:(NSString *)location
{
    id point = [LocationUtils pointFromString:location];
    
    return CLLocationCoordinate2DMake([point[@"lat"] floatValue], [point[@"lng"] floatValue]);
}

- (void)selectLocation
{
    AddApartmentViewController *addApartmentVC = (AddApartmentViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    addApartmentVC.apartmentLocation = apartmentLocation;
    addApartmentVC.locationName = apartmentLocationName;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyboard];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
