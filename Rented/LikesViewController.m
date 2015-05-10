//
//  LikesViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 2/17/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "LikesViewController.h"
#import "LikesTableViewCell.h"

@interface LikesViewController ()

@end

@implementation LikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:@"LikesTableViewCell" bundle:nil] forCellReuseIdentifier:@"LikesTableViewCell"];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    [DEP.api.apartmentApi userApartment:^(PFObject *apartment, NSArray *images, BOOL succeeded) {
        
        if(succeeded)
        {
            
            PFQuery* query = [PFQuery queryWithClassName:@"Favorites"];
            [query whereKey:@"apartment" equalTo:apartment];
            [query includeKey:@"user"];
            [query orderByDescending:@"timestamp"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
            {
                self.favoritesArray = objects;
                [self.tableView reloadData];
            }
             ];
        }
    }];
  
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.favoritesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LikesTableViewCell *cell = (LikesTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:@"LikesTableViewCell" forIndexPath:indexPath];
    
    if(!cell)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LikesTableViewCell" owner:self options:nil] firstObject];
    
    PFObject *favorite = [self.favoritesArray objectAtIndex:indexPath.row];
    
    [cell customiseWithObject:favorite];
    
    return cell;
}

-(IBAction)backButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
