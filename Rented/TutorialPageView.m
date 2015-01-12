//
//  TutorialPageView.m
//  Rented
//
//  Created by macmini on 1/12/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "TutorialPageView.h"

@implementation TutorialPageView{
    NSString *imgName;
}


-(id)initWithImageName:(NSString *)imageName{
    self = [[NSBundle mainBundle] loadNibNamed:@"TutorialPageView" owner:nil options:nil][0];
 
    imgName = imageName;
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.imageView setImage:[UIImage imageNamed:imgName]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
