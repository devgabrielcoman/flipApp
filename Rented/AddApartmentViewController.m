//
//  AddApartmentViewController.m
//  RentedAddApartment
//
//  Created by Lucian Gherghel on 30/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "AddApartmentViewController.h"
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
#import "CongratulationsViewController.h"
#import "UnflipedViewController.h"
#import "MBProgressHUD.h"
#import "EnterDetailsViewController.h"
#import "AppDelegate.h"
#import "RentedPanelController.h"
#import "DashboardViewController.h"
#import "ApartmentDetailsOtherListingView.h"
#import "FullMapViewViewController.h"



//set left text field inset
@implementation UITextField (custom)
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 8, bounds.origin.y,
                      bounds.size.width - 16, bounds.size.height);
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
    
    UIView *activeField;
    CGPoint lastScrollViewOffset;
    UIEdgeInsets lastScrollViewContentInset;
    UIEdgeInsets lastScrollViewScrollIndicator;
    
    NSDate* leaseExpirationDate;

    
    NSMutableArray *rooms;
    NSMutableArray *vacancy;
    NSMutableArray *fee;
    NSMutableArray *rentWillChange;
    NSMutableArray *type;
    
    NSInteger contactDirectly;
    NSInteger visible;
    NSInteger hideFacebookProfile;
    
    UIDatePicker* datePicker;
    
    BOOL imagesHaveChangedInEditMode;
    
    MKPointAnnotation *currentAnnotation;
    TRAutocompleteView *locationAutocomplete;

    NSString* locationName;
    

}
@property (weak, nonatomic) IBOutlet UIButton *vacancyLongTerm;
@property (weak, nonatomic) IBOutlet UIButton *vacancyShortTerm;
@property (weak, nonatomic) IBOutlet UIButton *vacancyFlexible;

@property (weak, nonatomic) IBOutlet UIButton *fee3percent;
@property (weak, nonatomic) IBOutlet UIButton *fee6percent;
@property (weak, nonatomic) IBOutlet UIButton *fee9percent;

@property (weak, nonatomic) IBOutlet UIButton *typeEntirePlace;
@property (weak, nonatomic) IBOutlet UIButton *typePrivateRoom;
@property (weak, nonatomic) IBOutlet UIButton *typeRetailOrCommercial;

@property (weak, nonatomic) IBOutlet UIButton *leaseRenewalButton;
@property (weak, nonatomic) IBOutlet UIButton *numberOfBedroomsButton;

@property (weak, nonatomic) IBOutlet UIView *leaseRenewalContainer;
@property (weak, nonatomic) IBOutlet UIView *numberOfBedroomsContainer;

@property (weak, nonatomic) IBOutlet UIPickerView *numberOfBedroomsPicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *leaseRenewalPicker;


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
@property (weak, nonatomic) IBOutlet UILabel *vacancyLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIButton *monthButton;
@property (weak, nonatomic) IBOutlet UIButton *dayButton;
@property (weak, nonatomic) IBOutlet UIPickerView *hourPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *dayPicker;
@property (weak, nonatomic) IBOutlet UIButton *hoursButton;
@property (weak, nonatomic) IBOutlet UIButton *daysButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel    *rentLabel;
@property (weak, nonatomic) IBOutlet UILabel    *feeLabel;





@end

@implementation AddApartmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.profileImageView setShowActivityIndicator:YES];
    [self.profileImageView setImageURL:[NSURL URLWithString:[PFUser currentUser][@"profilePictureUrl"]]];
    
    [self.ownerLabel setText:[NSString stringWithFormat:@"%@'s\rListing",[PFUser currentUser][@"firstName"]]];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    
    [self.profileImageView.layer setBorderWidth:2];
    [self.profileImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [self.entirePlaceButton.titleLabel setNumberOfLines:2];
    [self.privateRoomButton.titleLabel setNumberOfLines:2];
    
    [self.entirePlaceButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.privateRoomButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    self.propertyType = -1;
    self.listingType =-1;
    self.carousel.bounceDistance = 0.35;
    self.carousel.scrollSpeed = 0.6;

    UITapGestureRecognizer* rentGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(rentTapped:)];
    [self.rentTouchContainer addGestureRecognizer:rentGestureRecognizer];
    [self.rentTextField setDelegate:self];
    
    UITapGestureRecognizer* feeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(feeTapped:)];
    [self.feeTouchContainer addGestureRecognizer:feeGestureRecognizer];
    [self.feeTextField setDelegate:self];
    
    UITapGestureRecognizer* messageGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(messageTapped:)];
    [self.messageContainer addGestureRecognizer:messageGestureRecognizer];
    
    UITapGestureRecognizer* leaseDetailsGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(detailsTapped:)];
    [self.leaseDetailsContainer addGestureRecognizer:leaseDetailsGestureRecognizer];
    
    UITapGestureRecognizer* mapViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(listingAddressButtonTapped:)];
    [self.mapView addGestureRecognizer:mapViewGestureRecognizer];
    
    UITapGestureRecognizer* addressLabelGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(listingAddressButtonTapped:)];
    [self.addressLabel addGestureRecognizer:addressLabelGestureRecognizer];

    
    //configure views
//    
//    [self.addApartmentBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47a0db"]] forState:UIControlStateNormal];
//
//    
//
//    
//    _areaTF.delegate = self;
//    _rentTF.delegate = self;
//    _descriptionTextView.delegate = self;
//
//    
//
//
//    _descriptionTextView.delegate = self;
//    _descriptionTextView.returnKeyType = UIReturnKeyDefault;
//    
//    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
//    [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [nextButton setBackgroundColor:[UIColor whiteColor]];
//    [nextButton addTarget:self action:@selector(enterRent) forControlEvents:UIControlEventTouchUpInside];
//    
//
//    _areaTF.inputAccessoryView = nextButton;
//
//    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
//    [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [doneButton setBackgroundColor:[UIColor whiteColor]];
//    [doneButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
//    
//    _rentTF.inputAccessoryView = doneButton;
//    _descriptionTextView.inputAccessoryView = doneButton;
//
//    UITapGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismiss)];
//    dismissGesture.numberOfTapsRequired = 1;
//    dismissGesture.numberOfTouchesRequired = 1;
//    dismissGesture.cancelsTouchesInView = NO;
//    [self.view addGestureRecognizer:dismissGesture];
//    
//    
//    _apartmentLocation = kCLLocationCoordinate2DInvalid;
//    
//    apartmentTypePicker = [UIPickerView new];
//    apartmentTypePicker.delegate = self;
//    apartmentTypePicker.dataSource = self;
//    _typeTF.inputView = apartmentTypePicker;
//    
//    [self registerForKeyboardNotifications];

    _apartmentType = -1;
    
    
    rooms = [NSMutableArray new];
    
    vacancy = [NSMutableArray new];
    
    fee = [NSMutableArray new];
    
    rentWillChange = [NSMutableArray new];
    
    _apartmentOwner=[PFUser currentUser];
    
    
    contactDirectly=1;

    if(self.apartment)
    {
        [self customiseViews];
    }
    else
    {
        self.noApartmentOnEntry = YES;
        [[Mixpanel sharedInstance] timeEvent:@"Did Not Create Apartment"];
        [self loadAutoSave];
    }
        
    
    UIButton* previewButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [previewButton setFrame:CGRectMake(0, 0, 67, 30)];
    [previewButton setTitle:@"Preview" forState:UIControlStateNormal];
    [previewButton addTarget:self action:@selector(showPreview:) forControlEvents:UIControlEventTouchUpInside];
    [previewButton.titleLabel setFont:[UIFont fontWithName:@"HelveticeNeue-Medium" size:17.0]];

    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:previewButton], nil]];
 
    
    
//    //using view controller in edit mode
//    if(self.apartment)
//    {
//        UIButton* saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [saveButton setFrame:CGRectMake(0, 0, 80, 40)];
//        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
//        [saveButton addTarget:self action:@selector(saveChanges:) forControlEvents:UIControlEventTouchUpInside];
//
//        UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [deleteButton setFrame:CGRectMake(0, 0, 80, 40)];
//        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
//        [deleteButton addTarget:self action:@selector(deleteApartment:) forControlEvents:UIControlEventTouchUpInside];
//
//        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:deleteButton],[[UIBarButtonItem alloc] initWithCustomView:saveButton], nil]];
//        
//        //customise fields using the apartment's data
//        [self customiseViews];
//    }
//    else
//    {
//        [self.saveButton setHidden:YES];
//        [self.deleteButton setHidden:YES];
//
//    }
//    
//    [self.secondScrollViewContainer bringSubviewToFront:_hourPicker];
//    [self.secondScrollViewContainer bringSubviewToFront:_dayPicker];
//    

    
    

}

