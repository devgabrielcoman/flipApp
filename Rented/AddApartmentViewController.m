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
#import "MapUtils.h"
#import "PickerData.h"
#import <UIAlertView+Blocks.h>
#import "M13Checkbox.h"

#define EntirePlaceType 0
#define PrivateRoomType 1

@interface AddApartmentViewController ()
<UITextFieldDelegate, MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, CTAssetsPickerControllerDelegate>
{
    MKPointAnnotation *locationPin;
    UIPickerView *apartmentTypePicker;
    NSArray *apartmentTypes;
    
    UITextField *activeField;
    CGPoint lastScrollViewOffset;
    UIEdgeInsets lastScrollViewContentInset;
    UIEdgeInsets lastScrollViewScrollIndicator;
    
    M13Checkbox *studioRoom;
    M13Checkbox *bedroom1;
    M13Checkbox *bedroom2;
    M13Checkbox *bedroom3;
    M13Checkbox *bedroom4;
    
    M13Checkbox *vacancyImmediate;
    M13Checkbox *vacancyShortTerm;
    M13Checkbox *vacancyNegociable;
    
    UILabel*        yourFeeLabel;
    M13Checkbox*    fee3percent;
    M13Checkbox*    fee4percent;
    M13Checkbox*    fee5percent;
    
    UILabel*        willRentChangeLabel;
    M13Checkbox*    willRentChangeYes;
    M13Checkbox*    willRentChangeNo;
    M13Checkbox*    willRentChangeMaybe;
    
    NSMutableArray *rooms;
    NSMutableArray *vacancy;
    NSMutableArray *fee;
    NSMutableArray *rentWillChange;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *typeTF;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *roomsTextView;
@property (weak, nonatomic) IBOutlet UITextField *areaTF;
@property (weak, nonatomic) IBOutlet UITextField *daysRenewalTF;
@property (weak, nonatomic) IBOutlet UITextField *rentTF;
@property (weak, nonatomic) IBOutlet UIButton *addImagesButton;
@property (weak, nonatomic) IBOutlet UIButton *selectOwnerBtn;
@property (weak, nonatomic) IBOutlet UIButton *addApartmentBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewContainer;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *descriptionTextView;

@end

@implementation AddApartmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    _addApartmentBtn.layer.cornerRadius = 6.0;
    _addApartmentBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    
    _addImagesButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    _selectOwnerBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneButton setBackgroundColor:[UIColor whiteColor]];
    [doneButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    _areaTF.inputAccessoryView = doneButton;
    _rentTF.inputAccessoryView = doneButton;
    _daysRenewalTF.inputAccessoryView = doneButton;
    
    UITapGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    dismissGesture.numberOfTapsRequired = 1;
    dismissGesture.numberOfTouchesRequired = 1;
    dismissGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:dismissGesture];
    
    UITapGestureRecognizer *tapOnMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openFullScreenMap)];
    tapOnMap.numberOfTouchesRequired = 1;
    tapOnMap.numberOfTapsRequired = 1;
    [_mapView addGestureRecognizer:tapOnMap];
    
    _apartmentLocation = kCLLocationCoordinate2DInvalid;
    locationPin = [MKPointAnnotation new];
    
    apartmentTypes = @[[[PickerData alloc] initWithDisplayName:@"Entire Place" andValue:@EntirePlaceType], [[PickerData alloc] initWithDisplayName:@"Private Room" andValue:@PrivateRoomType]];
    apartmentTypePicker = [UIPickerView new];
    apartmentTypePicker.delegate = self;
    apartmentTypePicker.dataSource = self;
    _typeTF.inputView = apartmentTypePicker;
    
    [self registerForKeyboardNotifications];
    
    _apartmentType = -1;
    
    [self addCheckboxes];
    
    rooms = [NSMutableArray new];
    [rooms addObject:@Studio];
    
    vacancy = [NSMutableArray new];
    [vacancy addObject:@VacancyImmediate];
    
    fee = [NSMutableArray new];
    [fee addObject:@Fee3percent];
    
    rentWillChange = [NSMutableArray new];
    [rentWillChange addObject:@RentWillChangeYES];
    
    _apartmentOwner=[PFUser currentUser];
    
    self.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelf)];
    
}

