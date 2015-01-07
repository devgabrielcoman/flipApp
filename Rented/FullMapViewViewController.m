//
//  FullMapViewViewController.m
//  Rented
//
//  Created by Lucian Gherghel on 07/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "FullMapViewViewController.h"
#import "MapUtils.h"

@interface FullMapViewViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation FullMapViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Apartment location";
    [_mapView addAnnotation:_locationPin];
    [MapUtils zoomToFitMarkersOnMap:_mapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