-(void) loadAutoSave
{
    self.autoSave = [[[NSUserDefaults standardUserDefaults] objectForKey:@"autoSave" ] mutableCopy];
    if (self.autoSave == nil)
    {
        self.autoSave = [NSMutableDictionary new];
    }
    else
    {
        if([self.autoSave valueForKey:@"imagesArray"])
        {
            NSMutableArray* imageFromDataArray=[NSMutableArray new];
            for (NSData* imageData in [self.autoSave valueForKey:@"imagesArray"])
            {
                [imageFromDataArray addObject:[UIImage imageWithData:imageData]];
            }
            [self finishedAddingPhotosWithArray:imageFromDataArray];
        }
            
        if([self.autoSave valueForKey:@"location"])
        {
            [self finishedEnteringAddress:[LocationUtils locationFromPoint:self.autoSave[@"location"]] andString:self.autoSave[@"locationName"]];
        }
        if ([self.autoSave valueForKey:@"rent"])
        {
            [self finishedEnteringValue:self.autoSave[@"rent"] forState:stateRent];
        }
        if ([self.autoSave valueForKey:@"description"])
        {
            [self finishedEnteringValue:self.autoSave[@"description"] forState:stateMessage];
        }
        
        if( [self.autoSave valueForKey:@"listingType"] )
        {
            if ([self.autoSave[@"listingType"] integerValue] ==0) {
                [self.entirePlaceButton setSelected:YES];
            }
            else
            {
                [self.privateRoomButton setSelected:YES];
            }
            
        }
    
        if( [self.autoSave valueForKey:@"propertyType"])
        {
            if ([self.autoSave[@"propertyType"] integerValue] ==0) {
                [self.apartmentButton setSelected:YES];                }
            else
            {
                [self.houseButton setSelected:YES];

            }
        }
        
        NSInteger bedrooms = [self.autoSave[@"bedrooms"] integerValue];
        [self.bedroomsSlider setValue:bedrooms animated:NO];
        [self bedroomValueChanged:self.bedroomsSlider];
        
        CGFloat bathrooms = [self.autoSave[@"bathrooms"] floatValue];
        [self.bathroomsSlider setValue:bathrooms animated:NO];
        [self bathroomValueChanged:self.bathroomsSlider];
        
        if ([self.autoSave valueForKey:@"rent"])
        {
            [self finishedEnteringValue:self.autoSave[@"rent"] forState:stateRent];
        }
        if ([self.autoSave valueForKey:@"fee"])
        {
            [self finishedEnteringValue:self.autoSave[@"fee"] forState:stateFee];
        }
        if ([self.autoSave valueForKey:@"description"])
        {
            [self finishedEnteringValue:self.autoSave[@"description"] forState:stateMessage];
        }
        
        if ([self.autoSave valueForKey:@"option"])
        {
            [self finishedEnteringLeaeDetailsWithOption:[self.autoSave[@"option"] integerValue] date1:self.autoSave[@"date1"] date2:self.autoSave[@"date2"]];
        }
        
    }
    
    [self.contactDirectlySwitch setOn:[self.autoSave[@"contactDirectly"] boolValue]];
    contactDirectly=[self.autoSave[@"contactDirectly"] integerValue];
    
    [self.visibleSwitch setOn:[self.autoSave[@"visible"] boolValue]];
    visible=[self.autoSave[@"visible"] integerValue];

    [self.hideFacebookProfileSwitch setOn:[self.autoSave[@"hideFacebookProfile"] boolValue]];
    hideFacebookProfile=[self.autoSave[@"hideFacebookProfile"] integerValue];
    
}

-(void)enterRent
{
    [_areaTF resignFirstResponder];
    [_rentTF becomeFirstResponder];
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

    [super viewWillLayoutSubviews];

}

-(void)customiseViews
{
    
    //used in edit mode to customise the selected apartment
    self.apartmentLocation=[LocationUtils locationFromPoint:_apartment.apartment[@"location"]];
    self.locationName=_apartment.apartment[@"locationName"];

    [self finishedAddingPhotosWithArray:self.apartment.images];
    imagesHaveChangedInEditMode=NO;
    [self finishedEnteringAddress:[LocationUtils locationFromPoint:_apartment.apartment[@"location"]] andString:_apartment.apartment[@"locationName"]];

    NSDate*date1=[NSDate dateWithTimeIntervalSince1970:[self.apartment.apartment[@"moveOutTimestamp"] longValue]];
    NSDate*date2=[NSDate dateWithTimeIntervalSince1970:[self.apartment.apartment[@"renewalTimestamp"] longValue]];
    
    [self finishedEnteringLeaeDetailsWithOption:[self.apartment.apartment[@"moveOutOption"]intValue] date1:date1 date2:date2];
    
    NSString* rentString = [NSString stringWithFormat:@"$%d",[self.apartment.apartment[@"rent"]intValue]];
    
    if (rentString.length>4)
    {
        
        if (rentString.length==5)
        {
            rentString =[NSString stringWithFormat:@"%@,%@",[rentString substringToIndex:2],[rentString substringFromIndex:2]];
        }
        else if (rentString.length==6)
        {
            rentString =[NSString stringWithFormat:@"%@,%@",[rentString substringToIndex:3],[rentString substringFromIndex:3]];
        }
        else if (rentString.length==7)
        {
            rentString =[NSString stringWithFormat:@"%@,%@",[rentString substringToIndex:4],[rentString substringFromIndex:4]];
        }
    }
    [self finishedEnteringValue:rentString forState:stateRent];
    
    NSString* feeString = [NSString stringWithFormat:@"$%d",[self.apartment.apartment[@"fee"]intValue]];
    
    if (feeString.length>4)
    {
        
        if (feeString.length==5)
        {
            feeString =[NSString stringWithFormat:@"%@,%@",[feeString substringToIndex:2],[feeString substringFromIndex:2]];
        }
        else if (rentString.length==6)
        {
            feeString =[NSString stringWithFormat:@"%@,%@",[feeString substringToIndex:3],[feeString substringFromIndex:3]];
        }
        else if (rentString.length==7)
        {
            feeString =[NSString stringWithFormat:@"%@,%@",[feeString substringToIndex:4],[feeString substringFromIndex:4]];
        }
    }
    [self finishedEnteringValue:feeString forState:stateFee];
    
    [self finishedEnteringValue:self.apartment.apartment[@"description"] forState:stateMessage];
    
    NSInteger bedrooms = [self.apartment.apartment[@"bedrooms"] integerValue];
    [self.bedroomsSlider setValue:bedrooms animated:NO];
    [self bedroomValueChanged:self.bedroomsSlider];
    
    CGFloat bathrooms = [self.apartment.apartment[@"bathrooms"] floatValue];
    [self.bathroomsSlider setValue:bathrooms animated:NO];
    [self bathroomValueChanged:self.bathroomsSlider];
    
    if ([self.apartment.apartment[@"listingType"] integerValue]==TypeEntirePlace)
    {
        [self.entirePlaceButton setSelected:YES];
    }
    else
    {
        [self.privateRoomButton setSelected:YES];
    }
    if ([self.apartment.apartment[@"propertyType"] integerValue]==TypeApartment)
    {
        [self.apartmentButton setSelected:YES];
    }
    else
    {
        [self.houseButton setSelected:YES];
    }
    [self.contactDirectlySwitch setOn:[_apartment.apartment[@"directContact"] boolValue]];
    contactDirectly=[_apartment.apartment[@"directContact"] integerValue];
    
    [self.visibleSwitch setOn:[_apartment.apartment[@"visible"] boolValue]];
    visible=[_apartment.apartment[@"visible"] integerValue];
    
    [self.hideFacebookProfileSwitch setOn:[_apartment.apartment[@"hideFacebookProfile"] boolValue]];
    hideFacebookProfile=[_apartment.apartment[@"hideFacebookProfile"] integerValue];
    
    [self.publishListingButton setTitle:@"Save Listing" forState:UIControlStateNormal];

    [self.titleLabel setText:@"My Listing"];
    
    _apartmentImages = _apartment.images;
    
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

    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    lastScrollViewOffset = _scrollViewContainer.contentOffset;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(20.0, 0.0, kbSize.height, 0.0);
    _scrollViewContainer.contentInset = contentInsets;
    _scrollViewContainer.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [_scrollViewContainer scrollRectToVisible:activeField.frame animated:YES];
    }

}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //reset the content offset to the correct scrollview

    _scrollViewContainer.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    _scrollViewContainer.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    
    [_scrollViewContainer setContentOffset:lastScrollViewOffset animated:YES];
    

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

