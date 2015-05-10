//
//  AddApartmentViewController.h
//  RentedAddApartment
//
//  Created by Lucian Gherghel on 30/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Apartment.h"
#import "EnterDetailsViewController.h"
#import "EnterAddressViewController.h"
#import "EnterLeaseDetailsViewController.h"
#import <AsyncImageView.h>
#import <MapKit/MapKit.h>
#import "SelectListingPhotosViewController.h"
#import "iCarousel.h"
#import "ApartmentCellProtocol.h"


@protocol AddApartmentDelegate <NSObject>

-(void)addApartmentFinieshedWithChanges:(BOOL) changes;

@end

@interface AddApartmentViewController : UIViewController  <EnterDetailsViewControllerDelegate,EnterAddressViewControllerDelegate,EnterLeaseDetailsViewControllerDelegate,SelectListingPhotosViewControllerDelegate, iCarouselDataSource,iCarouselDelegate,ApartmentCellProtocol>

@property (weak, nonatomic) IBOutlet UIButton*          addMessageButton;
@property (weak, nonatomic) IBOutlet UIView*            rentContainer;
@property (weak, nonatomic) IBOutlet UIView*            feeContainer;
@property (weak, nonatomic) IBOutlet UIView*            messageContainer;
@property (weak, nonatomic) IBOutlet AsyncImageView*    profileImageView;
@property (weak, nonatomic) IBOutlet UILabel*           ownerLabel;
@property (weak, nonatomic) IBOutlet UIButton*          entirePlaceButton;
@property (weak, nonatomic) IBOutlet UIButton*          privateRoomButton;
@property (weak, nonatomic) IBOutlet UIButton*          apartmentButton;
@property (weak, nonatomic) IBOutlet UIButton*          houseButton;
@property (weak, nonatomic) IBOutlet UISlider*          bedroomsSlider;
@property (weak, nonatomic) IBOutlet UISlider*          bathroomsSlider;
@property (weak, nonatomic) IBOutlet UILabel*           bedroomsLabel;
@property (weak, nonatomic) IBOutlet UILabel*           bathroomsLabel;
@property (weak, nonatomic) IBOutlet UILabel*           studioLabel;
@property (weak, nonatomic) IBOutlet UILabel*           moveOutDateLabelUnselected;
@property (weak, nonatomic) IBOutlet UILabel*           moveOutDateLabelSelected;
@property (weak, nonatomic) IBOutlet UILabel*           moveOutDateLabel;
@property (weak, nonatomic) IBOutlet UILabel*           leaseEndDateLabelUnselected;
@property (weak, nonatomic) IBOutlet UILabel*           leaseEndDateLabelSelected;
@property (weak, nonatomic) IBOutlet UILabel*           leaseEndDateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *         contactDirectlySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *         visibleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *         hideFacebookProfileSwitch;
@property (weak, nonatomic) IBOutlet UITextField *      rentTextField;
@property (weak, nonatomic) IBOutlet UITextField *      feeTextField;
@property (weak, nonatomic) IBOutlet UIImageView *      rentTouchContainer;
@property (weak, nonatomic) IBOutlet UIImageView *      feeTouchContainer;
@property (weak, nonatomic) IBOutlet UIView*            messageBackground;
@property (weak, nonatomic) IBOutlet UILabel*           messageLabel;
@property (weak, nonatomic) IBOutlet UIButton*          listingPhotosButton;
@property (weak, nonatomic) IBOutlet UIView*            listingPhotosBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton*          listingAddressButton;
@property (weak, nonatomic) IBOutlet UIView*            listingAddressBackgroundView;
@property (weak, nonatomic) IBOutlet MKMapView*         mapView;
@property (weak, nonatomic) IBOutlet UILabel*           addressLabel;
@property (weak, nonatomic) IBOutlet UIView *           leaseDetailsContainer;
@property (weak, nonatomic) IBOutlet UITextView *       descriptionTextView;
@property (weak, nonatomic) IBOutlet iCarousel *        carousel;
@property (weak, nonatomic) IBOutlet UIPageControl*     pageControl;
@property (weak, nonatomic) IBOutlet UIButton*          publishListingButton;
@property (weak, nonatomic) IBOutlet UILabel*           titleLabel;
@property (weak, nonatomic) IBOutlet UILabel*           recommendedFeeLabel;

@property (nonatomic) BOOL noApartmentOnEntry;
@property (nonatomic) BOOL createdApartment;

@property (strong, nonatomic) NSMutableDictionary*      autoSave;

@property id <AddApartmentDelegate> delegate;
@property CLLocationCoordinate2D apartmentLocation;
@property NSString *locationName;
@property NSInteger apartmentType;
@property NSArray *apartmentImages;
@property PFUser *apartmentOwner;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewContainer;

@property (nonatomic) NSInteger listingType;
@property (nonatomic) NSInteger propertyType;

@property (nonatomic, strong) NSDate* date1;
@property (nonatomic, strong) NSDate* date2;
@property (nonatomic) NSInteger leaveApartmentOption;

@property (nonatomic, strong) NSArray* imagesArray;

@property Apartment* apartment;
@property UIImage* image;

@end
