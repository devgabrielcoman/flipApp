//
//  EnterLeaseDetailsViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 3/5/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "EnterLeaseDetailsViewController.h"



@interface EnterLeaseDetailsViewController ()

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

@implementation EnterLeaseDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.picker1 setDate:[NSDate date]];
    NSDate* today = [NSDate date];
    NSDateComponents* components = [NSDateComponents new];
    [components setMonth:1];
    NSDate* date2 = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:today options:0];
    NSDateComponents* actualDate= [[NSCalendar currentCalendar] components:(NSMonthCalendarUnit | NSCalendarUnitYear) fromDate:date2];
    [actualDate setDay:1];
    date2 = [[NSCalendar currentCalendar] dateFromComponents:actualDate];
    
    [self.picker2 setDate:date2];

    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMMM d, YYYY"];
    [self.date1Button setTitle:[formatter stringFromDate:today] forState:UIControlStateNormal];
    [self.date2Button setTitle:[formatter stringFromDate:today] forState:UIControlStateNormal];
    

    if (self.option==0)
    {
        [self.immediatelyButton setSelected:YES];
    }
    else
    {
        if (self.option==1)
        {
            [self.flexibleButton setSelected:YES];
        }
        else
        {
            if (self.option ==2)
            {
                [self.excatDateSwith setOn:YES];

            }
        }
    }
    
    if(self.date1)
    {
        [self.picker1 setDate:self.date1];
    }
    else
    {
        [self.picker1 setDate:[NSDate date]];
    }
    if (self.date2)
    {
        [self.picker2 setDate:self.date2];
    }
    else
    {
        [self.picker2 setDate:date2];
    }
    
    [self.picker1 setMinimumDate:[NSDate date]];
    [self.picker2 setMinimumDate:[NSDate date]];
    
    [self picker1ValueChanged:nil];
    [self picker2ValueChanged:nil];
}

