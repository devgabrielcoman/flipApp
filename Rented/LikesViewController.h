//
//  LikesViewController.h
//  Rented
//
//  Created by Cristian Olteanu on 2/17/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LikesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableView;

@property (strong, nonatomic) NSArray* favoritesArray;

@end
