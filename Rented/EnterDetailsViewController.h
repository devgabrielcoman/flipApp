//
//  EnterDetailsViewController.h
//  Rented
//
//  Created by Cristian Olteanu on 3/3/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

#define stateRent       0
#define stateFee        1
#define stateMessage    2

@protocol EnterDetailsViewControllerDelegate <NSObject>

-(void)finishedEnteringValue:(NSString*)value forState:(NSInteger) state;

@end

@interface EnterDetailsViewController : UIViewController <UITextFieldDelegate>

@property(nonatomic, weak) id<EnterDetailsViewControllerDelegate> delegate;

- (void) enterDetailsFor:(NSInteger) state withValue:(NSString*)value;

@property (nonatomic,weak) IBOutlet UILabel* titleLabel;

@property (nonatomic,weak) IBOutlet UITextField*    rentTextField;
@property (nonatomic,weak) IBOutlet UITextField*    feeTextField;
@property (nonatomic,weak) IBOutlet UITextView*     messageTextView;
@property (nonatomic,weak) IBOutlet UIImageView*    textFieldBackground;

@property(nonatomic) NSInteger state;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSString* rent;
@property (nonatomic, strong) NSString* fee;

@end