-(void)viewWillDisappear:(BOOL)animated
{
    if (self.noApartmentOnEntry && !self.createdApartment)
    {
        
        NSMutableDictionary* properties =[NSMutableDictionary new];
        
        if(self.imagesArray.count == 0)
        {
            properties[@"Added Photos"]=@"0";
        }
        else
        {
            properties[@"Added Photos"]=@"1";
        }
        if(self.locationName.length == 0)
        {
            properties[@"Added Address"]=@"0";
        }
        else
        {
            properties[@"Added Address"]=@"1";
        }
        
        if(!self.entirePlaceButton.selected && !self.privateRoomButton.selected)
        {
            properties[@"Added Listing Type"]=@"0";
        }
        else
        {
            properties[@"Added Listing Type"]=@"1";
        }
        if(!self.apartmentButton.selected && !self.houseButton.selected)
        {
            properties[@"Added Property Type"]=@"0";
        }
        else
        {
            properties[@"Added Property Type"]=@"1";
        }
        if(self.rentTextField.text.length == 0)
        {
            properties[@"Added Rent"]=@"0";
        }
        else
        {
            properties[@"Added Rent"]=@"1";
        }
        if(self.feeTextField.text.length == 0)
        {
            properties[@"Added Price"]=@"0";
        }
        else
        {
            properties[@"Added Price"]=@"1";
        }
        
        if(self.descriptionTextView.text.length ==0)
        {
            properties[@"Added Description"]=@"0";
        }
        else
        {
            properties[@"Added Description"]=@"1";
        }
        
        if(self.date2 ==nil)
        {
            properties[@"Added Lease Details"]=@"0";
        }
        else
        {
            properties[@"Added Lease Details"]=@"1";
        }


        [[Mixpanel sharedInstance] track:@"Did Not Create Apartment" properties:properties];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:self.autoSave forKey:@"autoSave"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)openFullScreenMap
{
}

#pragma mark - UITextField delegate methods
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [self dismissKeyboard];
//    return YES;
//}
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    activeField = textField;
//    return YES;
//}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}


//#pragma mark - UITextView delegate methods

//-(void)textViewDidBeginEditing:(UITextView *)textView
//{
//
//    activeField = textView;
//    
//}
//- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
////    [self dismissKeyboard];
//    return YES;
//}

#pragma mark - UIPicker delegate methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 6;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row) {
        case 0:
                return @" ";
            break;
        case 1:
                return @"Studio";
            break;
        case 2:
                return @"1 Bedroom";
            break;
        case 3:
                return @"2 Bedrooms";
            break;
        case 4:
                return @"3 Bedrooms";
            break;
        case 5:
                return @"4 Bedrooms";
            break;
        default:
            break;
    }
    return nil;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
                [self.numberOfBedroomsButton setTitle:@"# Bedrooms" forState:UIControlStateNormal];
            break;
        case 1:
                [self.numberOfBedroomsButton setTitle:@"Studio" forState:UIControlStateNormal];
            break;
        case 2:
                [self.numberOfBedroomsButton setTitle:@"1 Bedroom" forState:UIControlStateNormal];
            break;
        case 3:
                [self.numberOfBedroomsButton setTitle:@"2 Bedrooms" forState:UIControlStateNormal];
            break;
        case 4:
                [self.numberOfBedroomsButton setTitle:@"3 Bedrooms" forState:UIControlStateNormal];
            break;
        case 5:
                [self.numberOfBedroomsButton setTitle:@"4 Bedrooms" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - picker methods

-(IBAction)leaseRenewalButonTapped:(id)sender
{
    if([self.leaseRenewalContainer isHidden])
    {
        [self showLeaseRenewalContainer];
    }
    else
    {
        [self hideLeaseRenewalContainer];
    }
}
-(IBAction)numberOfBedroomsTapped:(id)sender
{
    if([self.numberOfBedroomsContainer isHidden])
    {
        [self showNumberOfBedroomsContainer];
    }
    else
    {
        [self hideNumberOfBedroomsContainer];
    }
}

-(IBAction)showLeaseRenewalContainer
{
    [self.numberOfBedroomsContainer setHidden:YES];
    [self.leaseRenewalContainer setHidden:NO];
}
-(IBAction)hideLeaseRenewalContainer
{
    [self.numberOfBedroomsContainer setHidden:YES];
    [self.leaseRenewalContainer setHidden:YES];
}
-(IBAction)showNumberOfBedroomsContainer
{
    [self.numberOfBedroomsContainer setHidden:NO];
    [self.leaseRenewalContainer setHidden:YES];
}
-(IBAction)hideNumberOfBedroomsContainer
{
    [self.numberOfBedroomsContainer setHidden:YES];
    [self.leaseRenewalContainer setHidden:YES];
}

#pragma mark - AssetsPicker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    imagesHaveChangedInEditMode =YES;
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
    leaseExpirationDate=self.leaseRenewalPicker.date;
    
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"MMMM"];
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"d"];
    
    
    NSString* monthString=[monthFormatter stringFromDate:self.leaseRenewalPicker.date];
    NSString* dayString=[dayFormatter stringFromDate:self.leaseRenewalPicker.date];
    [self.leaseRenewalButton setTitle:[NSString stringWithFormat:@"%@/%@",monthString,dayString] forState:UIControlStateNormal] ;
}
#pragma mark - Enter Lease Details ViewController delegate

-(void)finishedEnteringLeaeDetailsWithOption:(NSInteger)option date1:(NSDate *)date1 date2:(NSDate *)date2
{
    self.leaveApartmentOption= option;
    [self.autoSave setValue:[NSNumber numberWithInteger:option] forKey:@"option"];
    self.date1= date1;
    [self.autoSave setValue:date1 forKey:@"date1"];
    self.date2= date2;
    [self.autoSave setValue:date2 forKey:@"date2"];
    
    [self.moveOutDateLabelUnselected setHidden:YES];
    [self.leaseEndDateLabelUnselected setHidden:YES];
    
    [self.moveOutDateLabelSelected setHidden:NO];
    [self.moveOutDateLabel setHidden:NO];
    
    [self.leaseEndDateLabelSelected setHidden:NO];
    [self.leaseEndDateLabel setHidden:NO];
    
    if(option==0)
    {
        [self.moveOutDateLabel setText:@"Immediately"];
    }
    else if(option ==1)
    {
        [self.moveOutDateLabel setText:@"Flexible"];
    }
    else
    {
        NSDateFormatter* formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MMM d, YYYY"];
        [self.moveOutDateLabel setText:[formatter stringFromDate:date1]];
    }
    
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMM d, YYYY"];
    [self.leaseEndDateLabel setText:[formatter stringFromDate:date2]];
}


#pragma mark - Enter Address ViewController delegate

-(void)finishedEnteringAddress:(CLLocationCoordinate2D)location andString:(NSString *)string
{
    self.locationName = string;
    [self.autoSave setValue:string forKey:@"locationName"];
    self.apartmentLocation = location;
    [self.autoSave setValue:[NSString stringWithFormat:@"%f|%f", location.latitude, location.longitude] forKey:@"location"];
    CLLocation* apLocation = [[CLLocation alloc] initWithLatitude:_apartmentLocation.latitude longitude:_apartmentLocation.longitude];
    [[CLGeocoder new] reverseGeocodeLocation:apLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        NSString* neighborhood = @" ";
        NSString* city = @" ";
        NSString* state = @" ";
        NSString* zipCode = @" ";
        
        
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
        
        if (![neighborhood isEqualToString:@" "] && ![city isEqualToString:@" "])
        {
            [self.addressLabel setText:[NSString stringWithFormat:@"%@, %@",neighborhood, city]];
        }
        else
        {
            [self.addressLabel setText:[NSString stringWithFormat:@"%@, %@",city, placemark.country]];

        }
        
        [self.addressLabel setHidden:NO];
        
    }];
    
    MKCoordinateRegion mapRegion = MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.005, 0.005));
    [self.mapView setRegion:mapRegion animated:NO];
    
    [self.listingAddressBackgroundView setHidden:YES];
    [self.listingAddressButton setHidden:YES];
    [self.mapView setHidden:NO];

}

#pragma mark - Select Listing Photos ViewController delegate

-(void)finishedAddingPhotosWithArray:(NSArray *)array
{
    imagesHaveChangedInEditMode=YES;
    self.imagesArray = array;
    
    NSMutableArray* imageDataArray=[NSMutableArray new];
    if(!self.apartment)
    {
        for (UIImage* image in self.imagesArray)
        {
            [imageDataArray addObject:UIImagePNGRepresentation(image)];
        }
        [self.autoSave setObject:imageDataArray forKey:@"imagesArray"];
    }
    if (self.imagesArray.count>0)
    {
        [self.carousel setHidden:NO];
        [self.pageControl setHidden:NO];
        [self.pageControl setNumberOfPages:self.imagesArray.count];
        [self.listingPhotosButton setHidden:YES];
    }
    else
    {
        [self.carousel setHidden:YES];
        [self.pageControl setHidden:YES];
        [self.listingPhotosButton setHidden:NO];
    }

    [self.carousel reloadData];

}

#pragma mark - Enter Details ViewController delegate

-(void)finishedEnteringValue:(NSString *)value forState:(NSInteger)state
{
    switch (state)
    {
        case stateRent:
        {
            [self.rentTextField setText:value];
            NSString* rent = self.rentTextField.text;
            
            [self.autoSave setValue:value forKey:@"rent"];
            
            rent = [rent stringByReplacingOccurrencesOfString:@"$" withString:@""];
            rent = [rent stringByReplacingOccurrencesOfString:@"," withString:@""];
            NSInteger recommendedRent=[rent integerValue]* 12 *0.01;
            
            [self.recommendedFeeLabel setText:[NSString stringWithFormat:@"Recommended fee is $%d",recommendedRent]];
            break;
        }
        case stateFee:
        {
            [self.feeTextField setText:value];
            [self.autoSave setValue:value forKey:@"fee"];

            break;
        }
        case stateMessage:
        {
            [self.descriptionTextView setText:value];
            [self.autoSave setValue:value forKey:@"description"];

            [self.addMessageButton setHidden:YES];
            [self.messageBackground setHidden:YES];
            [self.messageLabel setHidden:NO];
            break;
        }
        default:
            break;
    }
}
#pragma mark - Slider actions

