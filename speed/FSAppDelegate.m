//
//  FSAppDelegate.m
//  speed
//
//  Created by Christopher Hansen on 5/19/14.
//  Copyright (c) 2014 Wanderful Media. All rights reserved.
//

#import "FSAppDelegate.h"

#import "Plot.h"
#import <CoreLocation/CoreLocation.h>

typedef void (^didRecieveLocationWithSpeedBlock)();

@interface FSAppDelegate() <PlotDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) didRecieveLocationWithSpeedBlock didRecieveLocationWithSpeedBlock;
@end

@implementation FSAppDelegate

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = -1;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    PlotConfiguration *config = [[PlotConfiguration alloc] initWithPublicKey:@"fFVLRFLnwLB0zXbG" delegate:self];
    [Plot initializeWithConfiguration:config launchOptions:launchOptions];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [Plot handleNotification:notification];
}

- (void)plotFilterNotifications:(PlotFilterNotifications *)filterNotifications {
    [self.locationManager startUpdatingLocation];
    
    self.didRecieveLocationWithSpeedBlock = ^{
        NSArray *notifications = filterNotifications.uiNotifications;
        [filterNotifications showNotifications:notifications];
    };
}

- (void)plotHandleNotification:(UILocalNotification *)notification data:(NSString *)data {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [[[UIAlertView alloc] initWithTitle:@"" message:notification.alertBody delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil] show];
    }
}

#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *loc in locations) {
        if (loc.speed > 0 && loc.speed < 5) {
            self.currentLocation = loc;
            [self.locationManager stopUpdatingLocation];
            if (self.didRecieveLocationWithSpeedBlock)
                self.didRecieveLocationWithSpeedBlock();
        }
    }
}

@end
