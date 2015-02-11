//
//  AddApartmentViewController.m
//  RentedAddApartment
//
//  Created by Lucian Gherghel on 30/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "AddApartmentViewController.h"
#import <MapKit/MapKit.h>
#import <CTAssetsPickerController.h>
#import "GCPlaceholderTextView.h"
#import "SelectLocationViewController.h"
#import "PickerData.h"
#import <UIAlertView+Blocks.h>
#import "M13Checkbox.h"
#import "GeneralUtils.h"
#import "UIImage+imageWithColor.h"
#import "UIColor+ColorFromHexString.h"
#import "LocationUtils.h"
#import "TRAutocompleteView.h"
#import "TRGoogleMapsAutocompleteItemsSource.h"
#import "TRGoogleMapsAutocompletionCellFactory.h"
#import "TRAutocompletionDelegate.h"
#import "MapUtils.h"




//set left text field inset
@implementation UITextField (custom)
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 10, bounds.origin.y,
                      bounds.size.width - 20, bounds.size.height);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}
@end

@interface AddApartmentViewController ()
<UITextFieldDelegate, MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, CTAssetsPickerControllerDelegate,TRAutocompletionDelegate>
{
    MKPointAnnotation *locationPin;
    UIPickerView *apartmentTypePicker;
    NSArray *apartmentTypes;
    
    UITextField *activeField;
    CGPoint lastScrollViewOffset;
    UIEdgeInsets lastScrollViewContentInset;
    UIEdgeInsets lastScrollViewScrollIndicator;
    
    NSDate* leaseExpirationDate;

    M13Checkbox *studioRoom;
    M13Checkbox *bedroom1;
    M13Checkbox *bedroom2;
    M13Checkbox *bedroom3;
    M13Checkbox *bedroom4;
    
    M13Checkbox *vacancyImmediate;
    M13Checkbox *vacancyShortTerm;
    M13Checkbox *vacancyNegociable;
    
    M13Checkbox*    fee3percent;
    M13Checkbox*    fee6percent;
    M13Checkbox*    fee9percent;
    
    M13Checkbox*    typeEntirePlace;
    M13Checkbox*    typePrivateRoom;
    M13Checkbox*    typeRetailOrCommercial;
    
    M13Checkbox*    willRentChangeYes;
    M13Checkbox*    willRentChangeNo;
    M13Checkbox*    willRentChangeMaybe;
    
    NSMutableArray *rooms;
    NSMutableArray *vacancy;
    NSMutableArray *fee;
    NSMutableArray *rentWillChange;
    NSMutableArray *type;
    
    UIDatePicker* datePicker;
    
    MKPointAnnotation *currentAnnotation;
    TRAutocompleteView *locationAutocomplete;


}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *otherAmountTextField;
@property (weak, nonatomic) IBOutlet UITextField *typeTF;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *roomsTextView;
@property (weak, nonatomic) IBOutlet UITextField *areaTF;
@property (weak, nonatomic) IBOutlet UITextField *daysRenewalTF;
@property (weak, nonatomic) IBOutlet UITextField *rentTF;
@property (weak, nonatomic) IBOutlet UIButton *addImagesButton;
@property (weak, nonatomic) IBOutlet UIButton *selectOwnerBtn;
@property (weak, nonatomic) IBOutlet UIButton *addApartmentBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *secondScrollViewContainer;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *vacancyLabel;
@property (weak, nonatomic) IBOutlet UILabel *bedroomsLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIButton *monthButton;
@property (weak, nonatomic) IBOutlet UIButton *dayButton;




@end

@implementation AddApartmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //configure views
    
    [self.addApartmentBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47a0db"]] forState:UIControlStateNormal];
    [self.addApartmentBtn.layer setCornerRadius:2.5];
    [self.addApartmentBtn setClipsToBounds:YES];
    
    self.title = @"Add Apartment";
    
    _typeTF.delegate = self;
    _areaTF.delegate = self;
    _daysRenewalTF.delegate = self;
    _rentTF.delegate = self;
    
    _roomsTextView.placeholder = @"Component rooms(Studio, 1 bedroom, 2 bedroom, etc)";
    _roomsTextView.placeholderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
    _roomsTextView.layer.borderWidth = 0.5f;
    _roomsTextView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f].CGColor;
    _roomsTextView.layer.cornerRadius = 6.0f;
    _roomsTextView.delegate = self;
    _roomsTextView.returnKeyType = UIReturnKeyDone;
    
    _descriptionTextView.placeholder = @"Description";
    _descriptionTextView.placeholderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
    _descriptionTextView.layer.borderWidth = 0.5f;
    _descriptionTextView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f].CGColor;
    _descriptionTextView.layer.cornerRadius = 4.0f;
    _descriptionTextView.delegate = self;
//    _descriptionTextView.returnKeyType = UIReturnKeyDone;
    
    _mapView.layer.borderWidth = 0.5f;
    _mapView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f].CGColor;
    _mapView.layer.cornerRadius = 6.0f;
    
    _addApartmentBtn.backgroundColor = [UIColor redColor];

    _addApartmentBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    
    _addImagesButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    _selectOwnerBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneButton setBackgroundColor:[UIColor whiteColor]];
    [doneButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    self.otherAmountTextField.inputAccessoryView = doneButton;
    self.addressTextField.inputAccessoryView = doneButton;
    _areaTF.inputAccessoryView = doneButton;
    _rentTF.inputAccessoryView = doneButton;
    _daysRenewalTF.inputAccessoryView = doneButton;
    
    UITapGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismiss)];
    dismissGesture.numberOfTapsRequired = 1;
    dismissGesture.numberOfTouchesRequired = 1;
    dismissGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:dismissGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    
    _apartmentLocation = kCLLocationCoordinate2DInvalid;
    locationPin = [MKPointAnnotation new];
    

    apartmentTypePicker = [UIPickerView new];
    apartmentTypePicker.delegate = self;
    apartmentTypePicker.dataSource = self;
    _typeTF.inputView = apartmentTypePicker;
    
    [self registerForKeyboardNotifications];
    
    _apartmentType = -1;
    

    
    rooms = [NSMutableArray new];
    
    vacancy = [NSMutableArray new];
    
    fee = [NSMutableArray new];
    
    rentWillChange = [NSMutableArray new];
    
    _apartmentOwner=[PFUser currentUser];
    
    [self.navigationController.navigationBar setHidden:YES];

    //instantiate and configure checkboxes
    [self addCheckboxes];
    
    
    //using view controller in edit mode
    if(self.apartment)
    {
        //customise fields using the apartment's data
        [self customiseViews];
    }

}