-(IBAction)bedroomValueChanged:(UISlider*)sender
{
    [sender setValue:(int)sender.value animated:NO];
    
    [self.bedroomsLabel setText:[NSString stringWithFormat:@"%d",(int)sender.value]];
    
    if ((int)sender.value ==0)
    {
        [self.studioLabel setHidden:NO];
    }
    else
    {
        [self.studioLabel setHidden:YES];
    }
    
    [self.autoSave setValue:self.bedroomsLabel.text forKey:@"bedrooms"];
}

-(IBAction)bathroomValueChanged:(UISlider*)sender
{
    [sender setValue:((int)(sender.value*2))/2.0 animated:NO];
    
    if ((int)(sender.value*2)%2==1)
    {
        [self.bathroomsLabel setText:[NSString stringWithFormat:@"%.01f",((int)(sender.value*2))/2.0]];
    }
    else
    {
        [self.bathroomsLabel setText:[NSString stringWithFormat:@"%.0f",((int)(sender.value*2))/2.0]];
    }
    [self.autoSave setValue:self.bathroomsLabel.text forKey:@"bathrooms"];
}

#pragma mark - Buttons actions

- (void)displayFullMapViewForApartmentAtIndex:(NSInteger)index
{
    self.title = @" "; 
    FullMapViewViewController *fullMapView = [FullMapViewViewController new];
    MKPointAnnotation *locationPin = [MKPointAnnotation new];
    Apartment *ap = self.apartment;
    [locationPin setCoordinate:[LocationUtils locationFromPoint:ap.apartment[@"location"]]];
    fullMapView.locationPin = locationPin;
    
    [self.navigationController pushViewController:fullMapView animated:YES];
}

-(IBAction)showPreview:(id)sender
{
    if([self validateFields])
    {
    
        //creates a default uiview and adds the apartment details view as a subview
        
        UIViewController* moreVC= [UIViewController new];
        ApartmentDetailsOtherListingView* details = (ApartmentDetailsOtherListingView*)[[[NSBundle mainBundle] loadNibNamed:@"ApartmentDetailsOtherListingView" owner:nil options:nil] firstObject];
        [details setApartmentDetailsDelegate:self];
        
        //set frame to compensate for the invisible navigation bar, fix this once bar is removed
        details.frame = CGRectMake(0,-44, wScr, 1318 - 163);
        details.controller = moreVC;
        
        PFObject* apartmentInfo = [PFObject objectWithClassName:@"Apartment"];
        
        
        apartmentInfo[@"location"] = [NSString stringWithFormat:@"%f|%f", self.apartmentLocation.latitude, self.apartmentLocation.longitude];
        if (self.entirePlaceButton.selected)
        {
            apartmentInfo[@"listingType"] = @TypeEntirePlace;
        }
        if (self.privateRoomButton.selected)
        {
            apartmentInfo[@"listingType"] = @TypePrivateRoom;
        }
        
        if (self.apartmentButton.selected)
        {
            apartmentInfo[@"propertyType"] = @TypeApartment;
        }
        if (self.houseButton.selected)
        {
            apartmentInfo[@"propertyType"] = @TypeHouse;
        }
        
        
        apartmentInfo[@"bedrooms"] = [NSNumber numberWithInt:[self.bedroomsLabel.text intValue]];
        apartmentInfo[@"bathrooms"]= [NSNumber numberWithFloat:[self.bathroomsLabel.text floatValue]];
        
        NSString* feeString = self.feeTextField.text;
        feeString = [feeString stringByReplacingOccurrencesOfString:@"$" withString:@""];
        feeString = [feeString stringByReplacingOccurrencesOfString:@"," withString:@""];
        apartmentInfo[@"fee"] = [NSNumber numberWithInt:[feeString intValue]];
        
        NSString* rentString = self.rentTextField.text;
        rentString = [rentString stringByReplacingOccurrencesOfString:@"$" withString:@""];
        rentString = [rentString stringByReplacingOccurrencesOfString:@"," withString:@""];
        apartmentInfo[@"rent"] = [NSNumber numberWithInt:[rentString intValue]];
        
        apartmentInfo[@"moveOutOption"] = [NSNumber numberWithInteger:self.leaveApartmentOption];
        
        if (self.date1)
        {
            apartmentInfo[@"moveOutTimestamp"]=[NSNumber numberWithLong:(long)[self.date1 timeIntervalSince1970]];
        }
        else
        {
            apartmentInfo[@"moveOutTimestamp"]=[NSNumber numberWithLong:0];
        }
        apartmentInfo[@"renewalTimestamp"]=[NSNumber numberWithLong:(long)[self.date2 timeIntervalSince1970]];
        
        
        
        apartmentInfo[@"description"] = self.descriptionTextView.text;
        //            apartmentInfo[@"area"] = _areaTF.text;
        apartmentInfo[@"directContact"]=[NSNumber numberWithInteger: contactDirectly];
        apartmentInfo[@"visible"]=[NSNumber numberWithInteger: visible];
        apartmentInfo[@"hideFacebookProfile"]=[NSNumber numberWithInteger: hideFacebookProfile];
        apartmentInfo[@"owner"] = DEP.authenticatedUser;
        Apartment *apartment = [Apartment new];
        apartment.apartment =apartmentInfo;
        apartment.images = self.apartmentImages;
        apartment.owner = DEP.authenticatedUser;
        
        details.apartmentImages = self.imagesArray;
        

        [details.connectedThroughLbl setHidden:YES];
        [details.connectedThroughImageView setHidden:YES];
        [details.getButton setHidden:YES];
        [details.likeBtn setHidden:YES];
        [details.shareBtn setHidden:YES];
        
        details.currentUserIsOwner = YES;
        details.apartmentIndex=0;
        [details setApartmentDetails:apartment.apartment];
        
        details.firstImageView = [self.imagesArray objectAtIndex:0];
        
        
        [self setTitle:@" "];
        moreVC.view=[[UIScrollView alloc] initWithFrame:self.view.frame];
        [moreVC.view addSubview:details];
        [(UIScrollView*)moreVC.view setContentSize:CGSizeMake(wScr, details.frame.size.height -44) ];
        [(UIScrollView*)moreVC.view setScrollEnabled:YES];
        [moreVC.view setBackgroundColor:[UIColor whiteColor]];
        [self.navigationController pushViewController:moreVC animated:YES];
    
    }
}

-(IBAction)listingPhotosButtonTapped:(id)sender
{

    SelectListingPhotosViewController* selectListingPhotosVC =[[SelectListingPhotosViewController alloc]initWithNibName:@"SelectListingPhotosViewController" bundle:nil];
    [selectListingPhotosVC setDelegate:self];
    [selectListingPhotosVC customiseWithArray:self.imagesArray];
    
    [self presentViewController:selectListingPhotosVC animated:YES completion:^{
        
    }];

}

-(IBAction)detailsTapped:(id)sender
{
    EnterLeaseDetailsViewController* enterLeaseDetailsVC = [[EnterLeaseDetailsViewController alloc]initWithNibName:@"EnterLeaseDetailsViewController" bundle:nil];
    [enterLeaseDetailsVC setDelegate:self];
    [enterLeaseDetailsVC enterLeaseDetailsWithOption:self.leaveApartmentOption date1:self.date1 andDate2:self.date2];
    [self presentViewController:enterLeaseDetailsVC animated:YES completion:^{
        
    }];

}

-(IBAction)listingAddressButtonTapped:(id)sender
{
    EnterAddressViewController* enterAddressVC = [[EnterAddressViewController alloc]initWithNibName:@"EnterAddressViewController" bundle:nil];
    [enterAddressVC setDelegate:self];
    [enterAddressVC customiseWithString:self.locationName];
    [self presentViewController:enterAddressVC animated:YES completion:^{
        
    }];
}

-(IBAction)entirePlaceButtonTapped:(id)sender
{
    if (self.entirePlaceButton.selected)
    {
        [self.entirePlaceButton setSelected:NO];
        
        self.listingType = -1;
    }
    else
    {
        [self.entirePlaceButton setSelected:YES];
        [self.privateRoomButton setSelected:NO];
        
        self.listingType = 0;
    }
    [self.autoSave setValue:[NSNumber numberWithInt:self.listingType] forKey:@"listingType"];
}
-(IBAction)privateRoomButtonTapped:(id)sender
{
    if (self.privateRoomButton.selected)
    {
        [self.privateRoomButton setSelected:NO];
        self.listingType =-1;
    }
    else
    {
        [self.privateRoomButton setSelected:YES];
        [self.entirePlaceButton setSelected:NO];
        self.listingType =1;
    }
    [self.autoSave setValue:[NSNumber numberWithInt:self.listingType] forKey:@"listingType"];

}
-(IBAction)apartmentButtonTapped:(id)sender
{
    if (self.apartmentButton.selected)
    {
        [self.apartmentButton setSelected:NO];
        self.propertyType =-1;
    }
    else
    {
        [self.apartmentButton setSelected:YES];
        [self.houseButton setSelected:NO];
        self.propertyType =0;
    }
    [self.autoSave setValue:[NSNumber numberWithInt:self.propertyType] forKey:@"propertyType"];

}
-(IBAction)houseButtonTapped:(id)sender
{
    if (self.houseButton.selected)
    {
        [self.houseButton setSelected:NO];
        self.propertyType =-1;
    }
    else
    {
        [self.houseButton setSelected:YES];
        [self.apartmentButton setSelected:NO];
        self.propertyType =1;
    }
    [self.autoSave setValue:[NSNumber numberWithInt:self.propertyType] forKey:@"propertyType"];

}


