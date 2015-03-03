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
#import "CongratulationsViewController.h"
#import "UnflipedViewController.h"
#import "MBProgressHUD.h"




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
    
    UIDatePicker* datePicker;
    
    BOOL imagesHaveChangedInEditMode;
    
    MKPointAnnotation *currentAnnotation;
    TRAutocompleteView *locationAutocomplete;


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
@property (weak, nonatomic) IBOutlet UISwitch *contactDirectlySwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *hourPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *dayPicker;
@property (weak, nonatomic) IBOutlet UIButton *hoursButton;
@property (weak, nonatomic) IBOutlet UIButton *daysButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;




@end

@implementation AddApartmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //configure views
    
    [self.addApartmentBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47a0db"]] forState:UIControlStateNormal];

    

    
    _areaTF.delegate = self;
    _rentTF.delegate = self;
    _descriptionTextView.delegate = self;

    
    _descriptionTextView.placeholder = @"\nPlumbing issues? Amazing natural light?\nWrite a short description here.";
    _descriptionTextView.placeholderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];

    _descriptionTextView.delegate = self;
    _descriptionTextView.returnKeyType = UIReturnKeyDefault;
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nextButton setBackgroundColor:[UIColor whiteColor]];
    [nextButton addTarget:self action:@selector(enterRent) forControlEvents:UIControlEventTouchUpInside];
    

    _areaTF.inputAccessoryView = nextButton;

    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneButton setBackgroundColor:[UIColor whiteColor]];
    [doneButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    _rentTF.inputAccessoryView = doneButton;
    _descriptionTextView.inputAccessoryView = doneButton;

    UITapGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismiss)];
    dismissGesture.numberOfTapsRequired = 1;
    dismissGesture.numberOfTouchesRequired = 1;
    dismissGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:dismissGesture];
    
    
    _apartmentLocation = kCLLocationCoordinate2DInvalid;
    
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
    
    
    contactDirectly=1;

    //using view controller in edit mode
    if(self.apartment)
    {
        UIButton* saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [saveButton setFrame:CGRectMake(0, 0, 80, 40)];
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveChanges:) forControlEvents:UIControlEventTouchUpInside];

        UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [deleteButton setFrame:CGRectMake(0, 0, 80, 40)];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteApartment:) forControlEvents:UIControlEventTouchUpInside];

        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:deleteButton],[[UIBarButtonItem alloc] initWithCustomView:saveButton], nil]];
        
        //customise fields using the apartment's data
        [self customiseViews];
    }
    else
    {
        [self.saveButton setHidden:YES];
        [self.deleteButton setHidden:YES];

    }
    
    [self.secondScrollViewContainer bringSubviewToFront:_hourPicker];
    [self.secondScrollViewContainer bringSubviewToFront:_dayPicker];
    
    [self.scrollViewContainer setContentInset:UIEdgeInsetsMake(-44, 0, 0, 0)];
    
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
    _apartmentLocation=[LocationUtils locationFromPoint:_apartment.apartment[@"location"]];

    _addressTextField.text = _apartment.apartment[@"locationName"];
    
    NSString* selectedText;
    if (_apartment.images.count==1)
    {
        selectedText = @"one image";
    }
    else
    {
        selectedText = [NSString stringWithFormat:@"%lu images", (unsigned long)_apartment.images.count];
    }
    
    [_addImagesButton setTitle:selectedText forState:UIControlStateNormal];
    
    
    if ([_apartment.apartment[@"vacancy"] containsObject:@VacancyShortTerm])
    {
        [self.vacancyShortTerm setSelected:YES];
    }
    if ([_apartment.apartment[@"vacancy"] containsObject:@VacancyLongTerm])
    {
        [self.vacancyLongTerm setSelected:YES];
    }
    if ([_apartment.apartment[@"vacancy"] containsObject:@VacancyFlexible])
    {
        [self.vacancyFlexible setSelected:YES];
    }
    
    if ([_apartment.apartment[@"fee"] containsObject:@Fee3percent])
    {
        [self.fee3percent setSelected:YES];
    }
    if ([_apartment.apartment[@"fee"] containsObject:@Fee6percent])
    {
        [self.fee6percent setSelected:YES];
    }
    if ([_apartment.apartment[@"fee"] containsObject:@Fee9percent])
    {
        [self.fee9percent setSelected:YES];
    }
    
    NSInteger roomType = [[_apartment.apartment[@"rooms"] firstObject] integerValue];
    
    [self.numberOfBedroomsPicker selectRow:roomType+1 inComponent:0 animated:NO];
    [self pickerView:self.numberOfBedroomsPicker didSelectRow:roomType+1 inComponent:0];
    
    rooms = [_apartment.apartment[@"rooms"] mutableCopy];
    
    if ([_apartment.apartment[@"type"] integerValue]==TypeEntirePlace)
    {
        [self.typeEntirePlace setSelected:YES];
    }
    if ([_apartment.apartment[@"type"] integerValue]==TypePrivateRoom)
    {
        [self.typePrivateRoom setSelected:YES];
    }
     if ([_apartment.apartment[@"type"] integerValue]==TypeRetailOrCommercial)
    {
        [self.typeRetailOrCommercial setSelected:YES];
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
    
    leaseExpirationDate = [NSDate dateWithTimeIntervalSince1970:[_apartment.apartment[@"renewalTimestamp"] integerValue]];
  
    [self.leaseRenewalPicker setDate:leaseExpirationDate];
    
    [self dateIsChanged:nil];
    
    [self.contactDirectlySwitch setOn:[_apartment.apartment[@"directContact"] boolValue]];
    contactDirectly=[_apartment.apartment[@"directContact"] integerValue];

    _apartmentImages = _apartment.images;
    
    [self.descriptionTextView setText:_apartment.apartment[@"description"]];
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
-(void)textViewDidBeginEditing:(UITextView *)textView
{

    activeField = textView;
    
}
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

#pragma mark - Buttons actions
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
            

                _apartment.apartment[@"location"] = [NSString stringWithFormat:@"%f|%f", _apartmentLocation.latitude, _apartmentLocation.longitude];
                if (self.typeEntirePlace.selected)
                {
                    _apartment.apartment[@"type"] = @TypeEntirePlace;
                }
                if (self.typePrivateRoom.selected)
                {
                    _apartment.apartment[@"type"] = @TypePrivateRoom;
                }
                if (self.typeRetailOrCommercial.selected)
                {
                    _apartment.apartment[@"type"] = @TypeRetailOrCommercial;
                }
                
                
                switch ([self.numberOfBedroomsPicker selectedRowInComponent:0])
                {
                    case 0:
                        break;
                    case 1:
                        _apartment.apartment[@"rooms"] = [NSArray arrayWithObject:@Studio];
                        break;
                    case 2:
                        _apartment.apartment[@"rooms"] = [NSArray arrayWithObject:@Bedroom1];
                        break;
                    case 3:
                        _apartment.apartment[@"rooms"] = [NSArray arrayWithObject:@Bedrooms2];
                        break;
                    case 4:
                        _apartment.apartment[@"rooms"] = [NSArray arrayWithObject:@Bedrooms3];
                        break;
                    case 5:
                        _apartment.apartment[@"rooms"] = [NSArray arrayWithObject:@Bedrooms4];
                        break;
                        
                    default:
                        break;
                }
                if (self.fee3percent.selected)
                {
                    _apartment.apartment[@"fee"] = [NSArray arrayWithObject:@Fee3percent];
                }
                if (self.fee6percent.selected)
                {
                    _apartment.apartment[@"fee"] = [NSArray arrayWithObject:@Fee6percent];
                }
                if (self.fee9percent.selected)
                {
                    _apartment.apartment[@"fee"] = [NSArray arrayWithObject:@Fee9percent];
                }
                
                if (self.vacancyShortTerm.selected)
                {
                    _apartment.apartment[@"vacancy"] = [NSArray arrayWithObject:@VacancyShortTerm];
                }
                if (self.vacancyLongTerm.selected)
                {
                    _apartment.apartment[@"vacancy"] = [NSArray arrayWithObject:@VacancyLongTerm];
                }
                if (self.vacancyFlexible.selected)
                {
                    _apartment.apartment[@"vacancy"] = [NSArray arrayWithObject:@VacancyFlexible];
                }

                _apartment.apartment[@"description"] = self.descriptionTextView.text;
                _apartment.apartment[@"area"] = [NSNumber numberWithInteger:[_areaTF.text integerValue]];
                _apartment.apartment[@"rent"] = [NSNumber numberWithInteger:[_rentTF.text integerValue]];
                _apartment.apartment[@"locationName"] = _addressTextField.text;
                _apartment.apartment[@"neighborhood"]=neighborhood;
                _apartment.apartment[@"city"]=city;
                _apartment.apartment[@"state"]=state;
                _apartment.apartment[@"zipcode"]=zipCode;
                
                _apartment.apartment[@"directContact"]=[NSNumber numberWithInteger: contactDirectly];

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
                            
                            [DEP.api.apartmentApi uploadImages: _apartmentImages forApartment:_apartment.apartment completion:^(BOOL succes) {
                               
                                
                                [UIAlertView showWithTitle:@""
                                                   message:@"Apartment has been saved!"
                                                     style:UIAlertViewStyleDefault
                                         cancelButtonTitle:nil otherButtonTitles:@[@"Ok"]
                                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                      [self.navigationController popViewControllerAnimated:YES];
                                                      [self.delegate addApartmentFinieshedWithChanges:YES];
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
                            [UIAlertView showWithTitle:@""
                                               message:@"Apartment has been saved!"
                                                 style:UIAlertViewStyleDefault
                                     cancelButtonTitle:nil otherButtonTitles:@[@"Ok"]
                                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                  [self.navigationController popViewControllerAnimated:YES];
                                                  [self.delegate addApartmentFinieshedWithChanges:YES];
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
    if (self.apartment)
    {

        if(![_apartment.apartment[@"visible"] boolValue])
        {
            [DEP.api.apartmentApi makeApartmentLive:_apartment.apartment completion:^(BOOL succeeded) {
                
            }];
            
            
            [[[UIAlertView alloc]initWithTitle:@"Your listing is now visible!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            
            [self.addApartmentBtn setTitle:@"UNFLIP" forState:UIControlStateNormal];
            
            
        }
        else
        {
            [DEP.api.apartmentApi hideLiveApartment:_apartment.apartment completion:^(BOOL succeeded) {
                
            }];
            
            [[[UIAlertView alloc]initWithTitle:@"OK! Your listing is hidden" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            
            
            
            
            
            [self.addApartmentBtn setTitle:@"FLIP" forState:UIControlStateNormal];
            
        }
            
        
        
        return;
    }
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
            
            NSMutableDictionary *apartmentInfo = [NSMutableDictionary new];
            apartmentInfo[@"location"] = [NSString stringWithFormat:@"%f|%f", _apartmentLocation.latitude, _apartmentLocation.longitude];
            if (self.typeEntirePlace.selected)
            {
                apartmentInfo[@"type"] = @TypeEntirePlace;
            }
            if (self.typePrivateRoom.selected)
            {
                apartmentInfo[@"type"] = @TypePrivateRoom;
            }
            if (self.typeRetailOrCommercial.selected)
            {
                apartmentInfo[@"type"] = @TypeRetailOrCommercial;
            }
            
            switch ([self.numberOfBedroomsPicker selectedRowInComponent:0])
            {
                case 0:
                    break;
                case 1:
                    apartmentInfo[@"rooms"] = [NSArray arrayWithObject:@Studio];
                    break;
                case 2:
                    apartmentInfo[@"rooms"] = [NSArray arrayWithObject:@Bedroom1];
                    break;
                case 3:
                    apartmentInfo[@"rooms"] = [NSArray arrayWithObject:@Bedrooms2];
                    break;
                case 4:
                    apartmentInfo[@"rooms"] = [NSArray arrayWithObject:@Bedrooms3];
                    break;
                case 5:
                    apartmentInfo[@"rooms"] = [NSArray arrayWithObject:@Bedrooms4];
                    break;
                    
                default:
                    break;
            }
            
            if (self.fee3percent.selected)
            {
                apartmentInfo[@"fee"] = [NSArray arrayWithObject:@Fee3percent];
            }
            if (self.fee6percent.selected)
            {
                apartmentInfo[@"fee"] = [NSArray arrayWithObject:@Fee6percent];
            }
            if (self.fee9percent.selected)
            {
                apartmentInfo[@"fee"] = [NSArray arrayWithObject:@Fee9percent];
            }
            
            if (self.vacancyShortTerm.selected)
            {
                apartmentInfo[@"vacancy"] = [NSArray arrayWithObject:@VacancyShortTerm];
            }
            if (self.vacancyLongTerm.selected)
            {
                apartmentInfo[@"vacancy"] = [NSArray arrayWithObject:@VacancyLongTerm];
            }
            if (self.vacancyFlexible.selected)
            {
                apartmentInfo[@"vacancy"] = [NSArray arrayWithObject:@VacancyFlexible];
            }
            
            apartmentInfo[@"description"] = self.descriptionTextView.text;
            apartmentInfo[@"area"] = _areaTF.text;
            apartmentInfo[@"rent"] = _rentTF.text;
            apartmentInfo[@"locationName"] = _addressTextField.text;
            apartmentInfo[@"neighborhood"]=neighborhood;
            apartmentInfo[@"city"]=city;
            apartmentInfo[@"state"]=state;
            apartmentInfo[@"zipcode"]=zipCode;
            apartmentInfo[@"directContact"]=[NSNumber numberWithInteger: contactDirectly];
            
            apartmentInfo[@"renewalTimestamp"]=[NSNumber numberWithLong:(long)[leaseExpirationDate timeIntervalSince1970]];
            
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
                                                                   [self.navigationController popViewControllerAnimated:YES];
                                                                   [self.delegate addApartmentFinieshedWithChanges:YES];

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
    if(!self.vacancyShortTerm.selected && !self.vacancyLongTerm.selected && !self.vacancyFlexible.selected)
    {
        [UIAlertView showWithTitle:@"" message:@"Select vacancy!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    if(!self.fee3percent.selected && !self.fee6percent.selected && !self.fee9percent.selected)
    {
        [UIAlertView showWithTitle:@"" message:@"Select your fee!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(!self.typeEntirePlace.selected && !self.typePrivateRoom.selected && !self.typeRetailOrCommercial.selected)
    {
        [UIAlertView showWithTitle:@"" message:@"Select type!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(!leaseExpirationDate)
    {
        [UIAlertView showWithTitle:@"" message:@"Select lease renewal date!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }

//    if(_roomsTextView.text.length == 0)
//    {
//        [UIAlertView showWithTitle:@"" message:@"Enter rooms description!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
//        return NO;
//    }
    
    
    if([self.numberOfBedroomsPicker selectedRowInComponent:0]==0)
    {
        [UIAlertView showWithTitle:@"" message:@"Select number of bedrooms!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }

    if(_areaTF.text.length == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Enter apartment's area!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
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
//    if(rentWillChange.count == 0)
//    {
//        [UIAlertView showWithTitle:@"" message:@"Select whether or not your rent will change!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
//        return NO;
//    }

    
    if(_descriptionTextView.text.length == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Enter apartment's description!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    


    
    return YES;
}

-(void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    }
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