- (void)addCheckboxes
{
    studioRoom = [[M13Checkbox alloc] initWithTitle:@"Studio"];
    studioRoom.frame = CGRectMake(8, 220, 74, 30);
    studioRoom.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    studioRoom.titleLabel.textAlignment = NSTextAlignmentRight;
    studioRoom.checkState = M13CheckboxStateChecked;
    [studioRoom addTarget:self action:@selector(checkStudio:) forControlEvents:UIControlEventValueChanged];
    
    [_scrollViewContainer addSubview:studioRoom];
    
    bedroom1 = [[M13Checkbox alloc] initWithTitle:@"#1"];
    bedroom1.frame = CGRectMake(82, 220, 50, 30);
    bedroom1.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    bedroom1.titleLabel.textAlignment = NSTextAlignmentRight;
    [bedroom1 addTarget:self action:@selector(check1Bedroom:) forControlEvents:UIControlEventValueChanged];
    [_scrollViewContainer addSubview:bedroom1];
    
    bedroom2 = [[M13Checkbox alloc] initWithTitle:@"#2"];
    bedroom2.frame = CGRectMake(137, 220, 50, 30);
    bedroom2.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    bedroom2.titleLabel.textAlignment = NSTextAlignmentRight;
    [bedroom2 addTarget:self action:@selector(check2Bedrooms:) forControlEvents:UIControlEventValueChanged];
    [_scrollViewContainer addSubview:bedroom2];
    
    bedroom3 = [[M13Checkbox alloc] initWithTitle:@"#3"];
    bedroom3.frame = CGRectMake(192, 220, 50, 30);
    bedroom3.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    bedroom3.titleLabel.textAlignment = NSTextAlignmentRight;
    [bedroom3 addTarget:self action:@selector(check3Bedrooms:) forControlEvents:UIControlEventValueChanged];
    [_scrollViewContainer addSubview:bedroom3];
    
    bedroom4 = [[M13Checkbox alloc] initWithTitle:@"#4"];
    bedroom4.frame = CGRectMake(247, 220, 50, 30);
    bedroom4.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    bedroom4.titleLabel.textAlignment = NSTextAlignmentRight;
    [bedroom4 addTarget:self action:@selector(check4Bedrooms:) forControlEvents:UIControlEventValueChanged];
    [_scrollViewContainer addSubview:bedroom4];
    
    vacancyImmediate = [[M13Checkbox alloc] initWithTitle:@"Immediate"];
    vacancyImmediate.frame = CGRectMake(14, 258, 90, 30);
    vacancyImmediate.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    vacancyImmediate.titleLabel.textAlignment = NSTextAlignmentRight;
    vacancyImmediate.checkState = M13CheckboxStateChecked;
    [vacancyImmediate addTarget:self action:@selector(checkVacancyImmediate:) forControlEvents:UIControlEventValueChanged];
    [_scrollViewContainer addSubview:vacancyImmediate];
    
    vacancyShortTerm = [[M13Checkbox alloc] initWithTitle:@"Short Term"];
    vacancyShortTerm.frame = CGRectMake(100, 258, 100, 30);
    vacancyShortTerm.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    vacancyShortTerm.titleLabel.textAlignment = NSTextAlignmentRight;
    [vacancyShortTerm addTarget:self action:@selector(checkVacancyShortTerm:) forControlEvents:UIControlEventValueChanged];
    [_scrollViewContainer addSubview:vacancyShortTerm];
    
    vacancyNegociable = [[M13Checkbox alloc] initWithTitle:@"Negociable"];
    vacancyNegociable.frame = CGRectMake(200, 258, 100, 30);
    vacancyNegociable.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    vacancyNegociable.titleLabel.textAlignment = NSTextAlignmentRight;
    [vacancyNegociable addTarget:self action:@selector(checkVacancyNegociable:) forControlEvents:UIControlEventValueChanged];
    [_scrollViewContainer addSubview:vacancyNegociable];
    
    yourFeeLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 561, 200, 30)];
    yourFeeLabel.text = @"Your Fee:";
    yourFeeLabel.font = [UIFont systemFontOfSize:12.0f];
    [_scrollViewContainer addSubview:yourFeeLabel];
    
    fee3percent = [[M13Checkbox alloc] initWithTitle:@"3% of 1 mont rent"];
    fee3percent.checkAlignment = M13CheckboxAlignmentLeft;
    fee3percent.frame = CGRectMake(80, 561, 150, 30);
    fee3percent.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    fee3percent.titleLabel.textAlignment = NSTextAlignmentLeft;
    fee3percent.checkState = M13CheckboxStateChecked;
    [fee3percent addTarget:self action:@selector(checkFee3Percent:) forControlEvents:UIControlEventValueChanged];
    [_scrollViewContainer addSubview:fee3percent];
    
    fee4percent = [[M13Checkbox alloc] initWithTitle:@"4% of 1 mont rent"];
    fee4percent.checkAlignment = M13CheckboxAlignmentLeft;
    fee4percent.frame = CGRectMake(80, 561 + 30 + 4, 150, 30);
    fee4percent.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    fee4percent.titleLabel.textAlignment = NSTextAlignmentLeft;
    [fee4percent addTarget:self action:@selector(checkFee4Percent:) forControlEvents:UIControlEventValueChanged];
    [_scrollViewContainer addSubview:fee4percent];
    
    fee5percent = [[M13Checkbox alloc] initWithTitle:@"5% of 1 mont rent"];
    fee5percent.checkAlignment = M13CheckboxAlignmentLeft;
    fee5percent.frame = CGRectMake(80, 561 + 60 + 8, 150, 30);
    fee5percent.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    fee5percent.titleLabel.textAlignment = NSTextAlignmentLeft;
    [fee5percent addTarget:self action:@selector(checkFee5Percent:) forControlEvents:UIControlEventValueChanged];
    [_scrollViewContainer addSubview:fee5percent];
    
    willRentChangeLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 660, 200, 30)];
    willRentChangeLabel.text = @"Will your rent change?:";
    willRentChangeLabel.font = [UIFont systemFontOfSize:12.0f];
    [_scrollViewContainer addSubview:willRentChangeLabel];
    
    willRentChangeYes = [[M13Checkbox alloc] initWithTitle:@"Yes"];
    willRentChangeYes.checkAlignment = M13CheckboxAlignmentLeft;
    willRentChangeYes.frame = CGRectMake(160, 660, 150, 30);
    willRentChangeYes.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    willRentChangeYes.titleLabel.textAlignment = NSTextAlignmentLeft;
    willRentChangeYes.checkState = M13CheckboxStateChecked;
    [willRentChangeYes addTarget:self action:@selector(checkWillRentChangeYes:) forControlEvents:UIControlEventValueChanged];
    [_scrollViewContainer addSubview:willRentChangeYes];
    
    willRentChangeNo = [[M13Checkbox alloc] initWithTitle:@"No"];
    willRentChangeNo.checkAlignment = M13CheckboxAlignmentLeft;
    willRentChangeNo.frame = CGRectMake(160, 660 + 30 + 4, 150, 30);
    willRentChangeNo.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    willRentChangeNo.titleLabel.textAlignment = NSTextAlignmentLeft;
    [willRentChangeNo addTarget:self action:@selector(checkWillRentChangeNO:) forControlEvents:UIControlEventValueChanged];
    [_scrollViewContainer addSubview:willRentChangeNo];
    
    willRentChangeMaybe = [[M13Checkbox alloc] initWithTitle:@"Maybe"];
    willRentChangeMaybe.checkAlignment = M13CheckboxAlignmentLeft;
    willRentChangeMaybe.frame = CGRectMake(160, 660 + 60 + 8, 150, 30);
    willRentChangeMaybe.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    willRentChangeMaybe.titleLabel.textAlignment = NSTextAlignmentLeft;
    [willRentChangeMaybe addTarget:self action:@selector(checkWillRentChangeMaybe:) forControlEvents:UIControlEventValueChanged];
    [_scrollViewContainer addSubview:willRentChangeMaybe];
    

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

