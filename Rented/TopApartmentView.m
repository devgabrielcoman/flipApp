//
//  TopApartmentView.m
//  Rented
//
//  Created by Lucian Gherghel on 08/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "TopApartmentView.h"
#import "UIImage+ProportionalFill.h"
#import "LocationUtils.h"
#import "MapUtils.h"
#import "ApartmentCellProtocol.h"
#import "UIColor+ColorFromHexString.h"
#import "GeneralUtils.h"

@implementation TopApartmentView

- (void)awakeFromNib
{
    //self.frame = CGRectMake(0, 0, wScr, hScr-statusBarHeight);

    _mapView.layer.masksToBounds = YES;
    _mapView.delegate = self;
    
    _ownerImgView.layer.cornerRadius = _ownerImgView.frame.size.width/2;
    _ownerImgView.layer.masksToBounds = YES;

    
    _locationString = @"";

    
    //Add a left swipe gesture recognizer
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:recognizer];
    
       
    CGRect apartmentImgViewFrame = _apartmentImgView.frame;
    apartmentImgViewFrame.size.width = wScr;
    _apartmentImgView.frame = apartmentImgViewFrame;
    [_apartmentImgView setContentMode:UIViewContentModeScaleAspectFill];
    


}
-(void)updateMapView
{
    CGFloat yposition = hScr- statusBarHeight-18 -40 - 174 + (174 - 100) /2.0;
    
    [_mapView setFrame:CGRectMake(_mapView.frame.origin.x, yposition, 100,100)];
}

-(void)layoutSubviews{
    
    self.frame = CGRectMake(0, 0, wScr, hScr-statusBarHeight);
    [super layoutSubviews];
    _mapView.layer.cornerRadius = _mapView.bounds.size.width/2;
}

- (void)setApartmentDetails:(PFObject *)apartment andImages:(NSArray *)images
{
    [self.verifiedLabel setHidden:YES];
    //set owner details
    _ownerImgView.crossfadeDuration =0;
    _ownerImgView.image = nil;
    _ownerImgView.image = [UIImage imageNamed:@"default_profile"];
    PFUser *owner = apartment[@"owner"];
    
    if ([apartment[@"hideFacebookProfile"] integerValue]== 1)
    {
        [_ownerImgView setImage:[UIImage imageNamed:@"default-profile"]];
        _ownerNameLbl.text = @"Annonymous User";
    }
    else
    {
        _ownerImgView.showActivityIndicator = YES;
        _ownerImgView.imageURL = [NSURL URLWithString:owner[@"profilePictureUrl"]];
        _ownerNameLbl.text = owner[@"firstName"];
    }
    

    
    //apartment image
    if(images && images.count > 0)
    {
        _apartmentImgView.crossfadeDuration =0;
        _apartmentImgView.image = nil;
        _apartmentImgView.showActivityIndicator = YES;
        
        PFObject *firstImage = [images firstObject];
        
        
        if (!firstImage[@"fileName"] || !firstImage[@"type"])
        {
            PFFile *imageFile = firstImage[@"image"];
            _apartmentImgView.imageURL = [NSURL URLWithString:imageFile.url];
        }
        else
        {
            NSInteger fileSize;
            
            if(wScr == 320)
            {
                if( ! IS_IPHONE_5 )
                {
                    fileSize = 1;
                }
                else
                {
                    fileSize = 2;
                }
            }
            else
            {
                if(wScr == 375)
                {
                    fileSize = 3;
                }
                else
                {
                    fileSize = 4;
                }
            }
            NSString* fileName = firstImage[@"fileName"];
            NSString* imageURL = [NSString stringWithFormat:@"%@/leaseflip/apt-img/%@/%@_%d",kImageHostString,[fileName substringToIndex:1],fileName,fileSize];
            _apartmentImgView.imageURL = [NSURL URLWithString:imageURL];
            
        }



        
        UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shouldOpenFullGallery)];
        tapped.numberOfTapsRequired = 1;
        [_apartmentImgView addGestureRecognizer:tapped];
        _apartmentImgView.userInteractionEnabled = YES;
    }
    
    //map location
    if(![_locationString isEqualToString:apartment[@"location"]])
    {
        [_mapView removeAnnotations:_mapView.annotations];
        
        MKPointAnnotation *locationPin = [MKPointAnnotation new];
        [locationPin setCoordinate:[LocationUtils locationFromPoint:apartment[@"location"]]];
        
        [_mapView addAnnotation:locationPin];
        
        [MapUtils zoomToFitMarkersOnMap:_mapView];
        
        _locationString = apartment[@"location"];
    }
    
    UITapGestureRecognizer *tapOnMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnMap)];
    tapOnMap.numberOfTapsRequired = 1;
    [_mapView addGestureRecognizer:tapOnMap];
    
    //_daysUntilRenewal.text = [NSString stringWithFormat:@"%li days\n until\n renewal", (long)[apartment[@"renewaldays"] integerValue]];
    

    
    NSInteger vacancyOption= [apartment[@"moveOutOption"] integerValue];
    if (vacancyOption == 0)
    {
        _daysUntilRenewal.text = @"Moving out: Immediately";
    }
    if (vacancyOption == 1)
    {
        _daysUntilRenewal.text = @"Moving out: Flexible";
    }
    if (vacancyOption == 2)
    {
        NSDateFormatter* formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MMM d, YYYY"];
        _daysUntilRenewal.text = [NSString stringWithFormat:@"Moving out:\r%@",[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[apartment[@"moveOutTimestamp"]longValue]]]];
    }


    if (apartment[@"neighborhood"])
    {
        _neighborhoodLabel.text = apartment[@"neighborhood"];
    }
    else
    {
        _neighborhoodLabel.text = apartment[@"city"];
    }
    
