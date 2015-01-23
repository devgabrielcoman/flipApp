//
//  FavoriteApartmentTableViewCell.h
//  Rented
//
//  Created by Lucian Gherghel on 10/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageView.h>
#import "FavoriteApartmentCellProtocol.h"

@interface FavoriteApartmentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *apartmentImageView;
@property (weak, nonatomic) IBOutlet UILabel *apartmentDescriptionLbl;
@property (weak, nonatomic) IBOutlet UILabel *locationLbl;

@property id<FavoriteApartmentCellProtocol> delegate;
@property NSInteger apartmentIndex;

@end
