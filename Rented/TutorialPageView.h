//
//  TutorialPageView.h
//  Rented
//
//  Created by macmini on 1/12/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialPageView : UIViewController;


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage* image;
@property (nonatomic) NSInteger index;

@end
