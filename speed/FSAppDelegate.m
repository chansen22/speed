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
        _locationManager.distanceFilter = 10;
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
    if (notification.userInfo[@"tmp"]) {
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
            [[[UIAlertView alloc] initWithTitle:@"" message:notification.alertBody delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    if (notification.userInfo[@"notifications"]) {
        UILocalNotification *closestNotification = (UILocalNotification *)notification.userInfo[@"notifications"][0];
        NSData *jsonStringData = [closestNotification.userInfo[@"action"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *closestJson = [NSJSONSerialization JSONObjectWithData:jsonStringData options:0 error:nil];
        CLLocation *closestStoreLocation = [[CLLocation alloc] initWithLatitude:[closestJson[@"lat"] doubleValue] longitude:[closestJson[@"lon"] doubleValue]];
        CLLocationDistance closestDistance = [closestStoreLocation distanceFromLocation:self.currentLocation];
        for (UILocalNotification *note in notification.userInfo[@"notifications"]) {
            NSData *jsonStringData = [note.userInfo[@"action"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonStringData options:0 error:nil];
            CLLocation *storeLocation = [[CLLocation alloc] initWithLatitude:[json[@"lat"] doubleValue] longitude:[json[@"lon"] doubleValue]];
            CLLocationDistance meters = [storeLocation distanceFromLocation:self.currentLocation];
            
            if (meters < closestDistance) {
                closestStoreLocation = storeLocation;
                closestDistance = meters;
                closestNotification = note;
            }
        }
        if (closestDistance < 50 && self.currentLocation.speed < 5)
            [Plot handleNotification:closestNotification];
    } else {
        NSData *jsonStringData = [notification.userInfo[@"action"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonStringData options:0 error:nil];
        CLLocation *storeLocation = [[CLLocation alloc] initWithLatitude:[json[@"lat"] doubleValue] longitude:[json[@"lon"] doubleValue]];
        CLLocationDistance meters = [storeLocation distanceFromLocation:self.currentLocation];
        
        if (meters < 50 && self.currentLocation.speed < 5) // check speed here too?
            [Plot handleNotification:notification];
    }
}

- (void)plotFilterNotifications:(PlotFilterNotifications *)filterNotifications {
    [self.locationManager startUpdatingLocation];
    UILocalNotification *loc = [[UILocalNotification alloc] init];
    if ([filterNotifications.uiNotifications count] > 1)
        [loc setUserInfo:@{@"notifications":filterNotifications.uiNotifications}];
    else
        loc = filterNotifications.uiNotifications[0];
    loc.fireDate = [[NSDate date] dateByAddingTimeInterval:300];
    [[UIApplication sharedApplication] scheduleLocalNotification:loc];
    
    UILocalNotification *notifier = [[UILocalNotification alloc] init];
    notifier.alertBody = [NSString stringWithFormat:@"Filtered Notification: %@", [[filterNotifications.uiNotifications[0] userInfo] objectForKey:@"message"]];
    notifier.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
    notifier.userInfo = @{@"action":@"", @"tmp":@(YES)};
    [[UIApplication sharedApplication] scheduleLocalNotification:notifier];
}

- (void)plotHandleNotification:(UILocalNotification *)notification data:(NSString *)data {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [[[UIAlertView alloc] initWithTitle:@"" message:notification.alertBody delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil] show];
    }
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = [locations lastObject];
}

@end
