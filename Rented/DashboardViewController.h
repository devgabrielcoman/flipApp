//
//  DashboardViewController.h
//  Rented
//
//  Created by Lucian ;;; on 23/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocation* currentLocation;

@property (weak, nonatomic) IBOutlet UIView* notificationCircle;
@property (weak, nonatomic) IBOutlet UILabel* notificationLabel;

-(void)showAdminOptions:(BOOL)visible;
- (IBAction)openMyPlace:(id)sender;
-(void)updateNotificationBadgeTo:(NSInteger) badgeNumber;

-(void)updateProfileData;
- (IBAction)logoutUser:(id)sender;
@end