-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {

    //user wants to change pin location
    
    //limit gesture to the first frame
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        //check if a pin already exists
        if (currentAnnotation)
        {
            //remove the existing pin
            [self.mapView removeAnnotation:currentAnnotation];
        }
        
        //get the touch point in the mapview frame
        CGPoint point = [sender locationInView:self.mapView];
        //get the coordinate for the point
        CLLocationCoordinate2D locCoord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        
        //configure the annotation with the coordinate
        MKPointAnnotation *dropPin = [[MKPointAnnotation alloc] init];
        dropPin.coordinate = CLLocationCoordinate2DMake(locCoord.latitude, locCoord.longitude);
        _apartmentLocation = CLLocationCoordinate2DMake(_apartmentLocation.latitude=locCoord.latitude, _apartmentLocation.longitude=locCoord.longitude);

        //the the annotation
        currentAnnotation= dropPin;
        
        [self.mapView addAnnotation:dropPin];
        
        //setup the address label with the new coordinate
        CLLocation* location = [[CLLocation alloc] initWithLatitude:_apartmentLocation.latitude longitude:_apartmentLocation.longitude];
        [[CLGeocoder new] reverseGeocodeLocation:location
                               completionHandler:^(NSArray *placemarks, NSError *error) {
                                   
                                   CLPlacemark* placemark= [placemarks firstObject];
                                   NSMutableString* locationString;
                                   if (placemark.subLocality)
                                   {
                                       if (locationString)
                                       {
                                           locationString =[[locationString stringByAppendingString:[NSString stringWithFormat:@", %@",placemark.subLocality]] mutableCopy];
                                       }
                                       else
                                       {
                                           locationString =[placemark.subLocality mutableCopy];
                                       }
                                   }
                                   if (placemark.locality)
                                   {
                                       if (locationString)
                                       {
                                           locationString =[[locationString stringByAppendingString:[NSString stringWithFormat:@", %@",placemark.locality]] mutableCopy];
                                       }
                                       else
                                       {
                                           locationString =[placemark.locality mutableCopy];
                                       }
                                   }
                                   if (placemark.administrativeArea)
                                   {
                                       if (locationString)
                                       {
                                           locationString =[[locationString stringByAppendingString:[NSString stringWithFormat:@", %@",placemark.administrativeArea]] mutableCopy];
                                       }
                                       else
                                       {
                                           locationString = [placemark.subLocality mutableCopy];
                                       }
                                   }
                                   if (placemark.country)
                                   {
                                       if (locationString)
                                       {
                                           locationString =[[locationString stringByAppendingString:[NSString stringWithFormat:@", %@",placemark.country]] mutableCopy];
                                       }
                                       else
                                       {
                                           locationString =[placemark.country mutableCopy];
                                       }
                                   }
                                   
                                   self.addressTextField.text=locationString;
        }];
        
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //create and animate annotation view
    
    MKPinAnnotationView *pinView = nil;
    static NSString *defaultPin = @"pinIdentifier";
    pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPin];
    if(pinView == nil)
        pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:defaultPin];
    pinView.pinColor = MKPinAnnotationColorRed;
    pinView.canShowCallout = NO;
    pinView.animatesDrop = YES;
    
    return pinView;
}

