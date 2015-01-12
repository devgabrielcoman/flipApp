//
//  FacebookFriend.h
//  Rented
//
//  Created by Gherghel Lucian on 12/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "NoInternetConnectionView.h"
#import "MBProgressHUD.h"
#import "AFNetworkReachabilityManager.h"

static MBProgressHUD *noInternetConnectionHud;
static MBProgressHUD *internetConnectionBack;

static BOOL internetConnectionDown;

@implementation NoInternetConnection

+ (void)displayNoInternetConnection
{
    if(![[AFNetworkReachabilityManager sharedManager]isReachable] && !internetConnectionDown)
    {
        [internetConnectionBack removeFromSuperview];
        if(!noInternetConnectionHud)
        {
            noInternetConnectionHud = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
            noInternetConnectionHud.mode = MBProgressHUDModeCustomView;
            UIView *customView = [[UIView alloc] init];
            UIImageView *exclamationTriangle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-connection"]];
            [customView setFrame:CGRectMake(noInternetConnectionHud.frame.size.width-noInternetConnectionHud.frame.size.width/2-30.0, 0, 45.0, 45)];
            [customView addSubview:exclamationTriangle];
            customView.backgroundColor = [UIColor clearColor];
            noInternetConnectionHud.customView = customView;
            noInternetConnectionHud.labelText = @"No Internet Connection!";
            noInternetConnectionHud.userInteractionEnabled = NO;
        }
        
        [[UIApplication sharedApplication].keyWindow addSubview:noInternetConnectionHud];
        [noInternetConnectionHud show:YES];
        [noInternetConnectionHud setMinShowTime:1.0];
        [noInternetConnectionHud hide:YES afterDelay:2.5];
        
        internetConnectionDown = YES;
    }
}

+ (void)internetConnectionAvailable
{
    if([[AFNetworkReachabilityManager sharedManager]isReachable])
    {
        if(internetConnectionDown)
        {
            [noInternetConnectionHud removeFromSuperview];
            if(!internetConnectionBack)
            {
                internetConnectionBack = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
                internetConnectionBack.mode = MBProgressHUDModeCustomView;
                UIView *customView = [[UIView alloc] init];
                UIImageView *exclamationTriangle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"connection"]];
                [customView setFrame:CGRectMake(internetConnectionBack.frame.size.width-internetConnectionBack.frame.size.width/2-30.0, 0, 45.0, 45)];
                [customView addSubview:exclamationTriangle];
                customView.backgroundColor = [UIColor clearColor];
                internetConnectionBack.customView = customView;
                internetConnectionBack.labelText = @"Internet Connection";
                internetConnectionBack.userInteractionEnabled = NO;
            }
            
            [[UIApplication sharedApplication].keyWindow addSubview:internetConnectionBack];
            [internetConnectionBack show:YES];
            [internetConnectionBack setMinShowTime:1.0];
            [internetConnectionBack hide:YES afterDelay:2.5];
            
            internetConnectionDown = NO;
        }
    }
}

@end