//    //show verifiedLabel if user is verified
//    PFQuery* verifiedQuery = [PFQuery queryWithClassName:@"UserMetaData"];
//    [verifiedQuery whereKey:@"user" equalTo:owner];
//    [verifiedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if ([objects count]>0)
//        {
//            PFObject* object = [objects firstObject];
//            if ([object[@"isVerified"] integerValue]==1)
//            {
//                [self.verifiedLabel setHidden:NO];
//            }
//            else
//            {
//                [self.verifiedLabel setHidden:YES];
//            }
//        }
//    }];
    
}

#pragma mark - Gesture handlers

- (void)shouldOpenFullGallery
{
//    [_delegate displayGalleryForApartmentAtIndex:_apartmentIndex];
    [_delegate displayMoreInfoForApartmentAtIndex:_apartmentIndex];
}

- (void)tapOnMap
{
    [_delegate displayFullMapViewForApartmentAtIndex:_apartmentIndex];
}

- (IBAction)showApartmentDetails:(id)sender
{
    [_delegate displayMoreInfoForApartmentAtIndex:_apartmentIndex];
}

- (IBAction)shareApartment:(id)sender
{
    [_delegate shareApartment];
}
-(IBAction)likesButtonTapped:(id)sender
{
    [_delegate showLikes];
}

-(IBAction)editButtonTapped:(id)sender
{
    [self.delegate editApartment];
}

#pragma mark - Swipe gesture handlers

- (void)handleSwipeLeft:(id)gesture
{
    
    if (!self.disableSwipeGestures)
    {
        [_delegate displayMoreInfoForApartmentAtIndex:_apartmentIndex];
    }

}

- (void)handleSwipeRight:(id)gesture
{
    RTLog(@"swipe right on cell with index: %li", (long)_apartmentIndex);

}
- (void)handleSwipeUp:(id)gesture
{
    RTLog(@"swipe Up on cell with index: %li", (long)_apartmentIndex);

    if ([_delegate respondsToSelector:@selector(switchToNextApartmentFromIndex:)])
    {
        [_delegate switchToNextApartmentFromIndex:_apartmentIndex];
    }
}
- (void)handleSwipeDown:(id)gesture
{
    RTLog(@"swipe Down on cell with index: %li", (long)_apartmentIndex);

    if ([_delegate respondsToSelector:@selector(switchToPreviousApartmentFromIndex:)])
    {
        [_delegate switchToPreviousApartmentFromIndex:_apartmentIndex];
    }
}

-(void)tappedAtPosition:(CGPoint)point
{
    if ([self.myListingBar isHidden])
    {
        return;
    }
    
    if(CGRectContainsPoint(self.editButton.frame, point))
    {
        [self editButtonTapped:nil];
    }
    if (CGRectContainsPoint(self.shareButton.frame, point))
    {
        [self shareApartment:nil];
    }
}

#pragma mark - Map View Delegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKPointAnnotation class]]){
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        [annotationView setImage:nil];
        
        return annotationView;
    }
    
    return nil;
}

@end