-(IBAction)rentTapped:(id)sender
{
    [self setTitle:@" "];
    EnterDetailsViewController* enterDetailsVC= [[EnterDetailsViewController alloc] initWithNibName:@"EnterDetailsViewController" bundle:nil];
    [enterDetailsVC setDelegate:self];
    if ([self.rentTextField.text isEqualToString:@""])
    {
        [enterDetailsVC enterDetailsFor:stateRent withValue:nil];
    }
    else
    {
        [enterDetailsVC enterDetailsFor:stateRent withValue:self.rentTextField.text];
    }
    
    [self presentViewController:enterDetailsVC animated:YES completion:^{
        
    }];

    
}
-(IBAction)feeTapped:(id)sender
{
    [self setTitle:@" "];
    EnterDetailsViewController* enterDetailsVC= [[EnterDetailsViewController alloc] initWithNibName:@"EnterDetailsViewController" bundle:nil];
    [enterDetailsVC setDelegate:self];
    if ([self.feeTextField.text isEqualToString:@""])
    {
        [enterDetailsVC enterDetailsFor:stateFee withValue:nil];
    }
    else
    {
        [enterDetailsVC enterDetailsFor:stateFee withValue:self.feeTextField.text];
    }
    
    [self presentViewController:enterDetailsVC animated:YES completion:^{
        
    }];
    
}
-(IBAction)messageTapped:(id)sender
{
    [self setTitle:@" "];
    EnterDetailsViewController* enterDetailsVC= [[EnterDetailsViewController alloc] initWithNibName:@"EnterDetailsViewController" bundle:nil];
    [enterDetailsVC setDelegate:self];
    if ([self.descriptionTextView.text isEqualToString:@""])
    {
        [enterDetailsVC enterDetailsFor:stateMessage withValue:nil];
    }
    else
    {
        [enterDetailsVC enterDetailsFor:stateMessage withValue:self.descriptionTextView.text];
    }
    
    [self presentViewController:enterDetailsVC animated:YES completion:^{
        
    }];
    
}

-(IBAction)deleteApartment:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = @"Deleting";

    if (self.apartment.apartment)
    {
        PFQuery* imageQuery = [PFQuery queryWithClassName:@"ApartmentPhotos"];
        [imageQuery whereKey:@"apartment" equalTo:_apartment.apartment];
        
        [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject* object in objects)
            {
                [object delete];
            }
            
            PFQuery* requestQuery = [PFQuery queryWithClassName:@"ApartmentRequests"];
            [requestQuery whereKey:@"apartment" equalTo:_apartment.apartment];
            [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                for (PFObject* object in objects)
                {
                    [object delete];
                }
                PFQuery* favoritesQuery =[PFQuery queryWithClassName:@"Favorites"];
                [favoritesQuery whereKey:@"apartment" equalTo:_apartment.apartment];
                [favoritesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    for (PFObject* object in objects)
                    {
                        [object delete];
                    }
                    [self.apartment.apartment delete];
                    [hud hide:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                    [self.delegate addApartmentFinieshedWithChanges:YES];
                }];
            }];
        }];
        



    }
    
}

-(IBAction)saveChanges:(id)sender
{

    if([self validateFields])
    {

            CLLocation* location = [[CLLocation alloc] initWithLatitude:_apartmentLocation.latitude longitude:_apartmentLocation.longitude];
            [[CLGeocoder new] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            
                NSString* neighborhood = @" ";
                NSString* city = @" ";
                NSString* state = @" ";
                NSString* zipCode = @" ";
            
        
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
             
                
                _apartment.apartment[@"location"] = [NSString stringWithFormat:@"%f|%f", self.apartmentLocation.latitude, self.apartmentLocation.longitude];
                
                if (self.entirePlaceButton.selected)
                {
                    _apartment.apartment[@"listingType"] = @TypeEntirePlace;
                }
                if (self.privateRoomButton.selected)
                {
                    _apartment.apartment[@"listingType"] = @TypePrivateRoom;
                }
                if (self.apartmentButton.selected)
                {
                    _apartment.apartment[@"propertyType"] = @TypeApartment;
                }
                if (self.houseButton.selected)
                {
                    _apartment.apartment[@"propertyType"] = @TypeHouse;
                }

                _apartment.apartment[@"bedrooms"] = [NSNumber numberWithInt:[self.bedroomsLabel.text intValue]];
                _apartment.apartment[@"bathrooms"]= [NSNumber numberWithFloat:[self.bathroomsLabel.text floatValue]];

                
                NSString* feeString = self.feeTextField.text;
                feeString = [feeString stringByReplacingOccurrencesOfString:@"$" withString:@""];
                feeString = [feeString stringByReplacingOccurrencesOfString:@"," withString:@""];
                _apartment.apartment[@"fee"] = [NSNumber numberWithInt:[feeString intValue]];

                NSString* rentString = self.rentTextField.text;
                rentString = [rentString stringByReplacingOccurrencesOfString:@"$" withString:@""];
                rentString = [rentString stringByReplacingOccurrencesOfString:@"," withString:@""];
                _apartment.apartment[@"rent"] = [NSNumber numberWithInt:[rentString intValue]];

                _apartment.apartment[@"moveOutOption"] = [NSNumber numberWithInt:self.leaveApartmentOption];

                if (self.date1)
                {
                    _apartment.apartment[@"moveOutTimestamp"]=[NSNumber numberWithLong:(long)[self.date1 timeIntervalSince1970]];
                }
                else
                {
                    _apartment.apartment[@"moveOutTimestamp"]=[NSNumber numberWithLong:0];
                }
                _apartment.apartment[@"renewalTimestamp"]=[NSNumber numberWithLong:(long)[self.date2 timeIntervalSince1970]];

                _apartment.apartment[@"description"] = self.descriptionTextView.text;
                _apartment.apartment[@"locationName"] = self.locationName;
                _apartment.apartment[@"neighborhood"]=neighborhood;
                _apartment.apartment[@"city"]=city;
                _apartment.apartment[@"state"]=state;
                _apartment.apartment[@"zipcode"]=zipCode;
                
                _apartment.apartment[@"directContact"]=[NSNumber numberWithInteger: contactDirectly];
                _apartment.apartment[@"visible"]=[NSNumber numberWithInteger: visible];
                _apartment.apartment[@"hideFacebookProfile"]=[NSNumber numberWithInteger: hideFacebookProfile];


                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                hud.labelText = @"Saving";
                
                if (imagesHaveChangedInEditMode)
                {
                    PFQuery* query =[PFQuery queryWithClassName:@"ApartmentPhotos"];
                    [query whereKey:@"apartment" equalTo:_apartment.apartment];
                    
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                       
                        for (PFObject* object in objects)
                        {
                            [object delete];
                        }
                        
                        [_apartment.apartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [hud hide:YES];
                            
                            [DEP.api.apartmentApi uploadImages: self.imagesArray forApartment:_apartment.apartment completion:^(BOOL succes) {
                               
                                NSString* message;
                                
                                if (visible)
                                {
                                    message=@"Apartment has been saved!";
                                }
                                else
                                {
                                    message=@"Your apartment is saved...but not published! Toggle visibility to \"on\" if you want people to see it";
                                }
                                
                                [UIAlertView showWithTitle:@""
                                                   message:message
                                                     style:UIAlertViewStyleDefault
                                         cancelButtonTitle:nil otherButtonTitles:@[@"Ok"]
                                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                      AppDelegate* appDelegate= (AppDelegate*)[UIApplication sharedApplication].delegate;
                                                      [(DashboardViewController*)[(RentedPanelController*)appDelegate.rootViewController leftPanel] openMyPlace:nil];
                                                  }];
                                
                            }];
  
                            
                        }];
                        
                        
                        
                    }];
                    
                    
                }
                else
                {
                    [_apartment.apartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [hud hide:YES];
                        if (!error)
                        {
                            [[Mixpanel sharedInstance].people set:@{@"Apartment Posted":@"1"}];
                            [[Mixpanel sharedInstance] track:@"Apartment Updated" properties:@{@"facebook_id":[PFUser currentUser][@"facebookID"]}];
                            if (visible == 1)
                            {
                                [[Mixpanel sharedInstance].people set:@{@"Apartment is visible":@"1"}];
                            }
                            else
                            {
                                [[Mixpanel sharedInstance].people set:@{@"Apartment is visible":@"0"}];
                            }
                            

                            
                            NSString* message;
                            
                            if (visible)
                            {
                                message=@"Apartment has been saved!";
                            }
                            else
                            {
                                message=@"Your apartment is saved...but not published! Toggle visibility to \"on\" if you want people to see it";
                            }
                            
                            [UIAlertView showWithTitle:@""
                                               message:message
                                                 style:UIAlertViewStyleDefault
                                     cancelButtonTitle:nil otherButtonTitles:@[@"Ok"]
                                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                  AppDelegate* appDelegate= (AppDelegate*)[UIApplication sharedApplication].delegate;
                                                  [(DashboardViewController*)[(RentedPanelController*)appDelegate.rootViewController leftPanel] openMyPlace:nil];
                                              }];

                        }
                    
                    }];
                }
        }];
    }
}

