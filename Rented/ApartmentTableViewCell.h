//
//  ApartmentTableViewCell.h
//  Rented
//
//  Created by Lucian Gherghel on 04/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ApartmentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *apartmentImgView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *ownerImgView;
@property (weak, nonatomic) IBOutlet UILabel *ownerNameLbl;

@end
