//
//  ApartmentTableViewCell.m
//  Rented
//
//  Created by Lucian Gherghel on 04/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ApartmentTableViewCell.h"
#import "UIImage+ProportionalFill.h"
#import "LocationUtils.h"
#import "MapUtils.h"

@implementation ApartmentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.frame = CGRectMake(0, 0, wScr, hScr);
    _mapView.layer.cornerRadius = _mapView.frame.size.width/2;
    _mapView.layer.masksToBounds = YES;
    
    _ownerImgView.layer.cornerRadius = _ownerImgView.frame.size.width/2;
    _ownerImgView.layer.masksToBounds = YES;
    
    _ownerNameLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:12.0];
    _daysUntilRenewal.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    
#warning fix this!
    [_mapView removeFromSuperview];
    [self.contentView addSubview:_mapView];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setApartmentDetails:(PFObject *)apartment andImages:(NSArray *)images
{
    //set owner pic
    _ownerImgView.imageURL = [NSURL URLWithString:DEP.authenticatedUser[@"profilePictureUrl"]];
    _ownerImgView.showActivityIndicator = YES;
    
    //set owner name
    _ownerNameLbl.text = DEP.authenticatedUser.username;
    
    //apartment image
    if(images && images.count > 0)
    {
        PFObject *firstImage = [images firstObject];
        PFFile *imageFile = firstImage[@"image"];
        _apartmentImgView.showActivityIndicator = YES;
        _apartmentImgView.imageURL = [NSURL URLWithString:imageFile.url];
    }
    
    //map location
    MKPointAnnotation *locationPin = [MKPointAnnotation new];
    [locationPin setCoordinate:[LocationUtils locationFromPoint:apartment[@"location"]]];
    [_mapView addAnnotation:locationPin];
    [MapUtils zoomToFitMarkersOnMap:_mapView];
    
    _daysUntilRenewal.text = [NSString stringWithFormat:@"%li days\n until\n renewal", (long)[apartment[@"renewaldays"] integerValue]];
}

@end