-(IBAction)daysDropDownTapped:(id)sender
{

    [self.dayPicker setHidden:!self.dayPicker.hidden];
    
    [self.hourPicker setHidden:YES];
}
-(IBAction)hoursDropDownTapped:(id)sender
{
    [self.hourPicker setHidden:!self.hourPicker.hidden];
    
    [self.dayPicker setHidden:YES];
}

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
//    if (self.apartment)
//    {
//
//        if(![_apartment.apartment[@"visible"] boolValue])
//        {
//            [DEP.api.apartmentApi makeApartmentLive:_apartment.apartment completion:^(BOOL succeeded) {
//                
//            }];
//            
//            
//            [[[UIAlertView alloc]initWithTitle:@"Your listing is now visible!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
//            
//            [self.addApartmentBtn setTitle:@"UNFLIP" forState:UIControlStateNormal];
//            
//            
//        }
//        else
//        {
//            [DEP.api.apartmentApi hideLiveApartment:_apartment.apartment completion:^(BOOL succeeded) {
//                
//            }];
//            
//            [[[UIAlertView alloc]initWithTitle:@"OK! Your listing is hidden" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
//            
//            
//            
//            
//            
//            [self.addApartmentBtn setTitle:@"FLIP" forState:UIControlStateNormal];
//            
//        }
//            
//        
//        
//        return;
//    }
    if([self validateFields])
    {
        
        [self.addApartmentBtn setEnabled:NO];
        
        if(self.apartment)
        {
            [self saveChanges:nil];
            return;
        }
        

        CLLocation* location = [[CLLocation alloc] initWithLatitude:_apartmentLocation.latitude longitude:_apartmentLocation.longitude];
        [[CLGeocoder new] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
           
            NSString* neighborhood = @" ";
            NSString* city = @" ";
            NSString* state = @" ";
            NSString* zipCode = @" ";

            
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
            apartmentInfo[@"location"] = [NSString stringWithFormat:@"%f|%f", self.apartmentLocation.latitude, self.apartmentLocation.longitude];
            if (self.entirePlaceButton.selected)
            {
                apartmentInfo[@"listingType"] = @TypeEntirePlace;
            }
            if (self.privateRoomButton.selected)
            {
                apartmentInfo[@"listingType"] = @TypePrivateRoom;
            }
            
            if (self.apartmentButton.selected)
            {
                apartmentInfo[@"propertyType"] = @TypeApartment;
            }
            if (self.houseButton.selected)
            {
                apartmentInfo[@"propertyType"] = @TypeHouse;
            }


            apartmentInfo[@"bedrooms"] = [NSNumber numberWithInt:[self.bedroomsLabel.text intValue]];
            apartmentInfo[@"bathrooms"]= [NSNumber numberWithFloat:[self.bathroomsLabel.text floatValue]];
            
            NSString* feeString = self.feeTextField.text;
            feeString = [feeString stringByReplacingOccurrencesOfString:@"$" withString:@""];
            feeString = [feeString stringByReplacingOccurrencesOfString:@"," withString:@""];
            apartmentInfo[@"fee"] = [NSNumber numberWithInt:[feeString intValue]];
            
            NSString* rentString = self.rentTextField.text;
            rentString = [rentString stringByReplacingOccurrencesOfString:@"$" withString:@""];
            rentString = [rentString stringByReplacingOccurrencesOfString:@"," withString:@""];
            apartmentInfo[@"rent"] = [NSNumber numberWithInt:[rentString intValue]];

            apartmentInfo[@"moveOutOption"] = [NSNumber numberWithInt:self.leaveApartmentOption];
            
            if (self.date1)
            {
                apartmentInfo[@"moveOutTimestamp"]=[NSNumber numberWithLong:(long)[self.date1 timeIntervalSince1970]];
            }
            else
            {
                apartmentInfo[@"moveOutTimestamp"]=[NSNumber numberWithLong:0];
            }
            apartmentInfo[@"renewalTimestamp"]=[NSNumber numberWithLong:(long)[self.date2 timeIntervalSince1970]];


            
            apartmentInfo[@"description"] = self.descriptionTextView.text;
//            apartmentInfo[@"area"] = _areaTF.text;
            apartmentInfo[@"locationName"] = self.locationName;
            apartmentInfo[@"neighborhood"]=neighborhood;
            apartmentInfo[@"city"]=city;
            apartmentInfo[@"state"]=state;
            apartmentInfo[@"zipcode"]=zipCode;
            apartmentInfo[@"directContact"]=[NSNumber numberWithInteger: contactDirectly];
            apartmentInfo[@"visible"]=[NSNumber numberWithInteger: visible];
            apartmentInfo[@"hideFacebookProfile"]=[NSNumber numberWithInteger: hideFacebookProfile];

            
            [DEP.api.apartmentApi saveApartment:apartmentInfo
                                         images:self.imagesArray
                                        forUser:_apartmentOwner
                                     completion:^(BOOL succes) {
                                         
                                         if(succes)
                                         {
                                             [[Mixpanel sharedInstance].people set:@{@"Apartment Posted":@"1"}];
                                             [[Mixpanel sharedInstance] track:@"New Apartment Posted" properties:@{@"facebook_id":[PFUser currentUser][@"facebookID"]}];
                                             
                                             if (visible == 1)
                                             {
                                                 [[Mixpanel sharedInstance].people set:@{@"Apartment is visible":@"1"}];
                                                 
                                                 PFPush* push = [PFPush new];
                                                 
                                                 [push setChannel:@"global"];
                                                 
                                                 NSString* apartmentType;
                                                 if ([apartmentInfo[@"bedrooms"] integerValue]==0)
                                                 {
                                                     apartmentType = @"Studio";
                                                 }
                                                 if ([apartmentInfo[@"bedrooms"] integerValue]==1)
                                                 {
                                                     apartmentType = @"One Bedroom";
                                                 }
                                                 if ([apartmentInfo[@"bedrooms"] integerValue]==2)
                                                 {
                                                     apartmentType = @"Two Bedrooms";
                                                 }
                                                 if ([apartmentInfo[@"bedrooms"] integerValue]==3)
                                                 {
                                                     apartmentType = @"Three Bedrooms";
                                                 }
                                                 if ([apartmentInfo[@"bedrooms"] integerValue]==4)
                                                 {
                                                     apartmentType = @"Four Bedrooms";
                                                 }
                                                 if ([apartmentInfo[@"bedrooms"] integerValue]==5)
                                                 {
                                                     apartmentType = @"Five Bedrooms";
                                                 }
                                                 if (apartmentType == nil)
                                                 {
                                                     apartmentType = @"Apartment";
                                                 }
                                                 
                                                 NSString* alertString =[NSString stringWithFormat:@"There was a new %@ added in %@", apartmentType,apartmentInfo[@"neighborhood"] ];
                                                 NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                       alertString, @"alert",
                                                                       @"Increment", @"badge",
                                                                       nil];
                                                 [push setData:data];
//                                                 [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                                                     
//                                                 }];
                                                 
                                             }
                                             else
                                             {
                                                 [[Mixpanel sharedInstance].people set:@{@"Apartment is visible":@"0"}];
                                             }
                                             
                                             [self.addApartmentBtn setEnabled:YES];

                                             [UIAlertView showWithTitle:@""
                                                                message:@"Apartment has been saved!"
                                                                  style:UIAlertViewStyleDefault
                                                      cancelButtonTitle:nil otherButtonTitles:@[@"Ok"]
                                                               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                   AppDelegate* appDelegate= (AppDelegate*)[UIApplication sharedApplication].delegate;
                                                                   [(DashboardViewController*)[(RentedPanelController*)appDelegate.rootViewController leftPanel] openMyPlace:nil];

                                                               }];

                                             
                                         }
                                         else
                                         {
                                             [UIAlertView showWithTitle:@"" message:@"An error occurred. Please try again!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
                                             [self.addApartmentBtn setEnabled:YES];
                                         }
                                     }];
            

                
            }];
    }
}

