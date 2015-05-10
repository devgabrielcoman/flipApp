//
//  EnterAddressViewController.h
//  Rented
//
//  Created by Cristian Olteanu on 3/5/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRAutocompletionDelegate.h"

@protocol EnterAddressViewControllerDelegate <NSObject>

-(void)finishedEnteringAddress:(CLLocationCoordinate2D)location andString:(NSString*)string;

@end

@interface EnterAddressViewController : UIViewController <TRAutocompletionDelegate>

@property (nonatomic, weak) id<EnterAddressViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UITextField* addressTextField;

@property (nonatomic) CLLocationCoordinate2D apartmentLocation;
@property (nonatomic) NSString* addressString;

-(void)customiseWithString:(NSString*) string;

@end
