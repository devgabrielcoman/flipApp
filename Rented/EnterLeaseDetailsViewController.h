//
//  EnterLeaseDetailsViewController.h
//  Rented
//
//  Created by Cristian Olteanu on 3/5/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EnterLeaseDetailsViewControllerDelegate <NSObject>

-(void)finishedEnteringLeaeDetailsWithOption: (NSInteger) option date1: (NSDate*) date1 date2: (NSDate*)date2;

@end

@interface EnterLeaseDetailsViewController : UIViewController 

@property (nonatomic, weak) id<EnterLeaseDetailsViewControllerDelegate> delegate;

@property (nonatomic) BOOL date1IsVisible;
@property (nonatomic) BOOL date1PickerIsVisible;
@property (nonatomic) BOOL date2PickerIsVisible;

@property (nonatomic) NSInteger option;
@property (nonatomic, strong) NSDate* date1;
@property (nonatomic, strong) NSDate* date2;



@property (nonatomic, weak) IBOutlet UIButton* immediatelyButton;
@property (nonatomic, weak) IBOutlet UIButton* flexibleButton;
@property (nonatomic, weak) IBOutlet UISwitch* excatDateSwith;

@property (nonatomic, weak) IBOutlet UIButton* date1Button;
@property (nonatomic, weak) IBOutlet UIButton* date2Button;

@property (nonatomic, weak) IBOutlet UIDatePicker* picker1;
@property (nonatomic, weak) IBOutlet UIDatePicker* picker2;

@property (nonatomic, weak) IBOutlet UIView* date1PickerContainer;
@property (nonatomic, weak) IBOutlet UIView* date2PickerContrainer;

@property (nonatomic, weak) IBOutlet UIView* separator1;
@property (nonatomic, weak) IBOutlet UIView* separator2;
@property (nonatomic, weak) IBOutlet UIView* separator3;
@property (nonatomic, weak) IBOutlet UIView* lastView;
@property (nonatomic, weak) IBOutlet UIView* date1Container;
@property (nonatomic, weak) IBOutlet UIView* table;
@property (nonatomic, weak) IBOutlet UIView* leaseEndContainer;
@property (nonatomic, weak) IBOutlet UIView* date2Container;
@property (nonatomic, weak) IBOutlet UIView* containerView;
@property (nonatomic,weak)  IBOutlet UIScrollView* scrollView;

-(void)enterLeaseDetailsWithOption:(NSInteger) option date1: (NSDate*) date1 andDate2:(NSDate*) date2;
@end
