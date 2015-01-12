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
    _mapView.delegate = self;
    
    _ownerImgView.layer.cornerRadius = _ownerImgView.frame.size.width/2;
    _ownerImgView.layer.masksToBounds = YES;
    
    _ownerNameLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:12.0];
    _daysUntilRenewal.font = [UIFont fontWithName:@"GothamRounded-Light" size:12.0];
    
    _displayMore.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    _connectedThroughLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:12.0];
    
    _locationString = @"";
    
    
    //Add a left swipe gesture recognizer
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:recognizer];
    
    //Add a right swipe gesture recognizer
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
//    recognizer.delegate = self;
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    [self addGestureRecognizer:recognizer];
    
    
#warning fix this!
    [_mapView removeFromSuperview];
    [self addSubview:_mapView];
}

- (void)setApartmentDetails:(PFObject *)apartment andImages:(NSArray *)images
{
    //set owner details
    _ownerImgView.showActivityIndicator = YES;
    PFUser *owner = apartment[@"owner"];
    _ownerImgView.imageURL = [NSURL URLWithString:owner[@"profilePictureUrl"]];
    _ownerNameLbl.text = owner[@"username"];
    
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

#pragma mark - Swipe gesture handlers

- (void)handleSwipeLeft:(id)gesture
{
    RTLog(@"swipe left on cell with index: %li", (long)_apartmentIndex);
    [_delegate addToFravoritesApartmentFromIndex:_apartmentIndex];
}

//- (void)handleSwipeRight:(id)gesture
//{
//    RTLog(@"swipe right on cell with index: %li", (long)_apartmentIndex);
//}

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