- (BOOL)validateFields
{
    if(self.imagesArray.count == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"You must upload at least one image!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    if(!CLLocationCoordinate2DIsValid(_apartmentLocation))
    {
        [UIAlertView showWithTitle:@"" message:@"Select location!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    if(!self.entirePlaceButton.selected && !self.privateRoomButton.selected)
    {
        [UIAlertView showWithTitle:@"" message:@"Select listing lype!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    if(!self.apartmentButton.selected && !self.houseButton.selected)
    {
        [UIAlertView showWithTitle:@"" message:@"Select property type" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    if(self.rentTextField.text.length == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Enter the current rent" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    if(self.feeTextField.text.length == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Select your fee!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    NSString* rent = self.rentTextField.text;
    rent = [rent stringByReplacingOccurrencesOfString:@"$" withString:@""];
    rent = [rent stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSInteger recommendedFee=[rent integerValue]* 12 *0.01;
    
    NSString* selectedFee = self.feeTextField.text;
    selectedFee = [selectedFee stringByReplacingOccurrencesOfString:@"$" withString:@""];
    selectedFee = [selectedFee stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    if(recommendedFee<[selectedFee integerValue])
    {
        [UIAlertView showWithTitle:@"" message:@"The fee you selected is too high!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(self.descriptionTextView.text.length ==0)
    {
        [UIAlertView showWithTitle:@"" message:@"Enter a message for your listing!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(self.date2 ==nil)
    {
        [UIAlertView showWithTitle:@"" message:@"Select when the lease ends!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }

    
    return YES;
}

-(void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)visible:(id)sender
{
    if ([self.visibleSwitch isOn])
    {
        visible =1;
    }
    else
    {
        visible =0;
    }
    [self.autoSave setValue:[NSNumber numberWithInteger:visible] forKey:@"visible"];
}

- (IBAction)hideFacebookProfile:(id)sender
{
    if ([self.hideFacebookProfileSwitch isOn])
    {
        hideFacebookProfile =1;
    }
    else
    {
        hideFacebookProfile =0;
    }
    [self.autoSave setValue:[NSNumber numberWithInteger:hideFacebookProfile] forKey:@"hideFacebookProfile"];
}

- (IBAction)contactDirectly:(id)sender
{
    if ([self.contactDirectlySwitch isOn])
    {
        contactDirectly =1;
    }
    else
    {
        contactDirectly =0;
        [[[UIAlertView alloc]initWithTitle:@"Got it!" message:@" Anyone interested in your listing will contact Flip and we will screen them for you." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
    [self.autoSave setValue:[NSNumber numberWithInteger:contactDirectly] forKey:@"contactDirectly"];

}
#pragma mark - iCarousel Delegate and DataSource
-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    [self listingPhotosButtonTapped:nil];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionSpacing:
        {
            return (carousel.frame.size.width + 8)/carousel.frame.size.width;
        }
        case iCarouselOptionVisibleItems:
        {
            return 3;
        }
        default:
        {
            return value;
        }
    }
}
-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    [self.pageControl setCurrentPage:carousel.currentItemIndex];
}

-(NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.imagesArray.count;
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    AsyncImageView* image;
    if (view)
    {
        image = (AsyncImageView*)[view viewWithTag:1];
    }
    else
    {
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, carousel.frame.size.height)];
        [view setClipsToBounds:YES];
        image = [[AsyncImageView alloc] initWithFrame:view.frame];
        [image setShowActivityIndicator:YES];
        [image setCrossfadeDuration:0];
        [image setContentMode:UIViewContentModeScaleAspectFill];
        [image setUserInteractionEnabled:YES];
        [view addSubview:image];
        [image setTag:1];
    }
    
    [image setShowActivityIndicator:YES];
    [image setCrossfadeDuration:0];
    [image setImage:nil];
    
    if ([[self.imagesArray objectAtIndex:index] isKindOfClass:[UIImage class]])
    {
        [image setImage:[self.imagesArray objectAtIndex:index]];
    }
    else
    {
        PFObject *imageObject = [self.imagesArray objectAtIndex:index];

        
        if (!imageObject[@"fileName"] || !imageObject[@"type"])
        {
            PFFile *imageFile = imageObject[@"image"];
            image.imageURL = [NSURL URLWithString:imageFile.url];
        }
        else
        {
            NSInteger fileSize;
            
            if(wScr == 320)
            {
                if( ! IS_IPHONE_5 )
                {
                    fileSize = 1;
                }
                else
                {
                    fileSize = 2;
                }
            }
            else
            {
                if(wScr == 375)
                {
                    fileSize = 3;
                }
                else
                {
                    fileSize = 4;
                }
            }
            
            NSString* fileName = imageObject[@"fileName"];
            NSString* imageURL = [NSString stringWithFormat:@"%@/leaseflip/apt-img/%@/%@_%d",kImageHostString,[fileName substringToIndex:1],fileName,fileSize];
            image.imageURL = [NSURL URLWithString:imageURL];
            
        }
    }
    

    
    return view;
    
}


#pragma mark - Checkbox handlers

-(IBAction)tappedCheckBox:(UIButton*) button
{

    if (button== self.fee3percent)
    {
        if ([button isSelected])
        {
            [button setSelected:NO];
        }
        else
        {
            [button setSelected:YES];
            [self.fee6percent setSelected:NO];
            [self.fee9percent setSelected:NO];
        }
    }
    if (button== self.fee6percent)
    {
        if ([button isSelected])
        {
            [button setSelected:NO];
        }
        else
        {
            [button setSelected:YES];
            [self.fee3percent setSelected:NO];
            [self.fee9percent setSelected:NO];
        }
    }
    if (button== self.fee9percent)
    {
        if ([button isSelected])
        {
            [button setSelected:NO];
        }
        else
        {
            [button setSelected:YES];
            [self.fee3percent setSelected:NO];
            [self.fee6percent setSelected:NO];
        }
    }
    
    if (button== self.vacancyShortTerm)
    {
        if ([button isSelected])
        {
            [button setSelected:NO];
        }
        else
        {
            [button setSelected:YES];
            [self.vacancyLongTerm setSelected:NO];
            [self.vacancyFlexible setSelected:NO];
        }
    }
    if (button== self.vacancyLongTerm)
    {
        if ([button isSelected])
        {
            [button setSelected:NO];
        }
        else
        {
            [button setSelected:YES];
            [self.vacancyShortTerm setSelected:NO];
            [self.vacancyFlexible setSelected:NO];
        }
    }
    if (button== self.vacancyFlexible)
    {
        if ([button isSelected])
        {
            [button setSelected:NO];
        }
        else
        {
            [button setSelected:YES];
            [self.vacancyShortTerm setSelected:NO];
            [self.vacancyLongTerm setSelected:NO];
        }
    }
    
    if (button== self.typeEntirePlace)
    {
        if ([button isSelected])
        {
            [button setSelected:NO];
        }
        else
        {
            [button setSelected:YES];
            [self.typePrivateRoom setSelected:NO];
            [self.typeRetailOrCommercial setSelected:NO];
        }
    }
    if (button== self.typePrivateRoom)
    {
        if ([button isSelected])
        {
            [button setSelected:NO];
        }
        else
        {
            [button setSelected:YES];
            [self.typeEntirePlace setSelected:NO];
            [self.typeRetailOrCommercial setSelected:NO];
        }
    }
    if (button== self.typeRetailOrCommercial)
    {
        if ([button isSelected])
        {
            [button setSelected:NO];
        }
        else
        {
            [button setSelected:YES];
            [self.typeEntirePlace setSelected:NO];
            [self.typePrivateRoom setSelected:NO];
        }
    }
}

//
//- (void)checkStudio:(M13Checkbox *)checkbox
//{
//    bedroom1.checkState = M13CheckboxStateUnchecked;
//    bedroom2.checkState = M13CheckboxStateUnchecked;
//    bedroom3.checkState = M13CheckboxStateUnchecked;
//    bedroom4.checkState = M13CheckboxStateUnchecked;
//    
//    [rooms removeObject:@Bedroom1];
//    [rooms removeObject:@Bedrooms2];
//    [rooms removeObject:@Bedrooms3];
//    [rooms removeObject:@Bedrooms4];
//    
//    if(checkbox.checkState == M13CheckboxStateChecked)
//    {
//        if (![rooms containsObject:@Studio])
//            [rooms addObject:@Studio];
//    }
//    else
//        [rooms removeObject:@Studio];
//}
//
//- (void)check1Bedroom:(M13Checkbox *)checkbox
//{
//    studioRoom.checkState = M13CheckboxStateUnchecked;
//    bedroom2.checkState = M13CheckboxStateUnchecked;
//    bedroom3.checkState = M13CheckboxStateUnchecked;
//    bedroom4.checkState = M13CheckboxStateUnchecked;
//    
//    [rooms removeObject:@Studio];
//    [rooms removeObject:@Bedrooms2];
//    [rooms removeObject:@Bedrooms3];
//    [rooms removeObject:@Bedrooms4];
//    
//    if(bedroom1.checkState == M13CheckboxStateChecked)
//    {
//        if (![rooms containsObject:@Bedroom1])
//            [rooms addObject:@Bedroom1];
//    }
//    else
//        [rooms removeObject:@Bedroom1];
//}
//
//- (void)check2Bedrooms:(M13Checkbox *)checkbox
//{
//    studioRoom.checkState = M13CheckboxStateUnchecked;
//    bedroom1.checkState = M13CheckboxStateUnchecked;
//    bedroom3.checkState = M13CheckboxStateUnchecked;
//    bedroom4.checkState = M13CheckboxStateUnchecked;
//    
//    [rooms removeObject:@Studio];
//    [rooms removeObject:@Bedroom1];
//    [rooms removeObject:@Bedrooms3];
//    [rooms removeObject:@Bedrooms4];
//    
//    if(bedroom2.checkState == M13CheckboxStateChecked)
//    {
//        if (![rooms containsObject:@Bedrooms2])
//            [rooms addObject:@Bedrooms2];
//    }
//    else
//        [rooms removeObject:@Bedrooms2];
//}
//
//- (void)check3Bedrooms:(M13Checkbox *)checkbox
//{
//    studioRoom.checkState = M13CheckboxStateUnchecked;
//    bedroom1.checkState = M13CheckboxStateUnchecked;
//    bedroom2.checkState = M13CheckboxStateUnchecked;
//    bedroom4.checkState = M13CheckboxStateUnchecked;
//    
//    [rooms removeObject:@Studio];
//    [rooms removeObject:@Bedroom1];
//    [rooms removeObject:@Bedrooms2];
//    [rooms removeObject:@Bedrooms4];
//    
//    if(bedroom3.checkState == M13CheckboxStateChecked)
//    {
//        if (![rooms containsObject:@Bedrooms3])
//            [rooms addObject:@Bedrooms3];
//    }
//    else
//        [rooms removeObject:@Bedrooms3];
//}
//
//- (void)check4Bedrooms:(M13Checkbox *)checkbox
//{
//    studioRoom.checkState = M13CheckboxStateUnchecked;
//    bedroom1.checkState = M13CheckboxStateUnchecked;
//    bedroom3.checkState = M13CheckboxStateUnchecked;
//    bedroom2.checkState = M13CheckboxStateUnchecked;
//    
//    [rooms removeObject:@Studio];
//    [rooms removeObject:@Bedroom1];
//    [rooms removeObject:@Bedrooms3];
//    [rooms removeObject:@Bedrooms2];
//    
//    if(bedroom4.checkState == M13CheckboxStateChecked)
//    {
//        if (![rooms containsObject:@Bedrooms4])
//            [rooms addObject:@Bedrooms4];
//    }
//    else
//        [rooms removeObject:@Bedrooms4];
//}
//
//- (void)checkVacancyImmediate:(M13Checkbox *)checkbox
//{
//    vacancyNegociable.checkState = M13CheckboxStateUnchecked;
//    vacancyShortTerm.checkState = M13CheckboxStateUnchecked;
//    
//    [vacancy removeObject:@VacancyShortTerm];
//    [vacancy removeObject:@VacancyFlexible];
//    
//    if(vacancyImmediate.checkState == M13CheckboxStateChecked)
//    {
//        if (![vacancy containsObject:@VacancyImmediate])
//            [vacancy addObject:@VacancyImmediate];
//    }
//    else
//        [vacancy removeObject:@VacancyImmediate];
//}
//
//- (void)checkVacancyShortTerm:(M13Checkbox *)checkbox
//{
//    vacancyNegociable.checkState = M13CheckboxStateUnchecked;
//    vacancyImmediate.checkState = M13CheckboxStateUnchecked;
//    
//    [vacancy removeObject:@VacancyImmediate];
//    [vacancy removeObject:@VacancyFlexible];
//    
//    if(vacancyShortTerm.checkState == M13CheckboxStateChecked)
//    {
//        if (![vacancy containsObject:@VacancyShortTerm])
//            [vacancy addObject:@VacancyShortTerm];
//    }
//    else
//        [vacancy removeObject:@VacancyShortTerm];
//    
//}
//
//- (void)checkVacancyNegociable:(M13Checkbox *)checkbox
//{
//    vacancyShortTerm.checkState = M13CheckboxStateUnchecked;
//    vacancyImmediate.checkState = M13CheckboxStateUnchecked;
//    
//    [vacancy removeObject:@VacancyImmediate];
//    [vacancy removeObject:@VacancyShortTerm];
//    
//    if(vacancyNegociable.checkState == M13CheckboxStateChecked)
//    {
//        if (![vacancy containsObject:@VacancyFlexible])
//            [vacancy addObject:@VacancyFlexible];
//    }
//    else
//        [vacancy removeObject:@VacancyFlexible];
//}
//- (void)checkFee3Percent:(M13Checkbox *)checkbox
//{
//    fee6percent.checkState = M13CheckboxStateUnchecked;
//    fee9percent.checkState = M13CheckboxStateUnchecked;
//    self.otherAmountTextField.text =@"";
//    
//    [fee removeObject:@Fee6percent];
//    [fee removeObject:@Fee9percent];
//    [fee removeObject:@FeeOtherpercent];
//    
//    if(fee3percent.checkState == M13CheckboxStateChecked)
//    {
//        if (![fee containsObject:@Fee3percent])
//            [fee addObject:@Fee3percent];
//    }
//    else
//        [fee removeObject:@Fee9percent];
//}
//- (void)checkFee6Percent:(M13Checkbox *)checkbox
//{
//    fee3percent.checkState = M13CheckboxStateUnchecked;
//    fee9percent.checkState = M13CheckboxStateUnchecked;
//    self.otherAmountTextField.text =@"";
//
//    [fee removeObject:@Fee3percent];
//    [fee removeObject:@Fee9percent];
//    [fee removeObject:@FeeOtherpercent];
//    
//    if(fee6percent.checkState == M13CheckboxStateChecked)
//    {
//        if (![fee containsObject:@Fee6percent])
//            [fee addObject:@Fee6percent];
//    }
//    else
//        [fee removeObject:@Fee6percent];
//}
//- (void)checkFee9Percent:(M13Checkbox *)checkbox
//{
//    fee6percent.checkState = M13CheckboxStateUnchecked;
//    fee3percent.checkState = M13CheckboxStateUnchecked;
//    self.otherAmountTextField.text =@"";
//    
//    [fee removeObject:@Fee6percent];
//    [fee removeObject:@Fee3percent];
//    [fee removeObject:@FeeOtherpercent];
//    
//    if(fee9percent.checkState == M13CheckboxStateChecked)
//    {
//        if (![fee containsObject:@Fee9percent])
//            [fee addObject:@Fee9percent];
//    }
//    else
//        [fee removeObject:@Fee9percent];
//}
//- (void)checkWillRentChangeYes:(M13Checkbox *)checkbox
//{
//    willRentChangeNo.checkState = M13CheckboxStateUnchecked;
//    willRentChangeMaybe.checkState = M13CheckboxStateUnchecked;
//    
//    [rentWillChange removeObject:@RentWillChangeNO];
//    [rentWillChange removeObject:@RentWillChangeMaybe];
//    
//    if(willRentChangeYes.checkState == M13CheckboxStateChecked)
//    {
//        if (![rentWillChange containsObject:@RentWillChangeYES])
//            [rentWillChange addObject:@RentWillChangeYES];
//    }
//    else
//        [rentWillChange removeObject:@RentWillChangeYES];
//}
//- (void)checkWillRentChangeNO:(M13Checkbox *)checkbox
//{
//    willRentChangeYes.checkState = M13CheckboxStateUnchecked;
//    willRentChangeMaybe.checkState = M13CheckboxStateUnchecked;
//    
//    [rentWillChange removeObject:@RentWillChangeYES];
//    [rentWillChange removeObject:@RentWillChangeMaybe];
//    
//    if(willRentChangeNo.checkState == M13CheckboxStateChecked)
//    {
//        if (![rentWillChange containsObject:@RentWillChangeNO])
//            [rentWillChange addObject:@RentWillChangeNO];
//    }
//    else
//        [rentWillChange removeObject:@RentWillChangeNO];
//}
//- (void)checkWillRentChangeMaybe:(M13Checkbox *)checkbox
//{
//    willRentChangeNo.checkState = M13CheckboxStateUnchecked;
//    willRentChangeYes.checkState = M13CheckboxStateUnchecked;
//    
//    [rentWillChange removeObject:@RentWillChangeNO];
//    [rentWillChange removeObject:@RentWillChangeYES];
//    
//    if(willRentChangeMaybe.checkState == M13CheckboxStateChecked)
//    {
//        if (![rentWillChange containsObject:@RentWillChangeMaybe])
//            [rentWillChange addObject:@RentWillChangeMaybe];
//    }
//    else
//        [rentWillChange removeObject:@RentWillChangeMaybe];
//}
//
//- (void)checkEntirePlace:(M13Checkbox *)checkbox
//{
//    typePrivateRoom.checkState = M13CheckboxStateUnchecked;
//    typeRetailOrCommercial.checkState = M13CheckboxStateUnchecked;
//    
//    [type removeObject:@TypePrivateRoom];
//    [type removeObject:@TypeRetailOrCommercial];
//    
//    if(typeEntirePlace.checkState == M13CheckboxStateChecked)
//    {
//        if (![type containsObject:@TypeEntirePlace])
//            [type addObject:@TypeEntirePlace];
//    }
//    else
//        [type removeObject:@TypeEntirePlace];
//}
//
//- (void)checkPrivateRoom:(M13Checkbox *)checkbox
//{
//    typeEntirePlace.checkState = M13CheckboxStateUnchecked;
//    typeRetailOrCommercial.checkState = M13CheckboxStateUnchecked;
//    
//    [type removeObject:@TypeEntirePlace];
//    [type removeObject:@TypeRetailOrCommercial];
//    
//    if(typePrivateRoom.checkState == M13CheckboxStateChecked)
//    {
//        if (![type containsObject:@TypePrivateRoom])
//            [type addObject:@TypePrivateRoom];
//    }
//    else
//        [type removeObject:@TypePrivateRoom];
//}
//
//- (void)checkRetailOrCommercial:(M13Checkbox *)checkbox
//{
//    typeEntirePlace.checkState = M13CheckboxStateUnchecked;
//    typePrivateRoom.checkState = M13CheckboxStateUnchecked;
//    
//    [type removeObject:@TypeEntirePlace];
//    [type removeObject:@TypePrivateRoom];
//    
//    if(typeRetailOrCommercial.checkState == M13CheckboxStateChecked)
//    {
//        if (![type containsObject:@TypeRetailOrCommercial])
//            [type addObject:@TypeRetailOrCommercial];
//    }
//    else
//        [type removeObject:@TypeRetailOrCommercial];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}


@end
    