//
//  CustomActivityItemProvider2.h
//  Rented
//
//  Created by Cristian Olteanu on 5/18/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomActivityItemProvider2 : UIActivityItemProvider

- (id)initWithDefaultString:(NSString*) string andEmailString:(NSString*) emailString;

@property (nonatomic, strong) NSString* emailString;

@end
