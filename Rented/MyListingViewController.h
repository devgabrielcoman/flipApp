//
//  MyListingViewController.h
//  Rented
//
//  Created by Cristian Olteanu on 2/10/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApartmentCellProtocol.h"
#import <MWPhotoBrowser.h>
#import "Apartment.h"
#import "AddApartmentViewController.h"
#import "ApartmentTableViewCell.h"


@interface MyListingViewController : UIViewController <ApartmentCellProtocol,MWPhotoBrowserDelegate,AddApartmentDelegate>
@property (nonatomic,strong) ApartmentTableViewCell* apartmentCell;
@property (nonatomic,strong) Apartment* apartment;
@property (nonatomic,strong) NSArray* likesArray;
@property (nonatomic,strong) NSMutableArray* apartmentGalleryPhotos;


@end
