//
//  TopApartmentView.h
//  Rented
//
//  Created by Lucian Gherghel on 08/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AsyncImageView.h>
#import "ApartmentCellProtocol.h"

@interface TopApartmentView : UIView<UIGestureRecognizerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet AsyncImageView *apartmentImgView;
@property (weak, nonatomic) IBOutlet UILabel *ownerNameLbl;
@property (weak, nonatomic) IBOutlet AsyncImageView *ownerImgView;
@property (weak, nonatomic) IBOutlet UILabel *daysUntilRenewal;
@property (weak, nonatomic) IBOutlet UIButton *displayMore;
@property (weak, nonatomic) IBOutlet UIImageView *connectedThroughImgView;
@property (weak, nonatomic) IBOutlet UILabel *connectedThroughLbl;

@property BOOL enableSwipeGestures;
@property id<ApartmentCellProtocol> delegate;
@property NSInteger apartmentIndex;
@property NSString *locationString;
@property PFObject *apartment;

- (void)setApartmentDetails:(PFObject *)apartment andImages:(NSArray *)images;

@end
