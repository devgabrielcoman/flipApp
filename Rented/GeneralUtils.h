//
//  GeneralUtils.h
//  Rented
//
//  Created by Lucian Gherghel on 10/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeneralUtils : NSObject

+ (NSString *)roomsDescriptionForApartment:(PFObject *)apartment;
+ (NSString *)roomsLongDescriptionForApartment:(PFObject *)apartment;
+ (NSString *)connectedThroughExtendedDescription:(NSMutableArray *)mutalFriends;
+ (NSString *)getCityFromLocation:(NSString *)locationString;
+(NSMutableArray*) mutualFriendsInArray1: (NSArray*)friends1 andArray2: (NSArray*)friends2;
+(NSString*) stateAbbreviationForState:(NSString*) state;
@end
