//
//  SelectListingPhotosViewController.h
//  Rented
//
//  Created by Cristian Olteanu on 3/7/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageView.h>

@protocol SelectListingPhotosViewControllerDelegate <NSObject>

-(void)finishedAddingPhotosWithArray:(NSArray*)array;

@end

@interface SelectListingPhotosViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet AsyncImageView*    photo1ImageView;
@property (nonatomic, weak) IBOutlet AsyncImageView*    photo2ImageView;
@property (nonatomic, weak) IBOutlet AsyncImageView*    photo3ImageView;
@property (nonatomic, weak) IBOutlet AsyncImageView*    photo4ImageView;
@property (nonatomic, weak) IBOutlet AsyncImageView*    photo5ImageView;
@property (nonatomic, weak) IBOutlet AsyncImageView*    photo6ImageView;
@property (nonatomic, weak) IBOutlet AsyncImageView*    photo7ImageView;
@property (nonatomic, weak) IBOutlet AsyncImageView*    photo8ImageView;
@property (nonatomic, weak) IBOutlet AsyncImageView*    photo9ImageView;

@property (nonatomic, weak) IBOutlet UIButton*          photo1Button;
@property (nonatomic, weak) IBOutlet UIButton*          photo2Button;
@property (nonatomic, weak) IBOutlet UIButton*          photo3Button;
@property (nonatomic, weak) IBOutlet UIButton*          photo4Button;
@property (nonatomic, weak) IBOutlet UIButton*          photo5Button;
@property (nonatomic, weak) IBOutlet UIButton*          photo6Button;
@property (nonatomic, weak) IBOutlet UIButton*          photo7Button;
@property (nonatomic, weak) IBOutlet UIButton*          photo8Button;
@property (nonatomic, weak) IBOutlet UIButton*          photo9Button;

@property (nonatomic, weak) IBOutlet UIView*            blacknessView;
@property (nonatomic, weak) IBOutlet UIView*            buttonsContainer;
@property (nonatomic, weak) IBOutlet UIView*            firstTwoButtonsContainer;
@property (nonatomic, weak) IBOutlet UIView*            cancelButtonContainer;


@property (nonatomic, weak) IBOutlet UIButton*          takePhotoButton;
@property (nonatomic, weak) IBOutlet UIButton*          choseFromLibraryButton;
@property (nonatomic, weak) IBOutlet UIButton*          cancelButton;

@property (nonatomic, weak) id<SelectListingPhotosViewControllerDelegate> delegate;

@property (nonatomic, strong)   UIImageView*        selectedImageView;
@property (nonatomic, strong)   NSMutableArray*     imageArray;
@property (nonatomic)           NSInteger           numberOfPhotos;
@property (nonatomic)           BOOL                changesMade;

-(void) customiseWithArray:(NSArray*)array;


@end
