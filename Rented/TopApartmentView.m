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

@implementation TopApartmentView

- (void)awakeFromNib
{
    //self.frame = CGRectMake(0, 0, wScr, hScr-statusBarHeight);
    
    _mapView.layer.cornerRadius = _mapView.frame.size.width/2;
    _mapView.layer.masksToBounds = YES;
    
    _ownerImgView.layer.cornerRadius = _ownerImgView.frame.size.width/2;
    _ownerImgView.layer.masksToBounds = YES;
    
    _ownerNameLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:12.0];
    _daysUntilRenewal.font = [UIFont fontWithName:@"GothamRounded-Light" size:12.0];
    
    _displayMore.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    
#warning fix this!
    [_mapView removeFromSuperview];
    [self addSubview:_mapView];
}

- (void)setApartmentDetails:(PFObject *)apartment andImages:(NSArray *)images
{
    //set owner pic
    _ownerImgView.showActivityIndicator = YES;
    _ownerImgView.imageURL = [NSURL URLWithString:DEP.authenticatedUser[@"profilePictureUrl"]];
    
    //set owner name
    _ownerNameLbl.text = DEP.authenticatedUser.username;
    
    //apartment image
    if(images && images.count > 0)
    {
        PFObject *firstImage = [images firstObject];
        PFFile *imageFile = firstImage[@"image"];
        _apartmentImgView.showActivityIndicator = YES;
        _apartmentImgView.imageURL = [NSURL URLWithString:imageFile.url];
        
        UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shouldOpenFullGallery)];
        tapped.numberOfTapsRequired = 1;
        [_apartmentImgView addGestureRecognizer:tapped];
        _apartmentImgView.userInteractionEnabled = YES;
    }
    
    //map location
    [_mapView removeAnnotations:_mapView.annotations];
    
    MKPointAnnotation *locationPin = [MKPointAnnotation new];
    [locationPin setCoordinate:[LocationUtils locationFromPoint:apartment[@"location"]]];
    [_mapView addAnnotation:locationPin];
    
    [MapUtils zoomToFitMarkersOnMap:_mapView];
    
    UITapGestureRecognizer *tapOnMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnMap)];
    tapOnMap.numberOfTapsRequired = 1;
    [_mapView addGestureRecognizer:tapOnMap];
    
    _daysUntilRenewal.text = [NSString stringWithFormat:@"%li days\n until\n renewal", (long)[apartment[@"renewaldays"] integerValue]];
}

#pragma mark - Gesture handlers

- (void)shouldOpenFullGallery
{
    [_delegate displayGalleryForApartmentAtIndex:_apartmentIndex];
}

- (void)tapOnMap
{
    [_delegate displayFullMapViewForApartmentAtIndex:_apartmentIndex];
}

- (IBAction)showApartmentDetails:(id)sender
{
    [_delegate displayMoreInfoForApartmentAtIndex:_apartmentIndex];
}

@end
