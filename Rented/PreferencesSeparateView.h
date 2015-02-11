//
//  PreferencesView.h
//  Rented
//
//  Created by Lucian Gherghel on 11/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"
#import "M13Checkbox.h"

@interface PreferencesSeparateView : UIView<UITextFieldDelegate>
{
    UILabel *lowerLabel;
    UILabel *upperLabel;
    
    M13Checkbox *vacancyImmediate;
    M13Checkbox *vacancyShortTerm;
    M13Checkbox *vacancyNegociable;
    
    M13Checkbox *studioRoom;
    M13Checkbox *bedroom1;
    M13Checkbox *bedroom2;
    M13Checkbox *bedroom3;
    M13Checkbox *bedroom4;
    
    M13Checkbox *everywhere;
    
    NSMutableArray *vacancyTypes;
    NSMutableArray *rooms;
    
    M13Checkbox *showOnlyRentalInMyNetwork;
    M13Checkbox *hideFacebookProfileCheckbox;
    
    NSInteger showRentalsFromUserNetork;
    NSInteger hideFacebookProfile;
}

@property (weak, nonatomic) IBOutlet NMRangeSlider *leaseRenewalSlider;
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UILabel *leaseRenewalLbl;
@property (weak, nonatomic) IBOutlet UILabel *vacancyLbl;
@property (weak, nonatomic) IBOutlet UILabel *rentLbl;
@property UITextField *minRentTF;
@property  UITextField *maxRentTF;
@property (weak, nonatomic) IBOutlet UILabel *squareFtLbl;
@property UITextField *minSquareFtTF;
@property UITextField *maxSquareFtTF;
@property (weak, nonatomic) IBOutlet UILabel *roomsLbl;
@property (weak, nonatomic) IBOutlet UILabel *locationLbl;
@property UITextField *locationTF;


@end
