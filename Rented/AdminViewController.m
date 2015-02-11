//
//  AdminViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 2/5/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "AdminViewController.h"
#import "AdminUserTableViewCell.h"

@interface AdminViewController ()

@end

@implementation AdminViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setAllowsSelection:NO];
    [self loadData];

}

-(void)loadData
{
    [self.loadingLabel setHidden:NO];
    [self.tableView setHidden:YES];
    
    //get all the users
    [DEP.api.userApi getListOfUsers:^(NSArray *users, BOOL succeeded) {
       
        PFQuery* verifiedUsers = [PFQuery queryWithClassName:@"UserMetaData"];
        
        //for every user his additional info
        [verifiedUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            for (PFUser* user in users)
            {
                user[@"isVerified"] = [NSNumber numberWithInt:0];
                for(PFObject* object in objects)
                {
                    if ( [[(PFUser*)object[@"user"] objectId] isEqualToString:user.objectId])
                    {
                        user[@"isVerified"] = object[@"isVerified"];
                    }
                }
            }
            [self.loadingLabel setHidden:YES];
            [self.tableView setHidden:NO];
            self.userArray = users;
            [self.tableView reloadData];
        }];
        

        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate and UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.userArray && [self.userArray count]>0)
    {
        return [self.userArray count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AdminUserTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AdminUserTableViewCell"];

    
    if(!cell)
    {
        [self.tableView registerNib:[UINib nibWithNibName:@"AdminUserTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdminUserTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"AdminUserTableViewCell"];
    }
    

    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.layer setMasksToBounds:YES];
    PFUser *user = (PFUser*) [self.userArray objectAtIndex:indexPath.row];
    
    [(AdminUserTableViewCell*)cell customiseWithUser:user];
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}



@end
