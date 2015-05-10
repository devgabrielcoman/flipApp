//
//  SelectListingPhotosViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 3/7/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "SelectListingPhotosViewController.h"
#import "UIImage+Alpha.h"

@interface SelectListingPhotosViewController ()

@end

@implementation SelectListingPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if (self.imageArray)
    {
        [self showImages];
    }
    else
    {
        self.imageArray = [NSMutableArray new];
    }
    
    [self.firstTwoButtonsContainer setClipsToBounds:YES];
    [self.firstTwoButtonsContainer.layer setCornerRadius:3];
    [self.cancelButtonContainer setClipsToBounds:YES];
    [self.cancelButtonContainer.layer setCornerRadius:3];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showButtomButtons
{
    [self.blacknessView setHidden:NO];
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [self.blacknessView setAlpha:0.2];
                         CGRect buttonsFrame = self.buttonsContainer.frame;
                         buttonsFrame.origin.y = [UIScreen mainScreen].bounds.size.height-buttonsFrame.size.height;
                         [self.buttonsContainer setFrame:buttonsFrame];
        
    }
                     completion:^(BOOL finished) {
        
    }];
    
}

-(void)hideButtomButtons
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [self.blacknessView setAlpha:0];
                         CGRect buttonsFrame = self.buttonsContainer.frame;
                         buttonsFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
                         [self.buttonsContainer setFrame:buttonsFrame];
                         
                     }
                     completion:^(BOOL finished) {
                         [self.blacknessView setHidden:YES];
                     }];
}
#pragma mark Image pickcker delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    self.selectedImageView = nil;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    UIImage *resizedImage;
    
    float actualHeight = chosenImage.size.height;
    float actualWidth = chosenImage.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxHeight=2.5*[UIScreen mainScreen].bounds.size.height;
    float maxWidth=2.5*[UIScreen mainScreen].bounds.size.width;
    
    if(actualHeight>actualWidth)
    {
        if (actualHeight>maxHeight)
        {
            actualHeight = maxHeight;
            actualWidth = actualHeight*imgRatio;
        }

    }
    else
    {
        if(actualWidth > maxWidth)
        {
            actualWidth = maxWidth;
            actualHeight = actualWidth/imgRatio;
        }

    }
    

    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [chosenImage drawInRect:rect];
    
    resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    resizedImage = [resizedImage transparentBorderImage:1];
    
    [self.selectedImageView setImage:resizedImage];
    [self.selectedImageView setHidden:NO];
    
    self.selectedImageView = nil;
    
    if (self.imageArray.count==0)
    {
        [self.imageArray addObject:resizedImage];
    }
    else
    {
        [self.imageArray insertObject:resizedImage atIndex:self.numberOfPhotos];
    }
    
    UIImage* deleteImage = [UIImage imageNamed:@"remove_photo"];
    UIView* containerView= [self.view viewWithTag:(self.numberOfPhotos+1)];
    UIButton* removeButton = (UIButton*)[containerView viewWithTag:(self.numberOfPhotos+1+10)];
    [removeButton setImage:deleteImage forState:UIControlStateNormal];
    
    self.numberOfPhotos++;
    
    containerView= [self.view viewWithTag:(self.numberOfPhotos+1)];
    removeButton = (UIButton*)[containerView viewWithTag:(self.numberOfPhotos+1+10)];
    [removeButton setEnabled:YES];
    
    self.changesMade = YES;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - IBActions


