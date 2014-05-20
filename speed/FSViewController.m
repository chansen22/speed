//
//  FSViewController.m
//  speed
//
//  Created by Christopher Hansen on 5/19/14.
//  Copyright (c) 2014 Wanderful Media. All rights reserved.
//

#import "FSViewController.h"

#import <CoreLocation/CoreLocation.h>

@interface FSViewController () <CLLocationManagerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UITextField *accuracyTextField;
@property (weak, nonatomic) IBOutlet UITextField *distanceFilterTextField;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (nonatomic) BOOL updating;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;

@end

@implementation FSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.updating = NO;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 600.0f;
    
    self.accuracyTextField.text = @"100";
    self.distanceFilterTextField.text = @"600";
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.accuracyTextField resignFirstResponder];
    [self.distanceFilterTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:.2 animations:^{
        self.bottomLayoutConstraint.constant += 100;
        [self.view layoutIfNeeded];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.accuracyTextField) {
        self.locationManager.desiredAccuracy = [textField.text doubleValue];
    } else {
        self.locationManager.distanceFilter = [textField.text doubleValue];
    }
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startUpdatingLocation];
    [self.locationButton setTitle:@"Stop Updating" forState:UIControlStateNormal];
    [UIView animateWithDuration:.2 animations:^{
        self.bottomLayoutConstraint.constant -= 100;
        [self.view layoutIfNeeded];
    }];
}

@end
