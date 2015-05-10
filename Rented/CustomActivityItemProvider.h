//
//  CustomActivityItemProvider.h
//  Rented
//
//  Created by Cristian Olteanu on 4/6/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomActivityItemProvider : UIActivityItemProvider

- (id)initWithDefaultUrl:(NSURL*) url andFBURL:(NSURL*)fburl;

@property (nonatomic, strong) NSURL* fbURL;

@end