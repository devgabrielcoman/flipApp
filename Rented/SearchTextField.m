//
//  SearchTextField.m
//  Rented
//
//  Created by Cristian Olteanu on 3/7/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "SearchTextField.h"

@implementation SearchTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 31, bounds.origin.y+2,
                      bounds.size.width -4-31, bounds.size.height-4);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