-(void)viewDidLayoutSubviews
{
    if (self.option ==2 && self.leaseEndContainer.frame.origin.y<self.date1Container.frame.origin.y + self.date1Container.frame.size.height)
    {
        CGRect newSeparator1Frame = self.separator1.frame;
        newSeparator1Frame.origin.y = self.date1Container.frame.origin.y + self.date1Container.frame.size.height;
        CGRect newLeaseEndFrame = self.leaseEndContainer.frame;
        newLeaseEndFrame.origin.y = newSeparator1Frame.origin.y + newSeparator1Frame.size.height;
        CGRect newSeparator2Frame = self.separator2.frame;
        newSeparator2Frame.origin.y = newLeaseEndFrame.origin.y + newLeaseEndFrame.size.height;
        CGRect newDate2Frame = self.date2Container.frame;
        newDate2Frame.origin.y =newSeparator2Frame.origin.y + newSeparator2Frame.size.height;
        CGRect newSeparator3Frame = self.separator3.frame;
        newSeparator3Frame.origin.y = newDate2Frame.origin.y + newDate2Frame.size.height;
        CGRect newDate2PickerFrame = self.date2PickerContrainer.frame;
        newDate2PickerFrame.origin.y = newSeparator3Frame.origin.y + newSeparator3Frame.size.height;
        CGRect newLastViewFrame = self.lastView.frame;
        newLastViewFrame.origin.y = newSeparator3Frame.origin.y + newSeparator3Frame.size.height;
        
        
        [self.separator1 setFrame:newSeparator1Frame];
        [self.leaseEndContainer setFrame:newLeaseEndFrame];
        [self.separator2 setFrame:newSeparator2Frame];
        [self.date2Container setFrame: newDate2Frame];
        [self.separator3 setFrame: newSeparator3Frame];
        [self.lastView setFrame:newLastViewFrame];
        [self.date2PickerContrainer setFrame:newDate2PickerFrame];
        
        self.date1IsVisible = YES;

        [self updateContentSize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)enterLeaseDetailsWithOption:(NSInteger) option date1: (NSDate*) date1 andDate2:(NSDate*) date2
{
    self.date1= date1;
    self.date2= date2;
    self.option= option;

}


-(IBAction)immediatelyButtonTapped:(id) sender
{
    if ([self.immediatelyButton isSelected])
    {
        [self.immediatelyButton setSelected:NO];
        self.option = -1;
    }
    else
    {
        [self.immediatelyButton setSelected:YES];
        [self.flexibleButton setSelected:NO];
        [self.excatDateSwith setOn:NO];
        if (self.date1PickerIsVisible)
        {
            [self hideDate1Picker];

        }
        if (self.date1IsVisible)
        {
            [self hideDate1];
        }
        self.option =0;
    }
}

-(IBAction)flexibleButtonTapped:(id) sender
{
    if ([self.flexibleButton isSelected])
    {
        [self.flexibleButton setSelected:NO];
        self.option = -1;
    }
    else
    {
        [self.flexibleButton setSelected:YES];
        [self.immediatelyButton setSelected:NO];
        [self.excatDateSwith setOn:NO];
        if (self.date1IsVisible)
        {
            [self hideDate1];
  
        }
        if (self.date1PickerIsVisible)
        {
            [self hideDate1Picker];
        }
        self.option =1;
    }
}
-(IBAction)swtichValueChanged:(id)sender
{
    if ([self.excatDateSwith isOn])
    {
        [self.flexibleButton setSelected:NO];
        [self.immediatelyButton setSelected:NO];
        self.option =2;
        [self showDate1];
    }
    else
    {
        [self hideDate1];
        self.option =-1;
    }
}

-(IBAction)date1ButtonTapped:(id)sender
{
    if (!self.date1PickerIsVisible)
    {
        [self showDate1Picker];
    }
    else
    {
        [self hideDate1Picker];
    }
}
-(IBAction)date2ButtonTapped:(id)sender
{
    if (!self.date2PickerIsVisible)
    {
        [self showDate2Picker];
    }
    else
    {
        [self hideDate2Picker];
    }
}

-(void)hideDate1Picker
{
    CGRect newLeaseEndFrame = self.leaseEndContainer.frame;
    newLeaseEndFrame.origin.y = self.separator1.frame.origin.y + self.separator1.frame.size.height;
    CGRect newSeparator2Frame = self.separator2.frame;
    newSeparator2Frame.origin.y = newLeaseEndFrame.origin.y + newLeaseEndFrame.size.height;
    CGRect newDate2Frame = self.date2Container.frame;
    newDate2Frame.origin.y =newSeparator2Frame.origin.y + newSeparator2Frame.size.height;
    CGRect newSeparator3Frame = self.separator3.frame;
    newSeparator3Frame.origin.y = newDate2Frame.origin.y + newDate2Frame.size.height;
    CGRect newDate2PickerFrame = self.date2PickerContrainer.frame;
    newDate2PickerFrame.origin.y = newSeparator3Frame.origin.y + newSeparator3Frame.size.height;
    CGRect newLastViewFrame = self.lastView.frame;

    if (self.date2PickerIsVisible)
    {

        newLastViewFrame.origin.y = newDate2PickerFrame.origin.y + newDate2PickerFrame.size.height;
    }
    else
    {
        newLastViewFrame.origin.y = newSeparator3Frame.origin.y + newSeparator3Frame.size.height;
    }

    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [self.leaseEndContainer setFrame:newLeaseEndFrame];
                         [self.separator2 setFrame:newSeparator2Frame];
                         [self.date2Container setFrame: newDate2Frame];
                         [self.separator3 setFrame: newSeparator3Frame];
                         [self.lastView setFrame:newLastViewFrame];
                         [self.date2PickerContrainer setFrame:newDate2PickerFrame];
                         
                         
                     }
                     completion:^(BOOL finished) {
                         [self.date1PickerContainer setHidden:YES];
                                 [self updateContentSize];
                     }];
                         

    
    self.date1PickerIsVisible=NO;

}
-(void)showDate1Picker
{

    [self.date1PickerContainer setHidden:NO];

    CGRect newLeaseEndFrame = self.leaseEndContainer.frame;
    newLeaseEndFrame.origin.y = self.date1PickerContainer.frame.origin.y + self.date1PickerContainer.frame.size.height;
    CGRect newSeparator2Frame = self.separator2.frame;
    newSeparator2Frame.origin.y = newLeaseEndFrame.origin.y + newLeaseEndFrame.size.height;
    CGRect newDate2Frame = self.date2Container.frame;
    newDate2Frame.origin.y =newSeparator2Frame.origin.y + newSeparator2Frame.size.height;
    CGRect newSeparator3Frame = self.separator3.frame;
    newSeparator3Frame.origin.y = newDate2Frame.origin.y + newDate2Frame.size.height;
    CGRect newDate2PickerFrame = self.date2PickerContrainer.frame;
    newDate2PickerFrame.origin.y = newSeparator3Frame.origin.y + newSeparator3Frame.size.height;
    CGRect newLastViewFrame = self.lastView.frame;

    if (self.date2PickerIsVisible)
    {
        
        newLastViewFrame.origin.y = newDate2PickerFrame.origin.y + newDate2PickerFrame.size.height;
    }
    else
    {
        newLastViewFrame.origin.y = newSeparator3Frame.origin.y + newSeparator3Frame.size.height;
    }
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [self.leaseEndContainer setFrame:newLeaseEndFrame];
                         [self.separator2 setFrame:newSeparator2Frame];
                         [self.date2Container setFrame: newDate2Frame];
                         [self.separator3 setFrame: newSeparator3Frame];
                         [self.lastView setFrame:newLastViewFrame];
                         [self.date2PickerContrainer setFrame:newDate2PickerFrame];
                         
                     }
                     completion:^(BOOL finished) {

                     }];
    
    self.date1PickerIsVisible = YES;
    [self updateContentSize];
}
-(void)hideDate1
{
    CGRect newSeparator1Frame = self.separator1.frame;
    newSeparator1Frame.origin.y = self.table.frame.origin.y + self.table.frame.size.height;
    CGRect newLeaseEndFrame = self.leaseEndContainer.frame;
    newLeaseEndFrame.origin.y = newSeparator1Frame.origin.y + newSeparator1Frame.size.height;
    CGRect newSeparator2Frame = self.separator2.frame;
    newSeparator2Frame.origin.y = newLeaseEndFrame.origin.y + newLeaseEndFrame.size.height;
    CGRect newDate2Frame = self.date2Container.frame;
    newDate2Frame.origin.y =newSeparator2Frame.origin.y + newSeparator2Frame.size.height;
    CGRect newSeparator3Frame = self.separator3.frame;
    newSeparator3Frame.origin.y = newDate2Frame.origin.y + newDate2Frame.size.height;
    CGRect newDate2PickerFrame = self.date2PickerContrainer .frame;
    newDate2PickerFrame.origin.y=  newSeparator3Frame.origin.y + newSeparator3Frame.size.height;
    CGRect newLastViewFrame = self.lastView.frame;

    if (self.date2PickerIsVisible)
    {
        
        newLastViewFrame.origin.y = newDate2PickerFrame.origin.y + newDate2PickerFrame.size.height;
    }
    else
    {
        newLastViewFrame.origin.y = newSeparator3Frame.origin.y + newSeparator3Frame.size.height;
    }
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [self.separator1 setFrame:newSeparator1Frame];
                         [self.leaseEndContainer setFrame:newLeaseEndFrame];
                         [self.separator2 setFrame:newSeparator2Frame];
                         [self.date2Container setFrame: newDate2Frame];
                         [self.separator3 setFrame: newSeparator3Frame];
                         [self.lastView setFrame:newLastViewFrame];
                         [self.date2PickerContrainer setFrame:newDate2PickerFrame];

                     }
                     completion:^(BOOL finished) {
                         [self updateContentSize];
 
                     }];
    
    self.date1IsVisible = NO;
}
-(void)showDate1
{
    CGRect newSeparator1Frame = self.separator1.frame;
    newSeparator1Frame.origin.y = self.date1Container.frame.origin.y + self.date1Container.frame.size.height;
    CGRect newLeaseEndFrame = self.leaseEndContainer.frame;
    newLeaseEndFrame.origin.y = newSeparator1Frame.origin.y + newSeparator1Frame.size.height;
    CGRect newSeparator2Frame = self.separator2.frame;
    newSeparator2Frame.origin.y = newLeaseEndFrame.origin.y + newLeaseEndFrame.size.height;
    CGRect newDate2Frame = self.date2Container.frame;
    newDate2Frame.origin.y =newSeparator2Frame.origin.y + newSeparator2Frame.size.height;
    CGRect newSeparator3Frame = self.separator3.frame;
    newSeparator3Frame.origin.y = newDate2Frame.origin.y + newDate2Frame.size.height;
    CGRect newDate2PickerFrame = self.date2PickerContrainer.frame;
    newDate2PickerFrame.origin.y = newSeparator3Frame.origin.y + newSeparator3Frame.size.height;
    CGRect newLastViewFrame = self.lastView.frame;

    if (self.date2PickerIsVisible)
    {
        
        newLastViewFrame.origin.y = newDate2PickerFrame.origin.y + newDate2PickerFrame.size.height;
    }
    else
    {
        newLastViewFrame.origin.y = newSeparator3Frame.origin.y + newSeparator3Frame.size.height;
    }
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [self.separator1 setFrame:newSeparator1Frame];
                         [self.leaseEndContainer setFrame:newLeaseEndFrame];
                         [self.separator2 setFrame:newSeparator2Frame];
                         [self.date2Container setFrame: newDate2Frame];
                         [self.separator3 setFrame: newSeparator3Frame];
                         [self.lastView setFrame:newLastViewFrame];
                         [self.date2PickerContrainer setFrame:newDate2PickerFrame];

                         
                            }
                     completion:^(BOOL finished) {
        
                            }];
    
    self.date1IsVisible = YES;
    [self updateContentSize];
}
-(void)hideDate2Picker
{
    
    CGRect newLastViewFrame = self.lastView.frame;
    newLastViewFrame.origin.y = self.separator3.frame.origin.y + self.separator3.frame.size.height;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         
                         [self.lastView setFrame:newLastViewFrame];
                         
                     }
                     completion:^(BOOL finished) {
                         [self.date2PickerContrainer setHidden:YES];
                         [self updateContentSize];

                     }];
    
    self.date2PickerIsVisible = NO;
}
-(void)showDate2Picker
{

    [self.date2PickerContrainer setHidden:NO];

    CGRect newLastViewFrame = self.lastView.frame;
    newLastViewFrame.origin.y = self.date2PickerContrainer.frame.origin.y + self.date2PickerContrainer.frame.size.height;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         

                         [self.lastView setFrame:newLastViewFrame];
                         
                     }
                     completion:^(BOOL finished) {

                     }];
    
    self.date2PickerIsVisible = YES;
    [self updateContentSize];
}