-(IBAction)imageButtonTapped:(id)sender
{
    NSInteger tag = [(UIButton*)sender tag];
    
    if (tag - 10 <= self.numberOfPhotos)
    {
        [self.imageArray removeObjectAtIndex:tag-10-1];
        
        for (int i = tag-10; i<self.numberOfPhotos; i++)
        {
            UIView* containerView1= [self.view viewWithTag:i];
            UIImageView* imageView1 = (UIImageView*)[containerView1 viewWithTag:(i+20)];
            UIView* containerView2= [self.view viewWithTag:i+1];
            UIImageView* imageView2 = (UIImageView*)[containerView2 viewWithTag:(i+1+20)];
            [imageView1 setImage: imageView2.image];
        }
        
        UIView* containerView= [self.view viewWithTag:self.numberOfPhotos];
        UIImageView* imageView = (UIImageView*)[containerView viewWithTag:(self.numberOfPhotos+20)];
        [imageView setImage:nil];
        [imageView setHidden:YES];
        UIButton* button = (UIButton*)[containerView viewWithTag:(self.numberOfPhotos+10)];
        UIImage* addPhoto = [UIImage imageNamed:@"add_photo"];
        [button setImage:addPhoto forState:UIControlStateNormal];
        
        if (tag-10<9)
        {
            containerView= [self.view viewWithTag:self.numberOfPhotos+1];
             button = (UIButton*)[containerView viewWithTag:(self.numberOfPhotos+10+1)];
            [button setEnabled:NO];
        }
        
        self.numberOfPhotos--;
        
        self.changesMade =YES;

    }
    else if(tag-10 ==self.numberOfPhotos +1)
    {
        switch (tag) {
            case 11:
            {
                self.selectedImageView = self.photo1ImageView;
                break;
            }
            
            case 12:
                {
                self.selectedImageView = self.photo2ImageView;
                break;
            }

            
            case 13:
                {
                self.selectedImageView = self.photo3ImageView;
                break;
            }

            
            case 14:
                {
                self.selectedImageView = self.photo4ImageView;
                break;
            }

            
            case 15:
                {
                self.selectedImageView = self.photo5ImageView;
                break;
            }
                
            case 16:
            {
                self.selectedImageView = self.photo6ImageView;
                break;
            }
            case 17:
                {
                self.selectedImageView = self.photo7ImageView;
                break;
            }

            
            case 18:
                {
                self.selectedImageView = self.photo8ImageView;
                break;
            }

            
            case 19:
                {
                self.selectedImageView = self.photo9ImageView;
                break;
            }
                
            default:
                break;
        }
        
        [self showButtomButtons];
    }
}

-(IBAction)takePhotoButtonTapped:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    [self hideButtomButtons];
}

-(IBAction)choseFromLibraryTapped:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    [self hideButtomButtons];

}

-(IBAction)cancelButtonTapped:(id)sender
{
    [self hideButtomButtons];
}

-(IBAction)doneButtonTapped:(id)sender
{
    if (self.changesMade)
    {
        [self.delegate finishedAddingPhotosWithArray:self.imageArray];
    }
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
        
    }];
}

-(void) customiseWithArray:(NSArray*)array
{
    if (array)
    {
        self.numberOfPhotos = array.count;
    }
    
    self.imageArray= [array mutableCopy];
}

-(void)showImages
{
    for (int i=0; i<self.imageArray.count; i++)
    {
        NSInteger tag = i+1;

        
        UIView* containerView = [self.view viewWithTag:tag];
        UIImage* deleteImage = [UIImage imageNamed:@"remove_photo"];
        UIButton* button = (UIButton*)[containerView viewWithTag:tag+10];
        [button setEnabled:YES];
        [button setImage:deleteImage forState:UIControlStateNormal];
        
        AsyncImageView* imageView = (AsyncImageView*) [containerView viewWithTag:tag+20];
        
        
        if ([[self.imageArray objectAtIndex:i] isKindOfClass:[UIImage class]])
        {
            [imageView setImage: [self.imageArray objectAtIndex:i]];
        }
        else
        {
            PFObject *firstImage = [self.imageArray objectAtIndex:i];
            PFFile *imageFile = firstImage[@"image"];
            [imageView setShowActivityIndicator:YES];
            [imageView setCrossfadeDuration:0];
            imageView.imageURL = [NSURL URLWithString:imageFile.url];
        }

    }
    
    if (self.imageArray.count<9)
    {
        UIView* containerView= [self.view viewWithTag:self.numberOfPhotos+1];
        UIButton* button = (UIButton*)[containerView viewWithTag:(self.numberOfPhotos+10+1)];
        [button setEnabled:YES];
    }
    
}

@end
