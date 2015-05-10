//
//  EnterDetailsViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 3/3/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "EnterDetailsViewController.h"



@interface EnterDetailsViewController ()

@end

@implementation UITextField (custom)
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 8, bounds.origin.y+2,
                      bounds.size.width - 16, bounds.size.height-4);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}
@end

@implementation EnterDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneButton setBackgroundColor:[UIColor whiteColor]];
    [doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];

    self.rentTextField.inputAccessoryView = doneButton;
    self.feeTextField.inputAccessoryView = doneButton;
    self.messageTextView.inputAccessoryView = doneButton;


    
    switch (self.state)
    {
        case stateRent:
        {
            [self.titleLabel setText:@"Current Rent"];
            [self.rentTextField setHidden:NO];
            [self.textFieldBackground setHidden:NO];
            if (self.rent)
            {
                [self.rentTextField setText:self.rent];
            }
            else
            {
                [self.rentTextField setText:@"$"];
            }
            [self.rentTextField becomeFirstResponder];
            break;
        }
        case stateFee:
        {
            [self.titleLabel setText:@"Takeover Fee"];
            [self.feeTextField setHidden:NO];
            [self.textFieldBackground setHidden:NO];
            if (self.fee)
            {
                [self.feeTextField setText:self.fee];
            }
            else
            {
                [self.feeTextField setText:@"$"];
            }
            [self.feeTextField becomeFirstResponder];
            break;
        }
        case stateMessage:
        {
            [self.titleLabel setText:@"Message"];
            [self.messageTextView setHidden:NO];
            if (self.message)
            {
                [self.messageTextView setText:self.message];
            }
            [self.messageTextView becomeFirstResponder];
            break;
        }
        default:
            break;
    }
    
}

- (void) enterDetailsFor:(NSInteger) state withValue:(NSString*)value
{
    self.state = state;
    switch (state)
    {
        case stateRent:
        {
            self.rent = value;
            break;
        }
        case stateFee:
        {
            self.fee = value;
            break;
        }
        case stateMessage:
        {
            self.message = value;
            break;
        }
        default:
            break;
    }

}

-(IBAction)done:(id)sender
{
    [self.rentTextField resignFirstResponder];
    [self.feeTextField resignFirstResponder];
    [self.messageTextView resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString=[textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length>0 && [[newString substringToIndex:1] isEqualToString:@"$"])
    {
        if (newString.length>4)
        {
            newString = [newString stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            if (newString.length==5)
            {
                newString =[NSString stringWithFormat:@"%@,%@",[newString substringToIndex:2],[newString substringFromIndex:2]];
            }
            else if (newString.length==6)
            {
                newString =[NSString stringWithFormat:@"%@,%@",[newString substringToIndex:3],[newString substringFromIndex:3]];
            }
            else if (newString.length==7)
            {
                newString =[NSString stringWithFormat:@"%@,%@",[newString substringToIndex:4],[newString substringFromIndex:4]];
            }else if (newString.length>7)
            {
                return NO;
            }
            
            textField.text= newString;
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    switch (self.state)
    {
        case stateRent:
        {
            if (![self.rentTextField.text isEqualToString:@"$"])
            {
                [self.delegate finishedEnteringValue:self.rentTextField.text forState:stateRent];
            }
            break;
        }
        case stateFee:
        {
            if (![self.feeTextField.text isEqualToString:@"$"])
            {
                [self.delegate finishedEnteringValue:self.feeTextField.text forState:stateFee];
            }
            break;
        }
        case stateMessage:
        {
            if (![self.messageTextView.text isEqualToString:@""])
            {
                [self.delegate finishedEnteringValue:self.messageTextView.text forState:stateMessage];
            }
            break;
        }
        default:
            break;
    }
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