-(IBAction)doneButtonTapped:(id)sender
{
    NSDate*date1 = nil;
    if (self.option ==2)
    {
        date1 = self.picker1.date;
    }
    [self.delegate finishedEnteringLeaeDetailsWithOption:self.option date1:date1 date2:self.picker2.date];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(IBAction)picker1ValueChanged:(id)sender
{
    NSDateFormatter* formatter= [NSDateFormatter new];
    [formatter setDateFormat:@"MMMM d, YYYY"];
    [self.date1Button setTitle:[formatter stringFromDate:self.picker1.date] forState:UIControlStateNormal];
}

-(IBAction)picker2ValueChanged:(id)sender
{
    NSDateFormatter* formatter= [NSDateFormatter new];
    [formatter setDateFormat:@"MMMM d, YYYY"];
    [self.date2Button setTitle:[formatter stringFromDate:self.picker2.date] forState:UIControlStateNormal];
}
-(void)updateContentSize
{
    CGFloat size = 370;
    if (self.date1IsVisible)
    {
        size+= self.date1Container.frame.size.height;
        if (self.date1PickerIsVisible)
        {
            size+=self.date1PickerContainer.frame.size.height;
        }
    }
    if (self.date2PickerIsVisible)
    {
        size+= self.date2PickerContrainer.frame.size.height;
    }
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                     } completion:^(BOOL finished) {
                         [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, size)];

                     }];
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
