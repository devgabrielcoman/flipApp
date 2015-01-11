//
//  PreferencesView.m
//  Rented
//
//  Created by Lucian Gherghel on 11/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "PreferencesSeparateView.h"
#import "UIColor+ColorFromHexString.h"

@implementation PreferencesSeparateView

- (void)awakeFromNib
{
    
#warning just a solution for the moment
    CGFloat remainedWidth = wScr - 94;
    
    _minRentTF = [[UITextField alloc] initWithFrame:CGRectMake(76, 162, remainedWidth/2, 40)];
    _minRentTF.placeholder = @"Min";
    [self setupTextField:_minRentTF];
    
    _maxRentTF = [[UITextField alloc] initWithFrame:CGRectMake(76+remainedWidth/2+10, 162, remainedWidth/2, 40)];
    _maxRentTF.placeholder = @"Max";
    [self setupTextField:_maxRentTF];
    
    [self addSubview:_minRentTF];
    [self addSubview:_maxRentTF];
    
    _minSquareFtTF = [[UITextField alloc] initWithFrame:CGRectMake(76, 210, remainedWidth/2, 40)];
    _minSquareFtTF.placeholder = @"Min";
    [self setupTextField:_minSquareFtTF];
    
    _maxSquareFtTF = [[UITextField alloc] initWithFrame:CGRectMake(76+remainedWidth/2+10, 210, remainedWidth/2, 40)];
    _maxSquareFtTF.placeholder = @"Max";
    [self setupTextField:_maxSquareFtTF];
    
    [self addSubview:_minSquareFtTF];
    [self addSubview:_maxSquareFtTF];
    
    UITapGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    dismissGesture.numberOfTapsRequired = 1;
    dismissGesture.numberOfTouchesRequired = 1;
    dismissGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:dismissGesture];
    
    [self blueBackgroundForLabel:_leaseRenewalLbl];
    [self blueBackgroundForLabel:_vacancyLbl];
    [self blueBackgroundForLabel:_rentLbl];
    [self blueBackgroundForLabel:_squareFtLbl];
    [self blueBackgroundForLabel:_roomsLbl];
    
    [self configureSlider];
    
    [self addCheckboxes];
    
    rooms= [NSMutableArray new];
    vacancyTypes = [NSMutableArray new];
}

- (void)setupTextField:(UITextField *)textField
{
    textField.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f].CGColor;
    textField.layer.borderWidth = 0.5f;
    textField.layer.cornerRadius = 4.0f;
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleNone;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.font = [UIFont systemFontOfSize:13.0f];
}

- (void)setEqualHeightForTextField:(UITextField *)textField
{
    CGFloat remainedWidth = wScr - 94;
    CGRect currentTFFrame = textField.frame;
    currentTFFrame.size.width = remainedWidth/2;
    textField.frame = currentTFFrame;
}

