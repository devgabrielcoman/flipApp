//
//  DemoApartmentTableViewCell.h
//  Rented
//
//  Created by Lucian Gherghel on 08/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopApartmentView.h"
#import "ApartmentDetailsView.h"
#import "ApartmentDetailsViewProtocol.h"

/*
 Custom apartment cell. This cell is used when displaying current user listing and also on feed
 It has two main components:
 apartmentTopView - is the same for both: cases when user see his own listing / other listing
 apartmentDetailsView - this might be: ApartmentDetailsView(when current user is owner of the listing) or ApartmentDetailsOtherListingView(when current user looks at listing
 that belongs to other people). I've used a generic object that implements the protocol ApartmentDetailsViewProtocol in order to avoid having two
 specific objectes for a single one that do the same thing. This view is changed when cell is extended
 */


@protocol ApartmentCellProtocol;

@interface ApartmentTableViewCell : UITableViewCell

@property TopApartmentView *apartmentTopView;
@property NSInteger index;
@property BOOL currentUserIsOwner;
@property BOOL isFromFavorites;

- (void)setDelegate:(id<ApartmentCellProtocol>)delegate;
- (void)setApartment:(PFObject *)apartment withImages:(NSArray *)images andCurrentUsersStatus:(BOOL)isOwner;
- (void)setApartmentIndex:(NSInteger)apartmentIndex;


@end
