//
//  ApartmentDetailsOtherListingView.m
//  Rented
//
//  Created by Gherghel Lucian on 15/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ApartmentDetailsOtherListingView.h"
#import "UIColor+ColorFromHexString.h"
#import "GeneralUtils.h"
#import "UIImage+imageWithColor.h"
#import "UIImage+ProportionalFill.h"
#import "CongratulationsViewController.h"
#import "UnflipedViewController.h"
#import "LocationUtils.h"
#import <AFNetworking.h>
#import "CustomActivityItemProvider.h"

@implementation ApartmentDetailsOtherListingView

- (void)awakeFromNib
{

    
    
    [_getButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47a0db"]] forState:UIControlStateNormal];
    
    [_likeBtn.layer setCornerRadius:5.0];
    [_likeBtn setClipsToBounds:YES];
    [_shareBtn.layer setCornerRadius:5.0];
    [_shareBtn setClipsToBounds:YES];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnMap:)];
    [self.mapView addGestureRecognizer:tapGesture];
    

}

- (void)setApartmentDetails:(PFObject *)apartment
{
    
    //customise apartment details
    
    _apartment = apartment;
    _descriptionLabel.text = apartment[@"description"];
 

    
    if ([apartment[@"hideFacebookProfile"] integerValue]==1)
    {
        [self.ownerLabel setText:@"Annonymous User's\rListing"];
    }
    else
    {
        [self.ownerLabel setText:[NSString stringWithFormat:@"%@'s\rListing",((PFUser*) apartment[@"owner"])[@"firstName"]]];
        [self.profileImageView setShowActivityIndicator:YES];
        [self.profileImageView setImageURL:[NSURL URLWithString:((PFUser*) apartment[@"owner"])[@"profilePictureUrl"]]];
    }
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    
    [self.profileImageView.layer setBorderWidth:2];
    [self.profileImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    self.carousel.bounceDistance = 0.35;
    self.carousel.scrollSpeed = 0.6;
    [self.pageControl setNumberOfPages:self.apartmentImages.count];
    [self.carousel reloadData];
    
    
    CLLocationCoordinate2D coord = [LocationUtils locationFromPoint:apartment[@"location"]];
    CLLocation* apLocation = [[CLLocation alloc]initWithLatitude:coord.latitude longitude:coord.longitude];
    [[CLGeocoder new] reverseGeocodeLocation:apLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        NSString* neighborhood = @" ";
        NSString* city = @" ";
        NSString* state = @" ";
        NSString* zipCode = @" ";
        
        
        CLPlacemark* placemark = (CLPlacemark*) [placemarks firstObject];
        
        if (placemark.subLocality)
        {
            neighborhood = placemark.subLocality;
        }
        if (placemark.locality)
        {
            city = placemark.locality;
        }
        if (placemark.postalCode)
        {
            zipCode = placemark.postalCode;
        }
        if (placemark.country && [placemark.country isEqualToString:@"United States"])
        {
            state = [GeneralUtils stateAbbreviationForState: placemark.administrativeArea];
        }
        
        if (![neighborhood isEqualToString:@" "] && ![city isEqualToString:@" "])
        {
            [self.addressLabel setText:[NSString stringWithFormat:@"%@, %@",neighborhood, city]];
        }
        else
        {
            [self.addressLabel setText:[NSString stringWithFormat:@"%@, %@",city, placemark.country]];
            
        }
        
        [self.addressLabel setHidden:NO];
        
    }];
    
    MKCoordinateRegion mapRegion = MKCoordinateRegionMake(coord, MKCoordinateSpanMake(0.005, 0.005));
    [self.mapView setRegion:mapRegion animated:NO];
    
    [self.mapView setHidden:NO];
    
    NSAttributedString *attributedText;
    CGFloat height;
    CGRect rect;
    
    NSInteger vacancy= [apartment[@"moveOutOption"] integerValue];
    if (vacancy == 0)
    {
        _vacancyLbl.text = @"Immediately";
    }
    if (vacancy == 1)
    {
        _vacancyLbl.text = @"Flexible";
    }
    if (vacancy == 2)
    {
        NSDateFormatter* formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MMM d, YYYY"];
        _vacancyLbl.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[apartment[@"moveOutTimestamp"]longValue]]];
    }
    attributedText=[[NSAttributedString alloc]     initWithString:_vacancyLbl.text     attributes:@     {     NSFontAttributeName: _vacancyLbl.font     }];

    rect = [attributedText boundingRectWithSize:(CGSize){_vacancyLbl.frame.size.width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    height = ceilf(rect.size.height);
    rect = _vacancyLbl.frame;
    rect.size.height = height;
    [_vacancyLbl setFrame:rect];


    _feeLbl.text = [NSString stringWithFormat:@"$%d",[apartment[@"fee"] integerValue]];
    
    
    attributedText=[[NSAttributedString alloc]     initWithString:_feeLbl.text     attributes:@     {     NSFontAttributeName: _vacancyLbl.font     }];
    
    rect = [attributedText boundingRectWithSize:(CGSize){_feeLbl.frame.size.width, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    height = ceilf(rect.size.height);
    rect = _feeLbl.frame;
    rect.size.height = height;
    [_feeLbl setFrame:rect];

    NSString* listingTypeText;
    if ([apartment[@"listingType"] integerValue] == 0)
    {
        listingTypeText=@"Entire Place";
    }
    else
    {
        listingTypeText=@"Private Room";
    }
    
    self.listingTypeLabel.text = listingTypeText;
    
    
    attributedText=[[NSAttributedString alloc]     initWithString:self.listingTypeLabel.text     attributes:@     {     NSFontAttributeName: self.listingTypeLabel.font     }];
    
    rect = [attributedText boundingRectWithSize:(CGSize){self.listingTypeLabel.frame.size.width, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    height = ceilf(rect.size.height);
    rect = self.listingTypeLabel.frame;
    rect.size.height = height;
    [self.listingTypeLabel setFrame:rect];
    
    NSString* propertyTypeText;
    if ([apartment[@"propertyType"] integerValue] == 0)
    {
        propertyTypeText=@"Appartment";
    }
    else
    {
        propertyTypeText=@"House";
    }
    
    self.propertyTypeLabel.text = propertyTypeText;
    
    
    attributedText=[[NSAttributedString alloc]     initWithString:self.propertyTypeLabel.text     attributes:@     {     NSFontAttributeName: self.propertyTypeLabel.font     }];
    
    rect = [attributedText boundingRectWithSize:(CGSize){self.propertyTypeLabel.frame.size.width, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    height = ceilf(rect.size.height);
    rect = self.propertyTypeLabel.frame;
    rect.size.height = height;
    [self.propertyTypeLabel setFrame:rect];

    if([apartment[@"bedrooms"] intValue]!=0)
    {
        _componentRoomsLbl.text = [NSString stringWithFormat:@"%d",[apartment[@"bedrooms"] intValue]];
    }
    else
    {
        _componentRoomsLbl.text = @"Studio";
    }
    
    
    attributedText=[[NSAttributedString alloc]     initWithString:_componentRoomsLbl.text     attributes:@     {     NSFontAttributeName: _vacancyLbl.font     }];
    
    rect = [attributedText boundingRectWithSize:(CGSize){_componentRoomsLbl.frame.size.width, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    height = ceilf(rect.size.height);
    rect = _componentRoomsLbl.frame;
    rect.size.height = height;
    [_componentRoomsLbl setFrame:rect];
    
    
    _priceLbl.text = [NSString stringWithFormat:@"$%@",apartment[@"rent"]];
    
    attributedText=[[NSAttributedString alloc]     initWithString:_priceLbl.text     attributes:@     {     NSFontAttributeName: _vacancyLbl.font     }];
    
    rect = [attributedText boundingRectWithSize:(CGSize){_priceLbl.frame.size.width, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    height = ceilf(rect.size.height);
    rect = _priceLbl.frame;
    rect.size.height = height;
    [_priceLbl setFrame:rect];
    
    if (((int)([apartment[@"bathrooms"] floatValue]*10 ))%10 ==0)
    {
        _sizeLbl.text = [NSString stringWithFormat:@"%.0f",[apartment[@"bathrooms"] floatValue]];

    }
    else
    {
        _sizeLbl.text = [NSString stringWithFormat:@"%.01f",[apartment[@"bathrooms"] floatValue]];
    }

    attributedText=[[NSAttributedString alloc]     initWithString:_sizeLbl.text     attributes:@     {     NSFontAttributeName: _vacancyLbl.font     }];
    
    rect = [attributedText boundingRectWithSize:(CGSize){_sizeLbl.frame.size.width, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    height = ceilf(rect.size.height);
    rect = _sizeLbl.frame;
    rect.size.height = height;
    [_sizeLbl setFrame:rect];
    
    
    if(apartment[@"renewalTimestamp"])
    {
        NSDate* renewalDate = [NSDate dateWithTimeIntervalSince1970:(long)[apartment[@"renewalTimestamp"] integerValue]];
        NSTimeInterval secondsInterval = [renewalDate timeIntervalSinceDate:[NSDate date]];
        int numberOfDays = secondsInterval /86400 +1;
        if (numberOfDays<0)
        {
            numberOfDays = 365+numberOfDays;
        }
        
        if (numberOfDays == 1)
        {
            _remainingDays.text = [NSString stringWithFormat:@"%d day",numberOfDays];
        }
        else
        {
            _remainingDays.text = [NSString stringWithFormat:@"%d days",numberOfDays];
        }
    }

    
    attributedText=[[NSAttributedString alloc]     initWithString:_remainingDays.text     attributes:@     {     NSFontAttributeName: _vacancyLbl.font     }];
    
    rect = [attributedText boundingRectWithSize:(CGSize){_remainingDays.frame.size.width, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    height = ceilf(rect.size.height);
    rect = _remainingDays.frame;
    rect.size.height = height;
    [_remainingDays setFrame:rect];
    
    
    if ([DEP.favorites containsObject: _apartment.objectId])
    {
        [_likeBtn setSelected:YES];
    }
    else
    {
        [_likeBtn setSelected:NO];
    }
    
    
    CGRect labelRect = [(NSString*)apartment[@"description"]
                        boundingRectWithSize:CGSizeMake(_descriptionLabel.frame.size.width, 500)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:16.0]
                                     }
                        context:nil];

    if (labelRect.size.height > 74)
    {
        [_moreBtn setHidden:NO];
    }
    else
    {
        [_moreBtn setHidden:YES];
    }
    
    if([_apartment[@"requested"] integerValue] == 1)
    {
        [self.getButton setTitle:@"REQUESTED" forState:UIControlStateNormal];
        [_getButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"CCCCCC"]] forState:UIControlStateNormal];
    }
    else
    {
        [self.getButton setTitle:@"GET" forState:UIControlStateNormal];
        [_getButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47A0DB"]] forState:UIControlStateNormal];
    }

    
}

-(IBAction)likeButtonTapped:(id)sender
{
    if (_likeBtn.selected)
    {
        [_likeBtn setSelected:!_likeBtn.selected];
        [DEP.api.apartmentApi removeApartmentFromFavorites:_apartment completion:^(BOOL succeeded) {}];
        [DEP.favorites removeObject:_apartment.objectId];
    }
    else
    {
        NSString* ownerName = self.apartment[@"owner"][@"firstName"];
        NSString* apartmentType;
        if ([self.apartment[@"bedrooms"] integerValue]==0)
        {
            apartmentType = @"Studio";
        }
        if ([self.apartment[@"bedrooms"] integerValue]==1)
        {
            apartmentType = @"One Bedroom";
        }
        if ([self.apartment[@"bedrooms"] integerValue]==2)
        {
            apartmentType = @"Two Bedrooms";
        }
        if ([self.apartment[@"bedrooms"] integerValue]==3)
        {
            apartmentType = @"Three Bedrooms";
        }
        if ([self.apartment[@"bedrooms"] integerValue]==4)
        {
            apartmentType = @"Four Bedrooms";
        }
        if ([self.apartment[@"bedrooms"] integerValue]==5)
        {
            apartmentType = @"Five Bedrooms";
        }
        if (apartmentType == nil)
        {
            apartmentType = @"Apartment";
        }
        NSString* neighborhood = self.apartment[@"neighborhood"];
        NSString* message;
        if ([self.apartment[@"hideFacebookProfile"] integerValue]==1)
        {
            message = [NSString stringWithFormat:@"OK! Annonymous Users's %@ in %@ will now be saved to your likes",apartmentType,neighborhood];
        }
        else
        {
            message = [NSString stringWithFormat:@"OK! %@'s %@ in %@ will now be saved to your likes",ownerName,apartmentType,neighborhood];
        }
        
        [[[UIAlertView alloc]initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        [_likeBtn setSelected:!_likeBtn.selected];
        [DEP.api.apartmentApi addApartmentToFavorites:_apartment withNotification:YES completion:^(BOOL succeeded) {}];
        [[Mixpanel sharedInstance] track:@"Liked Listing" properties:@{@"apartment_id":self.apartment.objectId}];
        [DEP.favorites addObject:_apartment.objectId];
    }

}

- (void)updateFlipButtonStatus
{
    
    if (self.currentUserIsOwner)
    {
        [_getButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"3799ff"]] forState:UIControlStateNormal];

        if ([_apartment[@"visible"] integerValue]==1)
        {
            [self.getButton setTitle:@"UNFLIP" forState:UIControlStateNormal];
        }
        else
        {
            [self.getButton setTitle:@"FLIP" forState:UIControlStateNormal];
            
        }
        return;
    }
 
    if([_apartment[@"requested"] integerValue] == 1)
    {
        [self.getButton setTitle:@"REQUESTED" forState:UIControlStateNormal];
        [_getButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"CCCCCC"]] forState:UIControlStateNormal];
    }
    else
    {
        [self.getButton setTitle:@"GET" forState:UIControlStateNormal];
        [_getButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"3799ff"]] forState:UIControlStateNormal];
    }
    
}

- (IBAction)getApartment:(id)sender
{
    if (self.currentUserIsOwner)
    {

        if(![_apartment[@"visible"] boolValue])
        {
            [DEP.api.apartmentApi makeApartmentLive:_apartment completion:^(BOOL succeeded) {
                
            }];
            
            
            [[[UIAlertView alloc]initWithTitle:@"Your listing is now visible!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            
            [self.getButton setTitle:@"UNFLIP" forState:UIControlStateNormal];
            
            
        }
        else
        {
            [DEP.api.apartmentApi hideLiveApartment:_apartment completion:^(BOOL succeeded) {
                
            }];
            
            [[[UIAlertView alloc]initWithTitle:@"OK! Your listing is hidden" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];

                
    
            
            
            [self.getButton setTitle:@"FLIP" forState:UIControlStateNormal];
            
        }
        
        return;
    }

    [_apartmentDetailsDelegate getApartmentAtIndex:_apartmentIndex];
}

-(IBAction)showDescription:(id)sender
{
    [self.controller setTitle:@" "];
    UIViewController* descriptionVC = [UIViewController new];
    
    CGRect labelRect = [(NSString*)_apartment[@"description"]
                        boundingRectWithSize:CGSizeMake(_descriptionLabel.frame.size.width, 5000)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:16.0]
                                     }
                        context:nil];
    
    UILabel * descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(_descriptionLabel.frame.origin.x, 0, _descriptionLabel.frame.size.width, labelRect.size.height+10)];
    descriptionLabel.numberOfLines =0;
    descriptionLabel.text = _descriptionLabel.text;
    descriptionLabel.font = _descriptionLabel.font;
    descriptionLabel.textColor = _descriptionLabel.textColor;
    
    UIScrollView* scrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [scrollView setContentSize:CGSizeMake(descriptionLabel.frame.size.width, descriptionLabel.frame.size.height+ 60)];
    [scrollView addSubview:descriptionLabel];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    
    [descriptionVC setView:scrollView];

    [self.controller.navigationController pushViewController:descriptionVC animated:YES];
    

}
-(IBAction)pressedShareButton:(id)sender
{
    [[Mixpanel sharedInstance] track:@"Pressed Share Apartment" properties:@{@"apartment_id":self.apartment.objectId, @"facebook_id":[PFUser currentUser][@"facebookID"]}];
    
    [self getFacebookUrl];
}

-(void)getFacebookUrl
{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:@"656809821111233|e3768c5fd6b066d1a3da09e57b000ab3" forKey:@"access_token"];
    NSString* nameString= [NSString stringWithFormat:@"%@'s apartment",self.apartment[@"owner"][@"firstName"]];
    [parameters setValue:nameString forKey:@"name"];

    NSMutableDictionary * iosDict = [NSMutableDictionary new];

    NSString *urlString = [NSString stringWithFormat:@"fb656809821111233://flip/apartment/%@",self.apartment.objectId];


    [iosDict setValue:urlString forKey:@"url"];
    [iosDict setValue:@"Flip" forKey:@"app_name"];
    [iosDict setValue:[NSNumber numberWithInt:970184178]forKey:@"app_store_id" ];
    NSArray *iosArray = [[NSArray alloc]initWithObjects:iosDict, nil];

    NSError* error;
    NSData *iosDictData = [NSJSONSerialization dataWithJSONObject:iosArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString* iosDictString;
    if (!error)
    {
        iosDictString = [[NSString alloc]initWithData:iosDictData encoding:NSUTF8StringEncoding];
    }

    [parameters setValue:iosDictString forKey:@"ios"];

    NSString* webString = @"{     \"should_fallback\" : false   }";

    [parameters setValue:webString forKey:@"web"];

    [manager POST:@"https://graph.facebook.com/app/app_link_hosts" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* responseDict = (NSDictionary*)responseObject;
        NSString* appLinkObjectId = [responseDict objectForKey:@"id"];

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString* getUrlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@",appLinkObjectId];
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        [parameters setValue:@"656809821111233|e3768c5fd6b066d1a3da09e57b000ab3" forKey:@"access_token"];
        [parameters setValue:@"canonical_url" forKey:@"fields"];
        [parameters setValue:@"true" forKey:@"pretty"];

        [manager GET:getUrlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

            NSDictionary* responseDict = (NSDictionary*)responseObject;
            NSString* shareUrl = [responseDict objectForKey:@"canonical_url"];

            [self showActivityViewControllerWithFBURL:[NSURL URLWithString:shareUrl]];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

-(void)showActivityViewControllerWithFBURL:(NSURL*)fburl
{
    NSString *textToShare = @" Check out Flip - it's a marketplace for lease breaks and lease takeovers";
    CustomActivityItemProvider* urlItem = [[CustomActivityItemProvider alloc] initWithDefaultUrl:[NSURL URLWithString:self.apartment[@"shareUrl"]] andFBURL:fburl];
    
//    NSURL *url = [NSURL URLWithString:self.apartment[@"shareUrl"]];
//    NSURL *url = [NSURL URLWithString:@"http://www.hiflip.com/"];
    UIImage* image = (UIImage*)[[self.carousel itemViewAtIndex:0] viewWithTag:1];
    
    NSArray *objectsToShare;
    
    if (image)
    {
        objectsToShare = @[textToShare,urlItem,image];
    }
    else
    {
        objectsToShare = @[textToShare,urlItem];
        
    }
    
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self.controller presentViewController:activityVC animated:YES completion:nil];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionSpacing:
        {
            return (carousel.frame.size.width + 8)/carousel.frame.size.width;
        }
        case iCarouselOptionVisibleItems:
        {
            return 3;
        }
        default:
        {
            return value;
        }
    }
}
-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    [self.pageControl setCurrentPage:carousel.currentItemIndex];
}

-(NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.apartmentImages.count;
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    AsyncImageView* image;
    if (view)
    {
        image = (AsyncImageView*)[view viewWithTag:1];
    }
    else
    {
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.carousel.frame.size.height)];
        [view setClipsToBounds:YES];
        image = [[AsyncImageView alloc] initWithFrame:view.frame];
        [image setShowActivityIndicator:YES];
        [image setCrossfadeDuration:0];
        [image setContentMode:UIViewContentModeScaleAspectFill];
        [image setUserInteractionEnabled:YES];
        [view addSubview:image];
        [image setTag:1];
    }
    
    [image setCrossfadeDuration:0];
    [image setShowActivityIndicator:YES];
    [image setImage:nil];
    
    if ([[self.apartmentImages objectAtIndex:index] isKindOfClass:[UIImage class]])
    {
        [image setImage:[self.apartmentImages objectAtIndex:index]];
    }
    else
    {
        PFObject *firstImage = [self.apartmentImages objectAtIndex:index];
        PFFile *imageFile = firstImage[@"image"];
        image.imageURL = [NSURL URLWithString:imageFile.url];
    }
    
    
    
    return view;
    
}

-(IBAction)tapOnMap:(id)sender
{
    [self.apartmentDetailsDelegate displayFullMapViewForApartmentAtIndex:self.apartmentIndex];
}

@end