- (void)addCheckboxes
{
    studioRoom = [[M13Checkbox alloc] initWithTitle:@"Studio"];
    studioRoom.frame = CGRectMake(76, 263, 70, 30);
    studioRoom.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    studioRoom.titleLabel.textAlignment = NSTextAlignmentRight;
    studioRoom.checkState = M13CheckboxStateChecked;
    [studioRoom addTarget:self action:@selector(checkStudio:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:studioRoom];
    
    bedroom1 = [[M13Checkbox alloc] initWithTitle:@"1"];
    bedroom1.frame = CGRectMake(studioRoom.frame.origin.x+studioRoom.frame.size.width, 263, 40, 30);
    bedroom1.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    bedroom1.titleLabel.textAlignment = NSTextAlignmentRight;
    [bedroom1 addTarget:self action:@selector(check1Bedroom:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:bedroom1];
    
    bedroom2 = [[M13Checkbox alloc] initWithTitle:@"2"];
    bedroom2.frame = CGRectMake(bedroom1.frame.origin.x+bedroom1.frame.size.width+1, 263, 40, 30);
    bedroom2.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    bedroom2.titleLabel.textAlignment = NSTextAlignmentRight;
    [bedroom2 addTarget:self action:@selector(check2Bedrooms:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:bedroom2];
    
    bedroom3 = [[M13Checkbox alloc] initWithTitle:@"3"];
    bedroom3.frame = CGRectMake(bedroom2.frame.origin.x+bedroom2.frame.size.width+1, 263, 40, 30);
    bedroom3.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    bedroom3.titleLabel.textAlignment = NSTextAlignmentRight;
    [bedroom3 addTarget:self action:@selector(check3Bedrooms:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:bedroom3];
    
    bedroom4 = [[M13Checkbox alloc] initWithTitle:@"4"];
    bedroom4.frame = CGRectMake(bedroom3.frame.origin.x+bedroom3.frame.size.width+1, 263, 40, 30);
    bedroom4.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    bedroom4.titleLabel.textAlignment = NSTextAlignmentRight;
    [bedroom4 addTarget:self action:@selector(check4Bedrooms:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:bedroom4];
    
    vacancyImmediate = [[M13Checkbox alloc] initWithTitle:@"Immediate"];
    vacancyImmediate.frame = CGRectMake(_vacancyLbl.frame.origin.x+_vacancyLbl.frame.size.width+8, _leaseRenewalLbl.frame.origin.y+_leaseRenewalLbl.frame.size.height+8, 100, 30);
    vacancyImmediate.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    vacancyImmediate.titleLabel.textAlignment = NSTextAlignmentRight;
    vacancyImmediate.checkState = M13CheckboxStateChecked;
    [vacancyImmediate addTarget:self action:@selector(checkVacancyImmediate:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:vacancyImmediate];
    
    vacancyShortTerm = [[M13Checkbox alloc] initWithTitle:@"Short Term"];
    vacancyShortTerm.frame = CGRectMake(_vacancyLbl.frame.origin.x+_vacancyLbl.frame.size.width+8, vacancyImmediate.frame.origin.y+30, 100, 30);
    vacancyShortTerm.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    vacancyShortTerm.titleLabel.textAlignment = NSTextAlignmentRight;
    [vacancyShortTerm addTarget:self action:@selector(checkVacancyShortTerm:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:vacancyShortTerm];
    
    vacancyNegociable = [[M13Checkbox alloc] initWithTitle:@"Negociable"];
    vacancyNegociable.frame = CGRectMake(_vacancyLbl.frame.origin.x+_vacancyLbl.frame.size.width+10, vacancyShortTerm.frame.origin.y+30, 99, 30);
    vacancyNegociable.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    vacancyNegociable.titleLabel.textAlignment = NSTextAlignmentRight;
    [vacancyNegociable addTarget:self action:@selector(checkVacancyNegociable:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:vacancyNegociable];
}

- (void)configureSlider
{
    self.leaseRenewalSlider.minimumValue = 0;
    self.leaseRenewalSlider.maximumValue = 365;
    
    self.leaseRenewalSlider.lowerValue = 0;
    self.leaseRenewalSlider.upperValue = 365;
    
    self.leaseRenewalSlider.minimumRange = 10;
    
    lowerLabel = [[UILabel alloc] initWithFrame:CGRectMake(_leaseRenewalLbl.frame.origin.x+_leaseRenewalLbl.frame.size.width+14, self.leaseRenewalSlider.frame.origin.y-26, 30, 30)];
    upperLabel = [[UILabel alloc] initWithFrame:CGRectMake(wScr-10-30,
                                                           self.leaseRenewalSlider.frame.origin.y-26, 30, 30)];
    
    lowerLabel.font = [UIFont systemFontOfSize:13];
    lowerLabel.textAlignment = NSTextAlignmentCenter;
    upperLabel.font = [UIFont systemFontOfSize:13];
    upperLabel.textAlignment = NSTextAlignmentCenter;
    
    lowerLabel.text = @"0";
    upperLabel.text = @"365";
    
    [self addSubview:lowerLabel];
    [self addSubview:upperLabel];
}

- (void)updateSliderLabels
{
    CGPoint lowerCenter;
    lowerCenter.x = (self.leaseRenewalSlider.lowerCenter.x + self.leaseRenewalSlider.frame.origin.x);
    lowerCenter.y = (self.leaseRenewalSlider.center.y - 30.0f);
    lowerLabel.center = lowerCenter;
    lowerLabel.text = [NSString stringWithFormat:@"%d", (int)self.leaseRenewalSlider.lowerValue];
    
    CGPoint upperCenter;
    upperCenter.x = (self.leaseRenewalSlider.upperCenter.x + self.leaseRenewalSlider.frame.origin.x);
    upperCenter.y = (self.leaseRenewalSlider.center.y - 30.0f);
    upperLabel.center = upperCenter;
    upperLabel.text = [NSString stringWithFormat:@"%d", (int)self.leaseRenewalSlider.upperValue];
}

- (void)blueBackgroundForLabel:(UILabel *)label
{
    label.backgroundColor = [UIColor colorFromHexString:@"47a0db"];
    label.layer.cornerRadius = 4.0;
    label.layer.masksToBounds = YES;
    label.textColor = [UIColor whiteColor];
}

- (IBAction)sliderValueChanged:(id)sender
{
    [self updateSliderLabels];
}

- (void)dismissKeyboard
{
    [self endEditing:YES];
}

#pragma mark - UITextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyboard];
    return YES;
}

#pragma mark - Checkbox action handlers

- (void)checkStudio:(M13Checkbox *)checkbox
{
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
    if(vacancyImmediate.checkState == M13CheckboxStateChecked)
    {
        if (![vacancyTypes containsObject:@VacancyImmediate])
            [vacancyTypes addObject:@VacancyImmediate];
    }
    else
        [vacancyTypes removeObject:@VacancyImmediate];
}

- (void)checkVacancyShortTerm:(M13Checkbox *)checkbox
{
    if(vacancyShortTerm.checkState == M13CheckboxStateChecked)
    {
        if (![vacancyTypes containsObject:@VacancyShortTerm])
            [vacancyTypes addObject:@VacancyShortTerm];
    }
    else
        [vacancyTypes removeObject:@VacancyShortTerm];
    
}

- (void)checkVacancyNegociable:(M13Checkbox *)checkbox
{
    if(vacancyNegociable.checkState == M13CheckboxStateChecked)
    {
        if (![vacancyTypes containsObject:@VacancyNegociable])
            [vacancyTypes addObject:@VacancyNegociable];
    }
    else
        [vacancyTypes removeObject:@VacancyNegociable];
}

@end
