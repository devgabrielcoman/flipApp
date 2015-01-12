//
//  TutorialPageView.h
//  Rented
//
//  Created by macmini on 1/12/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialPageView : UIView

-(id)initWithImageName:(NSString *)imageName;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