- (void)addCheckboxes
{

    studioRoom = [[M13Checkbox alloc] initWithTitle:@"Studio"];
    studioRoom.frame = CGRectMake(self.bedroomsLabel.frame.origin.x-2, 97, 65, 20);
    studioRoom.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    studioRoom.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    studioRoom.titleLabel.textAlignment = NSTextAlignmentRight;
    studioRoom.checkState = M13CheckboxStateUnchecked;
    [studioRoom addTarget:self action:@selector(checkStudio:) forControlEvents:UIControlEventValueChanged];
    [studioRoom setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [studioRoom setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [studioRoom setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [studioRoom setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    
    [_secondScrollViewContainer addSubview:studioRoom];
    
    bedroom1 = [[M13Checkbox alloc] initWithTitle:@"1"];
    bedroom1.frame = CGRectMake(studioRoom.frame.origin.x + studioRoom.frame.size.width +4, 97, 45, 20);
    bedroom1.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    bedroom1.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    bedroom1.titleLabel.textAlignment = NSTextAlignmentRight;
    [bedroom1 addTarget:self action:@selector(check1Bedroom:) forControlEvents:UIControlEventValueChanged];
    [bedroom1 setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [bedroom1 setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [bedroom1 setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [bedroom1 setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    
    [_secondScrollViewContainer addSubview:bedroom1];
    
    bedroom2 = [[M13Checkbox alloc] initWithTitle:@"2"];
    bedroom2.frame = CGRectMake(bedroom1.frame.origin.x + bedroom1.frame.size.width +4, 97, 45, 20);
    bedroom2.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    bedroom2.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    bedroom2.titleLabel.textAlignment = NSTextAlignmentRight;
    [bedroom2 addTarget:self action:@selector(check2Bedrooms:) forControlEvents:UIControlEventValueChanged];
    [bedroom2 setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [bedroom2 setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [bedroom2 setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [bedroom2 setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    
    [_secondScrollViewContainer addSubview:bedroom2];
    
    bedroom3 = [[M13Checkbox alloc] initWithTitle:@"3"];
    bedroom3.frame = CGRectMake(bedroom2.frame.origin.x + bedroom2.frame.size.width +4, 97, 45, 20);
    bedroom3.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    bedroom3.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    bedroom3.titleLabel.textAlignment = NSTextAlignmentRight;
    [bedroom3 addTarget:self action:@selector(check3Bedrooms:) forControlEvents:UIControlEventValueChanged];
    [bedroom3 setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [bedroom3 setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [bedroom3 setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [bedroom3 setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    
    [_secondScrollViewContainer addSubview:bedroom3];
    
    bedroom4 = [[M13Checkbox alloc] initWithTitle:@"More"];
    bedroom4.frame = CGRectMake(bedroom3.frame.origin.x + bedroom3.frame.size.width +4, 97, 60, 20);
    bedroom4.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    bedroom4.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    bedroom4.titleLabel.textAlignment = NSTextAlignmentRight;
    [bedroom4 addTarget:self action:@selector(check4Bedrooms:) forControlEvents:UIControlEventValueChanged];
    [bedroom4 setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [bedroom4 setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [bedroom4 setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [bedroom4 setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    
    [_secondScrollViewContainer addSubview:bedroom4];
    
    CGFloat widthLeft = wScr - 2 * self.vacancyLabel.frame.origin.x - self.vacancyLabel.frame.size.width;
    CGFloat checkboxWidth = widthLeft /3.0;
    
    vacancyImmediate = [[M13Checkbox alloc] initWithTitle:@"Immediate"];
    vacancyImmediate.frame = CGRectMake(self.vacancyLabel.frame.origin.x + self.vacancyLabel.frame.size.width + 4,
                                        self.vacancyLabel.frame.origin.y,
                                        checkboxWidth-4,
                                        20);
    vacancyImmediate.titleLabel.font = [UIFont systemFontOfSize:8];
    vacancyImmediate.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    vacancyImmediate.titleLabel.textAlignment = NSTextAlignmentLeft;
    vacancyImmediate.checkState = M13CheckboxStateUnchecked;
    [vacancyImmediate addTarget:self action:@selector(checkVacancyImmediate:) forControlEvents:UIControlEventValueChanged];
    [vacancyImmediate setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [vacancyImmediate setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [vacancyImmediate setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [vacancyImmediate setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    [vacancyImmediate setCheckAlignment:M13CheckboxAlignmentLeft];
    [vacancyImmediate.titleLabel setMinimumScaleFactor:0.2];
    [vacancyImmediate.titleLabel setAdjustsFontSizeToFitWidth:YES];

    
    [_scrollViewContainer addSubview:vacancyImmediate];
    
    vacancyShortTerm = [[M13Checkbox alloc] initWithTitle:@"Short Term"];
    vacancyShortTerm.frame = CGRectMake(vacancyImmediate.frame.origin.x + vacancyImmediate.frame.size.width + 4,
                                        vacancyImmediate.frame.origin.y,
                                        checkboxWidth-4,
                                        20);
    vacancyShortTerm.titleLabel.font = [UIFont systemFontOfSize:8];
    vacancyShortTerm.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    vacancyShortTerm.titleLabel.textAlignment = NSTextAlignmentLeft;
    [vacancyShortTerm addTarget:self action:@selector(checkVacancyShortTerm:) forControlEvents:UIControlEventValueChanged];
    [vacancyShortTerm setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [vacancyShortTerm setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [vacancyShortTerm setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [vacancyShortTerm setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    [vacancyShortTerm setCheckAlignment:M13CheckboxAlignmentLeft];
    [vacancyShortTerm.titleLabel setMinimumScaleFactor:0.2];
    [vacancyShortTerm.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    [_scrollViewContainer addSubview:vacancyShortTerm];
    
    vacancyNegociable = [[M13Checkbox alloc] initWithTitle:@"Flexible"];
    vacancyNegociable.frame = CGRectMake(vacancyShortTerm.frame.origin.x + vacancyShortTerm.frame.size.width + 4,
                                         vacancyShortTerm.frame.origin.y,
                                         checkboxWidth-4,
                                         20);
    vacancyNegociable.titleLabel.font = [UIFont systemFontOfSize:8];
    vacancyNegociable.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    vacancyNegociable.titleLabel.textAlignment = NSTextAlignmentRight;
    [vacancyNegociable addTarget:self action:@selector(checkVacancyNegociable:) forControlEvents:UIControlEventValueChanged];
    [vacancyNegociable setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [vacancyNegociable setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [vacancyNegociable setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [vacancyNegociable setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    [vacancyNegociable setCheckAlignment:M13CheckboxAlignmentLeft];
    [vacancyNegociable.titleLabel setMinimumScaleFactor:0.2];
    [vacancyNegociable.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    [_scrollViewContainer addSubview:vacancyNegociable];
    
    
    fee3percent = [[M13Checkbox alloc] initWithTitle:@"3%"];
    fee3percent.checkAlignment = M13CheckboxAlignmentLeft;
    fee3percent.frame = CGRectMake(16,
                                   self.otherAmountTextField.frame.origin.y-1,
                                   51,
                                   20);
    fee3percent.titleLabel.font = [UIFont systemFontOfSize:10];
    fee3percent.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    fee3percent.titleLabel.textAlignment = NSTextAlignmentRight;
    fee3percent.checkState = M13CheckboxStateUnchecked;
    [fee3percent addTarget:self action:@selector(checkFee3Percent:) forControlEvents:UIControlEventValueChanged];
    [fee3percent setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [fee3percent setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [fee3percent setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [fee3percent setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    [fee3percent setCheckAlignment:M13CheckboxAlignmentRight];
    
    [_scrollViewContainer addSubview:fee3percent];
    
    fee6percent = [[M13Checkbox alloc] initWithTitle:@"6%"];
    fee6percent.checkAlignment = NSTextAlignmentRight;
    fee6percent.frame = CGRectMake(fee3percent.frame.origin.x+ fee3percent.frame.size.width + 12,
                                   self.otherAmountTextField.frame.origin.y-1,
                                   51,
                                   20);
    fee6percent.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    fee6percent.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    fee6percent.titleLabel.textAlignment = NSTextAlignmentLeft;
    [fee6percent addTarget:self action:@selector(checkFee6Percent:) forControlEvents:UIControlEventValueChanged];
    [fee6percent setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [fee6percent setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [fee6percent setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [fee6percent setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    [fee6percent setCheckAlignment:M13CheckboxAlignmentRight];
    
    [_scrollViewContainer addSubview:fee6percent];
    
    fee9percent = [[M13Checkbox alloc] initWithTitle:@"9%"];
    fee9percent.checkAlignment = M13CheckboxAlignmentLeft;
    fee9percent.frame = CGRectMake(fee6percent.frame.origin.x+ fee6percent.frame.size.width + 12,
                                   self.otherAmountTextField.frame.origin.y -1,
                                   51,
                                   20);
    fee9percent.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    fee9percent.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    fee9percent.titleLabel.textAlignment = NSTextAlignmentLeft;
    [fee9percent addTarget:self action:@selector(checkFee9Percent:) forControlEvents:UIControlEventValueChanged];
    [fee9percent setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [fee9percent setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [fee9percent setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [fee9percent setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    [fee9percent setCheckAlignment:M13CheckboxAlignmentRight];
    
    [_scrollViewContainer addSubview:fee9percent];
    
    
    
    typeEntirePlace = [[M13Checkbox alloc] initWithTitle:@"Entire Place"];
    typeEntirePlace.frame = CGRectMake(self.typeLabel.frame.origin.x -2, 162, 90, 30);
    typeEntirePlace.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    typeEntirePlace.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    typeEntirePlace.titleLabel.textAlignment = NSTextAlignmentRight;
    typeEntirePlace.checkState = M13CheckboxStateUnchecked;
    [typeEntirePlace addTarget:self action:@selector(checkEntirePlace:) forControlEvents:UIControlEventValueChanged];
    [typeEntirePlace setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [typeEntirePlace setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [typeEntirePlace setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [typeEntirePlace setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    
    [_secondScrollViewContainer addSubview:typeEntirePlace];
    
    
    typePrivateRoom = [[M13Checkbox alloc] initWithTitle:@"Private Room"];
    typePrivateRoom.frame = CGRectMake(typeEntirePlace.frame.origin.x + typeEntirePlace.frame.size.width +4, 162, 95, 30);
    typePrivateRoom.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    typePrivateRoom.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    typePrivateRoom.titleLabel.textAlignment = NSTextAlignmentRight;
    typePrivateRoom.checkState = M13CheckboxStateUnchecked;
    [typePrivateRoom addTarget:self action:@selector(checkPrivateRoom:) forControlEvents:UIControlEventValueChanged];
    [typePrivateRoom setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [typePrivateRoom setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [typePrivateRoom setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [typePrivateRoom setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    
    [_secondScrollViewContainer addSubview:typePrivateRoom];
    
    
    typeRetailOrCommercial = [[M13Checkbox alloc] initWithTitle:@"Retail or\nCommercial"];
    typeRetailOrCommercial.frame = CGRectMake(typePrivateRoom.frame.origin.x + typePrivateRoom.frame.size.width +4, 162, 88, 30);
    [typeRetailOrCommercial.titleLabel setFrame:CGRectMake(typeRetailOrCommercial.titleLabel.frame.origin.x-10, typeRetailOrCommercial.titleLabel.frame.origin.y, typeRetailOrCommercial.titleLabel.frame.size.width, 40)];
    typeRetailOrCommercial.titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:105/255.0 blue:121/255.0 alpha:1];
    typeRetailOrCommercial.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    typeRetailOrCommercial.titleLabel.textAlignment = NSTextAlignmentLeft;
    typeRetailOrCommercial.titleLabel.numberOfLines = 2;
    typeRetailOrCommercial.checkState = M13CheckboxStateUnchecked;
    [typeRetailOrCommercial addTarget:self action:@selector(checkRetailOrCommercial:) forControlEvents:UIControlEventValueChanged];
    [typeRetailOrCommercial setStrokeColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
    [typeRetailOrCommercial setTintColor:[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1]];
    [typeRetailOrCommercial setUncheckedColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [typeRetailOrCommercial setCheckColor:[UIColor colorWithRed:162/255.0 green:174/255.0 blue:182/255.0 alpha:1]];
    
    [_secondScrollViewContainer addSubview:typeRetailOrCommercial];
    
//    willRentChangeLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 660, 200, 30)];
//    willRentChangeLabel.text = @"Will your rent change?:";
//    willRentChangeLabel.font = [UIFont systemFontOfSize:12.0f];
//    [_scrollViewContainer addSubview:willRentChangeLabel];
//    
//    willRentChangeYes = [[M13Checkbox alloc] initWithTitle:@"Yes"];
//    willRentChangeYes.checkAlignment = M13CheckboxAlignmentLeft;
//    willRentChangeYes.frame = CGRectMake(160, 660, 150, 30);
//    willRentChangeYes.titleLabel.font = [UIFont systemFontOfSize:12.0f];
//    willRentChangeYes.titleLabel.textAlignment = NSTextAlignmentLeft;
//    willRentChangeYes.checkState = M13CheckboxStateChecked;
//    [willRentChangeYes addTarget:self action:@selector(checkWillRentChangeYes:) forControlEvents:UIControlEventValueChanged];
//    [_scrollViewContainer addSubview:willRentChangeYes];
//    
//    willRentChangeNo = [[M13Checkbox alloc] initWithTitle:@"No"];
//    willRentChangeNo.checkAlignment = M13CheckboxAlignmentLeft;
//    willRentChangeNo.frame = CGRectMake(160, 660 + 30 + 4, 150, 30);
//    willRentChangeNo.titleLabel.font = [UIFont systemFontOfSize:12.0f];
//    willRentChangeNo.titleLabel.textAlignment = NSTextAlignmentLeft;
//    [willRentChangeNo addTarget:self action:@selector(checkWillRentChangeNO:) forControlEvents:UIControlEventValueChanged];
//    [_scrollViewContainer addSubview:willRentChangeNo];
//    
//    willRentChangeMaybe = [[M13Checkbox alloc] initWithTitle:@"Maybe"];
//    willRentChangeMaybe.checkAlignment = M13CheckboxAlignmentLeft;
//    willRentChangeMaybe.frame = CGRectMake(160, 660 + 60 + 8, 150, 30);
//    willRentChangeMaybe.titleLabel.font = [UIFont systemFontOfSize:12.0f];
//    willRentChangeMaybe.titleLabel.textAlignment = NSTextAlignmentLeft;
//    [willRentChangeMaybe addTarget:self action:@selector(checkWillRentChangeMaybe:) forControlEvents:UIControlEventValueChanged];
//    [_scrollViewContainer addSubview:willRentChangeMaybe];
    

}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)viewWillLayoutSubviews
{

    [self.scrollViewContainer setContentSize:CGSizeMake(wScr, 667)];
    [self.secondScrollViewContainer setContentSize:CGSizeMake(wScr, 450)];
    [super viewWillLayoutSubviews];
    

}

-(void)customiseViews
{
    
    //used in edit mode to customise the selected apartment

    MKPointAnnotation *dropPin = [[MKPointAnnotation alloc] init];
    dropPin.coordinate = [LocationUtils locationFromPoint:_apartment.apartment[@"location"]];
    _apartmentLocation=dropPin.coordinate;
    
    currentAnnotation= dropPin;
    [self.mapView addAnnotation:dropPin];
    
    [MapUtils zoomToFitMarkersOnMap:_mapView];
    
    _addressTextField.text = _apartment.apartment[@"locationName"];
    
    NSString* selectedText = [NSString stringWithFormat:@"%lu images", (unsigned long)_apartment.images.count];
    
    [_addImagesButton setTitle:selectedText forState:UIControlStateNormal];
    
    
    if ([_apartment.apartment[@"vacancy"] containsObject:[NSNumber numberWithInteger:0]])
    {
        [vacancyImmediate setCheckState:M13CheckboxStateChecked];
    }
    if ([_apartment.apartment[@"vacancy"] containsObject:[NSNumber numberWithInteger:1]])
    {
        [vacancyShortTerm setCheckState:M13CheckboxStateChecked];
    }
    if ([_apartment.apartment[@"vacancy"] containsObject:[NSNumber numberWithInteger:2]])
    {
        [vacancyNegociable setCheckState:M13CheckboxStateChecked];
    }
    
    if ([_apartment.apartment[@"fee"] containsObject:[NSNumber numberWithInteger:0]])
    {
        [fee3percent setCheckState:M13CheckboxStateChecked];
    }
    if ([_apartment.apartment[@"fee"] containsObject:[NSNumber numberWithInteger:1]])
    {
        [fee6percent setCheckState:M13CheckboxStateChecked];
    }
    if ([_apartment.apartment[@"fee"] containsObject:[NSNumber numberWithInteger:2]])
    {
        [fee9percent setCheckState:M13CheckboxStateChecked];
    }
    if ([_apartment.apartment[@"fee"] containsObject:[NSNumber numberWithInteger:3]] && [_apartment.apartment[@"feeOther"] floatValue]!=-1)
    {
        self.otherAmountTextField.text = [NSString stringWithFormat:@"%f",[_apartment.apartment[@"feeOther"] floatValue]];
    }
    if ([_apartment.apartment[@"rooms"] containsObject:[NSNumber numberWithInteger:0]])
    {
        [studioRoom setCheckState:M13CheckboxStateChecked];
    }
    if ([_apartment.apartment[@"rooms"] containsObject:[NSNumber numberWithInteger:1]])
    {
        [bedroom1 setCheckState:M13CheckboxStateChecked];
    }
    if ([_apartment.apartment[@"rooms"] containsObject:[NSNumber numberWithInteger:2]])
    {
        [bedroom2 setCheckState:M13CheckboxStateChecked];
    }
    if ([_apartment.apartment[@"rooms"] containsObject:[NSNumber numberWithInteger:3]])
    {
        [bedroom3 setCheckState:M13CheckboxStateChecked];
    }
    if ([_apartment.apartment[@"rooms"] containsObject:[NSNumber numberWithInteger:4]])
    {
        [bedroom4 setCheckState:M13CheckboxStateChecked];
    }
    
    if ([_apartment.apartment[@"type"] integerValue]==0)
    {
        [typeEntirePlace setCheckState:M13CheckboxStateChecked];
    }
    if ([_apartment.apartment[@"type"] integerValue]==1)
    {
        [typePrivateRoom setCheckState:M13CheckboxStateChecked];
    }
     if ([_apartment.apartment[@"type"] integerValue]==2)
    {
        [typeRetailOrCommercial setCheckState:M13CheckboxStateChecked];
    }
    
    _rentTF.text = [NSString stringWithFormat:@"%d",[_apartment.apartment[@"rent"] integerValue]];
    _areaTF.text = [NSString stringWithFormat:@"%d",[_apartment.apartment[@"area"] integerValue]];
    
    if ([_apartment.apartment[@"visible"] integerValue]==1)
    {
        [_addApartmentBtn setTitle:@"UNFLIP" forState:UIControlStateNormal];
    }
    else
    {
        [_addApartmentBtn setTitle:@"FLIP" forState:UIControlStateNormal];
    }
    

    
}

#pragma mark - TRAutocomplete delegate method

- (void)didAutocompleteWith:(NSString *)string
{

    
    _apartmentLocation = [self locationFromString:string];
    
    if(CLLocationCoordinate2DIsValid(_apartmentLocation))
    {
        if (currentAnnotation)
        {
            [self.mapView removeAnnotation:currentAnnotation];
        }
        

        MKPointAnnotation *dropPin = [[MKPointAnnotation alloc] init];
        dropPin.coordinate = _apartmentLocation;
        
        
        currentAnnotation= dropPin;
        [self.mapView addAnnotation:dropPin];

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
    addApartmentVC.apartmentLocation = _apartmentLocation;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Keyboard Notifications handlers

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    //used to resize scroll views when the keboard has finished animating in screen
    
    if (activeField == _otherAmountTextField)
    {
        //uncheck any checked fee checkboxes
        
        if (fee3percent.checkState == M13CheckboxStateChecked)
        {
            [self checkFee3Percent:fee3percent];
            [fee3percent setCheckState:M13CheckboxStateUnchecked];
        }
        if (fee6percent.checkState == M13CheckboxStateChecked)
        {
            [self checkFee6Percent:fee6percent];
            [fee6percent setCheckState:M13CheckboxStateUnchecked];
        }
        if (fee9percent.checkState == M13CheckboxStateChecked)
        {
            [self checkFee9Percent:fee9percent];
            [fee9percent setCheckState:M13CheckboxStateUnchecked];
        }
        
        //set content offset to make sure text field is visible
        
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        lastScrollViewOffset = _scrollViewContainer.contentOffset;
        lastScrollViewContentInset = _scrollViewContainer.contentInset;
        lastScrollViewScrollIndicator = _scrollViewContainer.scrollIndicatorInsets;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        _scrollViewContainer.contentInset = contentInsets;
        _scrollViewContainer.scrollIndicatorInsets = contentInsets;
        
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
            [_scrollViewContainer scrollRectToVisible:activeField.frame animated:YES];
        }
    }
    else
    {
        if (activeField == _addressTextField)
        {
            //set content offset for address text field to make sure there is enought space on screen for suggestion table
            
            NSDictionary* info = [aNotification userInfo];
            CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
            
            lastScrollViewOffset = _scrollViewContainer.contentOffset;
            lastScrollViewContentInset = _scrollViewContainer.contentInset;
            lastScrollViewScrollIndicator = _scrollViewContainer.scrollIndicatorInsets;
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height +120, 0.0);
            _scrollViewContainer.contentInset = contentInsets;
            _scrollViewContainer.scrollIndicatorInsets = contentInsets;
            

            
        }
        else
        {
            //setting content offset for the second scroll view
            NSDictionary* info = [aNotification userInfo];
            CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
            
            lastScrollViewOffset = _secondScrollViewContainer.contentOffset;
            lastScrollViewContentInset = _secondScrollViewContainer.contentInset;
            lastScrollViewScrollIndicator = _secondScrollViewContainer.scrollIndicatorInsets;
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
            _secondScrollViewContainer.contentInset = contentInsets;
            _secondScrollViewContainer.scrollIndicatorInsets = contentInsets;
            
            CGRect aRect = self.view.frame;
            aRect.size.height -= kbSize.height;
            if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
                [_secondScrollViewContainer scrollRectToVisible:activeField.frame animated:YES];
            }
        }
    }

}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //reset the content offset to the correct scrollview
    
    if (self.scrollViewContainer.frame.origin.x==0)
    {
        _scrollViewContainer.contentInset = lastScrollViewContentInset;
        _scrollViewContainer.scrollIndicatorInsets = lastScrollViewScrollIndicator;
        
        [_scrollViewContainer setContentOffset:lastScrollViewOffset animated:YES];
    }
    else
    {
        _secondScrollViewContainer.contentInset = lastScrollViewContentInset;
        _secondScrollViewContainer.scrollIndicatorInsets = lastScrollViewScrollIndicator;
        
        [_secondScrollViewContainer setContentOffset:lastScrollViewOffset animated:YES];
    }
}

-(void)tapToDismiss
{
    if (!locationAutocomplete.visible)
    {
        [self dismissKeyboard];
    }
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    if(!locationAutocomplete)
    {
        
        //configure the autocomplete view
        
        locationAutocomplete = [TRAutocompleteView autocompleteViewBindedTo:_addressTextField
                                                                usingSource:[[TRGoogleMapsAutocompleteItemsSource alloc] initWithMinimumCharactersToTrigger:2 apiKey:GoogleMapsApiKey]
                                                                cellFactory:[[TRGoogleMapsAutocompletionCellFactory alloc] initWithCellForegroundColor:[UIColor lightGrayColor] fontSize:14]
                                                               presentingIn:self];
        locationAutocomplete.delegate = self;
    }


}

- (void)openFullScreenMap
{
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyboard];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeField = textField;
    return YES;
}

#pragma mark - UITextView delegate methods

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    [self dismissKeyboard];
    return YES;
}

#pragma mark - UIPicker delegate methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return apartmentTypes.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [apartmentTypes[row] displayName];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    PickerData *data = apartmentTypes[row];
    _typeTF.text = data.displayName;
    _apartmentType = [data.value integerValue];
    [self.view endEditing:YES];
}

#pragma mark - AssetsPicker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    _apartmentImages = assets;
    
    NSString *selectedText;
    if(assets.count == 1)
        selectedText = @"1 image";
    else
        selectedText = [NSString stringWithFormat:@"%lu images", (unsigned long)assets.count];
    
    [_addImagesButton setTitle:selectedText forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - datepicker
-(IBAction)dateIsChanged:(id)sender
{
    leaseExpirationDate=datePicker.date;
    
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"MMMM"];
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"d"];
    
    [self.monthButton setTitle:[monthFormatter stringFromDate:datePicker.date] forState:UIControlStateNormal] ;
    [self.dayButton setTitle:[dayFormatter stringFromDate:datePicker.date] forState:UIControlStateNormal];
}

#pragma mark - Buttons actions

-(IBAction)dateDropDownTapped:(id)sender
{
    if (!datePicker)
    {
        datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, self.dayButton.frame.origin.y-216, wScr, 216)];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [datePicker setMinimumDate:[NSDate date]];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setYear:1];
        [datePicker setMaximumDate:[gregorian dateByAddingComponents:dateComponents toDate:[NSDate date] options:0]];
        [datePicker setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
        [datePicker addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
        [self.scrollViewContainer addSubview:datePicker];
    }
    else
    {
        [datePicker removeFromSuperview];
        datePicker=nil;
    }

}

-(IBAction)backArrowTapped:(id)sender
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect centerFrame = self.view.frame;
                         CGRect rightFrame = centerFrame;
                         rightFrame.origin.x = rightFrame.size.width;
                         
                         [self.secondScrollViewContainer setFrame:rightFrame];
                         [self.scrollViewContainer setFrame:centerFrame];
                         
                     }
                     completion:^(BOOL finished) {
                         for (NSLayoutConstraint* constraint in self.view.constraints)
                         {
                             if (constraint.firstItem == self.scrollViewContainer && constraint.firstAttribute == NSLayoutAttributeLeading)
                             {
                                 constraint.constant=0;
                             }
                             if (constraint.secondItem == self.scrollViewContainer && constraint.secondAttribute == NSLayoutAttributeTrailing)
                             {
                                 constraint.constant=0;
                             }
                             if (constraint.firstItem == self.secondScrollViewContainer && constraint.firstAttribute == NSLayoutAttributeLeading)
                             {
                                 constraint.constant=wScr;
                             }
                             if (constraint.secondItem == self.secondScrollViewContainer && constraint.secondAttribute == NSLayoutAttributeTrailing)
                             {
                                 constraint.constant=-wScr;
                             }
                         }
                     }];
    [self dismissKeyboard];
}

-(IBAction)dismissSelf:(id)sender
{

    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}

-(IBAction)almostDoneButtonTapped:(id)sender
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect centerFrame = self.view.frame;
                         CGRect leftFrame = centerFrame;
                         leftFrame.origin.x = -leftFrame.size.width;
                         
                         [self.secondScrollViewContainer setFrame:centerFrame];
                         [self.scrollViewContainer setFrame:leftFrame];
                         
    }
                     completion:^(BOOL finished) {
                    
                         for (NSLayoutConstraint* constraint in self.view.constraints)
                         {
                             if (constraint.firstItem == self.scrollViewContainer && constraint.firstAttribute == NSLayoutAttributeLeading)
                             {
                                 constraint.constant=-wScr;
                             }
                             if (constraint.secondItem == self.scrollViewContainer && constraint.secondAttribute == NSLayoutAttributeTrailing)
                             {
                                 constraint.constant=wScr;
                             }
                             if (constraint.firstItem == self.secondScrollViewContainer && constraint.firstAttribute == NSLayoutAttributeLeading)
                             {
                                 constraint.constant=0;
                             }
                             if (constraint.secondItem == self.secondScrollViewContainer && constraint.secondAttribute == NSLayoutAttributeTrailing)
                             {
                                 constraint.constant=0;
                             }
                         }
                         [self.secondScrollViewContainer setContentSize:CGSizeMake(wScr, 450)];

    }];
    [self dismissKeyboard];
}

- (IBAction)addImages:(id)sender
{
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.title = @"Select Images";
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)selectOwner:(id)sender
{
//    [self.navigationController pushViewController:[SelectUserTableViewController new] animated:YES];
}
- (IBAction)addApartment:(id)sender
{
    if (self.apartment)
    {
        if(![_apartment.apartment[@"visible"] boolValue])
            [DEP.api.apartmentApi makeApartmentLive:_apartment.apartment completion:^(BOOL succeeded) {
                
                [self.addApartmentBtn setTitle:@"UNFLIP" forState:UIControlStateNormal];

            }];
        else
            [DEP.api.apartmentApi hideLiveApartment:_apartment.apartment completion:^(BOOL succeeded) {
                
                [self.addApartmentBtn setTitle:@"FLIP" forState:UIControlStateNormal];

            }];
        
        return;
    }
    if([self validateFields])
    {
        if (![self.otherAmountTextField.text isEqualToString:@""] && [fee count]>0)
        {
            [fee addObject:@FeeOtherpercent];
        }
        CLLocation* location = [[CLLocation alloc] initWithLatitude:_apartmentLocation.latitude longitude:_apartmentLocation.longitude];
        [[CLGeocoder new] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
           
            NSString* neighborhood = @"";
            NSString* city = @"";
            NSString* state = @"";
            NSString* zipCode = @"";

            
            CLPlacemark* placemark = (CLPlacemark*) [placemarks firstObject];
            
            if (placemark.subLocality)
            {
                neighborhood = placemark.subLocality;
            }
            if (placemark.locality)
            {
                city = placemark.locality;
            }
            if (placemark.postalCode)
            {
                zipCode = placemark.postalCode;
            }
            if (placemark.country && [placemark.country isEqualToString:@"United States"])
            {
                state = [GeneralUtils stateAbbreviationForState: placemark.administrativeArea];
            }
            
            NSMutableDictionary *apartmentInfo = [NSMutableDictionary new];
            apartmentInfo[@"location"] = [NSString stringWithFormat:@"%f|%f", _apartmentLocation.latitude, _apartmentLocation.longitude];
            apartmentInfo[@"type"] = [NSNumber numberWithInteger:0];
            apartmentInfo[@"rooms"] = rooms;
            apartmentInfo[@"fee"] = fee;
            if ([fee containsObject:@FeeOtherpercent])
            {
                apartmentInfo[@"feeOther"] = [NSNumber numberWithFloat:[self.otherAmountTextField.text floatValue]];
            }
            apartmentInfo[@"rentWillChange"] = rentWillChange;
            apartmentInfo[@"vacancy"] = vacancy;
            apartmentInfo[@"description"] = @" ";
            apartmentInfo[@"area"] = _areaTF.text;
            apartmentInfo[@"rent"] = _rentTF.text;
            apartmentInfo[@"locationName"] = _addressTextField.text;
            apartmentInfo[@"neighborhood"]=neighborhood;
            apartmentInfo[@"city"]=city;
            apartmentInfo[@"state"]=state;
            apartmentInfo[@"zipcode"]=zipCode;
            
            NSDate* renewaldate = [NSDate date];
            NSDateComponents* days = [[NSDateComponents alloc] init];
            NSDate* fromDate = [NSDate date];
            NSDate* toDate = leaseExpirationDate;
            
            NSUInteger unitFlags = NSDayCalendarUnit;
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            days = [calendar components:unitFlags fromDate:fromDate toDate:toDate options:0];
            
            renewaldate = [[NSCalendar currentCalendar] dateByAddingComponents:days toDate:renewaldate options:0];
            
            apartmentInfo[@"renewalTimestamp"]=[NSNumber numberWithLong:(long)[renewaldate timeIntervalSince1970]];
            
            [DEP.api.apartmentApi saveApartment:apartmentInfo
                                         images:_apartmentImages
                                        forUser:_apartmentOwner
                                     completion:^(BOOL succes) {
                                         
                                         if(succes)
                                         {
                                             
                                             [UIAlertView showWithTitle:@""
                                                                message:@"Apartment has been saved!"
                                                                  style:UIAlertViewStyleDefault
                                                      cancelButtonTitle:nil otherButtonTitles:@[@"Ok"]
                                                               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                   [self dismissViewControllerAnimated:YES completion:^{
                                                                       [self.delegate addApartmentFinieshedWithChanges:YES];
                                                                   }];
                                                               }];
                                             
                                         }
                                         else
                                             [UIAlertView showWithTitle:@"" message:@"An error occurred. Please try again!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
                                     }];
            

                
            }];
    }
}

- (BOOL)validateFields
{
    if(!CLLocationCoordinate2DIsValid(_apartmentLocation))
    {
        [UIAlertView showWithTitle:@"" message:@"Select location!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
//    if(_apartmentType < 0)
//    {
//        [UIAlertView showWithTitle:@"" message:@"Select type!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
//        return NO;
//    }
    
//    if(_roomsTextView.text.length == 0)
//    {
//        [UIAlertView showWithTitle:@"" message:@"Enter rooms description!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
//        return NO;
//    }
    
//    if(type.count == 0)
//    {
//        [UIAlertView showWithTitle:@"" message:@"Select type!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
//        return NO;
//    }
    
    if(rooms.count == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Select your room components!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(fee.count == 0 && [self.otherAmountTextField.text isEqualToString:@""])
    {
        [UIAlertView showWithTitle:@"" message:@"Select your fee!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
//    if(rentWillChange.count == 0)
//    {
//        [UIAlertView showWithTitle:@"" message:@"Select whether or not your rent will change!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
//        return NO;
//    }
    
    if(vacancy.count == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Select vacancy!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
//    if(_descriptionTextView.text.length == 0)
//    {
//        [UIAlertView showWithTitle:@"" message:@"Enter apartment's description!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
//        return NO;
//    }
    
    if(_areaTF.text.length == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Enter apartment's area!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
//    if(_daysRenewalTF.text.length == 0)
//    {
//        [UIAlertView showWithTitle:@"" message:@"You must specify the remaining days until renewal!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
//        return NO;
//    }
    
    if(_rentTF.text.length == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"You must specify the rent value for the apartment!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(_apartmentImages.count == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"You must upload at least one image!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    
    
    
    return YES;
}

-(void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Checkbox handlers

- (void)checkStudio:(M13Checkbox *)checkbox
{
    bedroom1.checkState = M13CheckboxStateUnchecked;
    bedroom2.checkState = M13CheckboxStateUnchecked;
    bedroom3.checkState = M13CheckboxStateUnchecked;
    bedroom4.checkState = M13CheckboxStateUnchecked;
    
    [rooms removeObject:@Bedroom1];
    [rooms removeObject:@Bedrooms2];
    [rooms removeObject:@Bedrooms3];
    [rooms removeObject:@Bedrooms4];
    
    if(checkbox.checkState == M13CheckboxStateChecked)
    {
        if (![rooms containsObject:@Studio])
            [rooms addObject:@Studio];
    }
    else
        [rooms removeObject:@Studio];
}

- (void)check1Bedroom:(M13Checkbox *)checkbox
{
    studioRoom.checkState = M13CheckboxStateUnchecked;
    bedroom2.checkState = M13CheckboxStateUnchecked;
    bedroom3.checkState = M13CheckboxStateUnchecked;
    bedroom4.checkState = M13CheckboxStateUnchecked;
    
    [rooms removeObject:@Studio];
    [rooms removeObject:@Bedrooms2];
    [rooms removeObject:@Bedrooms3];
    [rooms removeObject:@Bedrooms4];
    
    if(bedroom1.checkState == M13CheckboxStateChecked)
    {
        if (![rooms containsObject:@Bedroom1])
            [rooms addObject:@Bedroom1];
    }
    else
        [rooms removeObject:@Bedroom1];
}

- (void)check2Bedrooms:(M13Checkbox *)checkbox
{
    studioRoom.checkState = M13CheckboxStateUnchecked;
    bedroom1.checkState = M13CheckboxStateUnchecked;
    bedroom3.checkState = M13CheckboxStateUnchecked;
    bedroom4.checkState = M13CheckboxStateUnchecked;
    
    [rooms removeObject:@Studio];
    [rooms removeObject:@Bedroom1];
    [rooms removeObject:@Bedrooms3];
    [rooms removeObject:@Bedrooms4];
    
    if(bedroom2.checkState == M13CheckboxStateChecked)
    {
        if (![rooms containsObject:@Bedrooms2])
            [rooms addObject:@Bedrooms2];
    }
    else
        [rooms removeObject:@Bedrooms2];
}

- (void)check3Bedrooms:(M13Checkbox *)checkbox
{
    studioRoom.checkState = M13CheckboxStateUnchecked;
    bedroom1.checkState = M13CheckboxStateUnchecked;
    bedroom2.checkState = M13CheckboxStateUnchecked;
    bedroom4.checkState = M13CheckboxStateUnchecked;
    
    [rooms removeObject:@Studio];
    [rooms removeObject:@Bedroom1];
    [rooms removeObject:@Bedrooms2];
    [rooms removeObject:@Bedrooms4];
    
    if(bedroom3.checkState == M13CheckboxStateChecked)
    {
        if (![rooms containsObject:@Bedrooms3])
            [rooms addObject:@Bedrooms3];
    }
    else
        [rooms removeObject:@Bedrooms3];
}

- (void)check4Bedrooms:(M13Checkbox *)checkbox
{
    studioRoom.checkState = M13CheckboxStateUnchecked;
    bedroom1.checkState = M13CheckboxStateUnchecked;
    bedroom3.checkState = M13CheckboxStateUnchecked;
    bedroom2.checkState = M13CheckboxStateUnchecked;
    
    [rooms removeObject:@Studio];
    [rooms removeObject:@Bedroom1];
    [rooms removeObject:@Bedrooms3];
    [rooms removeObject:@Bedrooms2];
    
    if(bedroom4.checkState == M13CheckboxStateChecked)
    {
        if (![rooms containsObject:@Bedrooms4])
            [rooms addObject:@Bedrooms4];
    }
    else
        [rooms removeObject:@Bedrooms4];
}

- (void)checkVacancyImmediate:(M13Checkbox *)checkbox
{
    vacancyNegociable.checkState = M13CheckboxStateUnchecked;
    vacancyShortTerm.checkState = M13CheckboxStateUnchecked;
    
    [vacancy removeObject:@VacancyShortTerm];
    [vacancy removeObject:@VacancyFlexible];
    
    if(vacancyImmediate.checkState == M13CheckboxStateChecked)
    {
        if (![vacancy containsObject:@VacancyImmediate])
            [vacancy addObject:@VacancyImmediate];
    }
    else
        [vacancy removeObject:@VacancyImmediate];
}

- (void)checkVacancyShortTerm:(M13Checkbox *)checkbox
{
    vacancyNegociable.checkState = M13CheckboxStateUnchecked;
    vacancyImmediate.checkState = M13CheckboxStateUnchecked;
    
    [vacancy removeObject:@VacancyImmediate];
    [vacancy removeObject:@VacancyFlexible];
    
    if(vacancyShortTerm.checkState == M13CheckboxStateChecked)
    {
        if (![vacancy containsObject:@VacancyShortTerm])
            [vacancy addObject:@VacancyShortTerm];
    }
    else
        [vacancy removeObject:@VacancyShortTerm];
    
}

- (void)checkVacancyNegociable:(M13Checkbox *)checkbox
{
    vacancyShortTerm.checkState = M13CheckboxStateUnchecked;
    vacancyImmediate.checkState = M13CheckboxStateUnchecked;
    
    [vacancy removeObject:@VacancyImmediate];
    [vacancy removeObject:@VacancyShortTerm];
    
    if(vacancyNegociable.checkState == M13CheckboxStateChecked)
    {
        if (![vacancy containsObject:@VacancyFlexible])
            [vacancy addObject:@VacancyFlexible];
    }
    else
        [vacancy removeObject:@VacancyFlexible];
}
- (void)checkFee3Percent:(M13Checkbox *)checkbox
{
    fee6percent.checkState = M13CheckboxStateUnchecked;
    fee9percent.checkState = M13CheckboxStateUnchecked;
    self.otherAmountTextField.text =@"";
    
    [fee removeObject:@Fee6percent];
    [fee removeObject:@Fee9percent];
    [fee removeObject:@FeeOtherpercent];
    
    if(fee3percent.checkState == M13CheckboxStateChecked)
    {
        if (![fee containsObject:@Fee3percent])
            [fee addObject:@Fee3percent];
    }
    else
        [fee removeObject:@Fee9percent];
}
- (void)checkFee6Percent:(M13Checkbox *)checkbox
{
    fee3percent.checkState = M13CheckboxStateUnchecked;
    fee9percent.checkState = M13CheckboxStateUnchecked;
    self.otherAmountTextField.text =@"";

    [fee removeObject:@Fee3percent];
    [fee removeObject:@Fee9percent];
    [fee removeObject:@FeeOtherpercent];
    
    if(fee6percent.checkState == M13CheckboxStateChecked)
    {
        if (![fee containsObject:@Fee6percent])
            [fee addObject:@Fee6percent];
    }
    else
        [fee removeObject:@Fee6percent];
}
- (void)checkFee9Percent:(M13Checkbox *)checkbox
{
    fee6percent.checkState = M13CheckboxStateUnchecked;
    fee3percent.checkState = M13CheckboxStateUnchecked;
    self.otherAmountTextField.text =@"";
    
    [fee removeObject:@Fee6percent];
    [fee removeObject:@Fee3percent];
    [fee removeObject:@FeeOtherpercent];
    
    if(fee9percent.checkState == M13CheckboxStateChecked)
    {
        if (![fee containsObject:@Fee9percent])
            [fee addObject:@Fee9percent];
    }
    else
        [fee removeObject:@Fee9percent];
}
- (void)checkWillRentChangeYes:(M13Checkbox *)checkbox
{
    willRentChangeNo.checkState = M13CheckboxStateUnchecked;
    willRentChangeMaybe.checkState = M13CheckboxStateUnchecked;
    
    [rentWillChange removeObject:@RentWillChangeNO];
    [rentWillChange removeObject:@RentWillChangeMaybe];
    
    if(willRentChangeYes.checkState == M13CheckboxStateChecked)
    {
        if (![rentWillChange containsObject:@RentWillChangeYES])
            [rentWillChange addObject:@RentWillChangeYES];
    }
    else
        [rentWillChange removeObject:@RentWillChangeYES];
}
- (void)checkWillRentChangeNO:(M13Checkbox *)checkbox
{
    willRentChangeYes.checkState = M13CheckboxStateUnchecked;
    willRentChangeMaybe.checkState = M13CheckboxStateUnchecked;
    
    [rentWillChange removeObject:@RentWillChangeYES];
    [rentWillChange removeObject:@RentWillChangeMaybe];
    
    if(willRentChangeNo.checkState == M13CheckboxStateChecked)
    {
        if (![rentWillChange containsObject:@RentWillChangeNO])
            [rentWillChange addObject:@RentWillChangeNO];
    }
    else
        [rentWillChange removeObject:@RentWillChangeNO];
}
- (void)checkWillRentChangeMaybe:(M13Checkbox *)checkbox
{
    willRentChangeNo.checkState = M13CheckboxStateUnchecked;
    willRentChangeYes.checkState = M13CheckboxStateUnchecked;
    
    [rentWillChange removeObject:@RentWillChangeNO];
    [rentWillChange removeObject:@RentWillChangeYES];
    
    if(willRentChangeMaybe.checkState == M13CheckboxStateChecked)
    {
        if (![rentWillChange containsObject:@RentWillChangeMaybe])
            [rentWillChange addObject:@RentWillChangeMaybe];
    }
    else
        [rentWillChange removeObject:@RentWillChangeMaybe];
}

- (void)checkEntirePlace:(M13Checkbox *)checkbox
{
    typePrivateRoom.checkState = M13CheckboxStateUnchecked;
    typeRetailOrCommercial.checkState = M13CheckboxStateUnchecked;
    
    [type removeObject:@TypePrivateRoom];
    [type removeObject:@TypeRetailOrCommercial];
    
    if(typeEntirePlace.checkState == M13CheckboxStateChecked)
    {
        if (![type containsObject:@TypeEntirePlace])
            [type addObject:@TypeEntirePlace];
    }
    else
        [type removeObject:@TypeEntirePlace];
}

- (void)checkPrivateRoom:(M13Checkbox *)checkbox
{
    typeEntirePlace.checkState = M13CheckboxStateUnchecked;
    typeRetailOrCommercial.checkState = M13CheckboxStateUnchecked;
    
    [type removeObject:@TypeEntirePlace];
    [type removeObject:@TypeRetailOrCommercial];
    
    if(typePrivateRoom.checkState == M13CheckboxStateChecked)
    {
        if (![type containsObject:@TypePrivateRoom])
            [type addObject:@TypePrivateRoom];
    }
    else
        [type removeObject:@TypePrivateRoom];
}

- (void)checkRetailOrCommercial:(M13Checkbox *)checkbox
{
    typeEntirePlace.checkState = M13CheckboxStateUnchecked;
    typePrivateRoom.checkState = M13CheckboxStateUnchecked;
    
    [type removeObject:@TypeEntirePlace];
    [type removeObject:@TypePrivateRoom];
    
    if(typeRetailOrCommercial.checkState == M13CheckboxStateChecked)
    {
        if (![type containsObject:@TypeRetailOrCommercial])
            [type addObject:@TypeRetailOrCommercial];
    }
    else
        [type removeObject:@TypeRetailOrCommercial];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
