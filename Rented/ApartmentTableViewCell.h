//
//  ApartmentTableViewCell.h
//  Rented
//
//  Created by Lucian Gherghel on 04/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AsyncImageView.h>

@interface ApartmentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *apartmentImgView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *ownerNameLbl;
@property (weak, nonatomic) IBOutlet AsyncImageView *ownerImgView;
@property (weak, nonatomic) IBOutlet UILabel *daysUntilRenewal;

- (void)setApartmentDetails:(PFObject *)apartment andImages:(NSArray *)images;

@end
