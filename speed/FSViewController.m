//
//  FSViewController.m
//  speed
//
//  Created by Christopher Hansen on 5/19/14.
//  Copyright (c) 2014 Wanderful Media. All rights reserved.
//

#import "FSViewController.h"

#import <CoreLocation/CoreLocation.h>

@interface FSViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (nonatomic) BOOL updating;

@end

@implementation FSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.updating = NO;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 600.0f;
//    self.locationManager.distanceFilter = kCLDistanceFilterNone;
}

- (IBAction)toggleLocationServices:(UIButton *)sender {
    if (self.updating) {
        [self.locationManager stopUpdatingLocation];
        [self.locationButton setTitle:@"Start Location Updating" forState:UIControlStateNormal];
    } else {
        [self.locationManager startUpdatingLocation];
        [self.locationButton setTitle:@"Stop Updating" forState:UIControlStateNormal];
    }
    self.updating = !self.updating;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = [locations lastObject];
    self.speedLabel.text = [NSString stringWithFormat:@"%g", self.currentLocation.speed];
}

@end
