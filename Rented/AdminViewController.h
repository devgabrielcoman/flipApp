//
//  AdminViewController.h
//  Rented
//
//  Created by Cristian Olteanu on 2/5/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdminViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic)     IBOutlet    UITableView*   tableView;
@property (weak, nonatomic)     IBOutlet    UILabel*       loadingLabel;

@property (strong, nonatomic)               NSArray*        userArray;

@end