#pragma mark - Keyboard Notifications handlers

- (void)keyboardWasShown:(NSNotification*)aNotification
{
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

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    _scrollViewContainer.contentInset = lastScrollViewContentInset;
    _scrollViewContainer.scrollIndicatorInsets = lastScrollViewScrollIndicator;
    
    [_scrollViewContainer setContentOffset:lastScrollViewOffset animated:YES];
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(locationPin)
        [_mapView removeAnnotation:locationPin];
    
    if(CLLocationCoordinate2DIsValid(_apartmentLocation))
    {
        RTLog(@"location -> %f - %f", _apartmentLocation.latitude, _apartmentLocation.longitude);
        [locationPin setCoordinate:_apartmentLocation];
        [_mapView addAnnotation:locationPin];
        [MapUtils zoomToFitMarkersOnMap:_mapView];
    }
    

}

- (void)openFullScreenMap
{
    [self.navigationController pushViewController:[SelectLocationViewController new] animated:YES];
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
    //[self dismissKeyboard];
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

#pragma mark - Buttons actions

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
    if([self validateFields])
    {
        NSMutableDictionary *apartmentInfo = [NSMutableDictionary new];
        apartmentInfo[@"location"] = [NSString stringWithFormat:@"%f|%f", _apartmentLocation.latitude, _apartmentLocation.longitude];
        apartmentInfo[@"type"] = [NSNumber numberWithInteger:_apartmentType];
        apartmentInfo[@"rooms"] = rooms;
        apartmentInfo[@"fee"] = fee;
        apartmentInfo[@"rentWillChange"] = rentWillChange;
        apartmentInfo[@"vacancy"] = vacancy;
        apartmentInfo[@"description"] = _descriptionTextView.text;
        apartmentInfo[@"area"] = _areaTF.text;
        apartmentInfo[@"renewaldays"] = _daysRenewalTF.text;
        apartmentInfo[@"rent"] = _rentTF.text;
        apartmentInfo[@"locationName"] = _locationName;
        
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
                                           
                                       }];
                                   }];

                               }
                               else
                                   [UIAlertView showWithTitle:@"" message:@"An error occurred. Please try again!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
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
    
    if(_apartmentType < 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Select type!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
//    if(_roomsTextView.text.length == 0)
//    {
//        [UIAlertView showWithTitle:@"" message:@"Enter rooms description!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
//        return NO;
//    }
    
    if(rooms.count == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Select your room components!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(fee.count == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Select your fee!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(rentWillChange.count == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Select whether or not your rent will change!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(vacancy.count == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Select vacancy!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(_descriptionTextView.text.length == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Enter apartment's description!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(_areaTF.text.length == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"Enter apartment's area!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(_daysRenewalTF.text.length == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"You must specify the remaining days until renewal!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(_rentTF.text.length == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"You must specify the rent value for the apartment!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    if(_apartmentImages.count == 0)
    {
        [UIAlertView showWithTitle:@"" message:@"You must upload at leats one image!" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
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
    [vacancy removeObject:@VacancyNegociable];
    
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
    [vacancy removeObject:@VacancyNegociable];
    
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
        if (![vacancy containsObject:@VacancyNegociable])
            [vacancy addObject:@VacancyNegociable];
    }
    else
        [vacancy removeObject:@VacancyNegociable];
}
- (void)checkFee3Percent:(M13Checkbox *)checkbox
{
    fee4percent.checkState = M13CheckboxStateUnchecked;
    fee5percent.checkState = M13CheckboxStateUnchecked;
    
    [fee removeObject:@Fee4percent];
    [fee removeObject:@Fee5percent];
    
    if(fee3percent.checkState == M13CheckboxStateChecked)
    {
        if (![fee containsObject:@Fee3percent])
            [fee addObject:@Fee3percent];
    }
    else
        [fee removeObject:@Fee5percent];
}
- (void)checkFee4Percent:(M13Checkbox *)checkbox
{
    fee3percent.checkState = M13CheckboxStateUnchecked;
    fee5percent.checkState = M13CheckboxStateUnchecked;
    
    [fee removeObject:@Fee3percent];
    [fee removeObject:@Fee5percent];
    
    if(fee4percent.checkState == M13CheckboxStateChecked)
    {
        if (![fee containsObject:@Fee4percent])
            [fee addObject:@Fee4percent];
    }
    else
        [fee removeObject:@Fee4percent];
}
- (void)checkFee5Percent:(M13Checkbox *)checkbox
{
    fee4percent.checkState = M13CheckboxStateUnchecked;
    fee3percent.checkState = M13CheckboxStateUnchecked;
    
    [fee removeObject:@Fee4percent];
    [fee removeObject:@Fee3percent];
    
    if(fee5percent.checkState == M13CheckboxStateChecked)
    {
        if (![fee containsObject:@Fee5percent])
            [fee addObject:@Fee5percent];
    }
    else
        [fee removeObject:@Fee5percent];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
