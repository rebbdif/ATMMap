//
//  SLVLocationService.m
//  SLVATM
//
//  Created by 1 on 11.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import "SLVLocationService.h"
#import "UIKit/UIKit.h"

@interface SLVLocationService()<CLLocationManagerDelegate>
@property (nonatomic, copy, nullable) void (^completionHandler)(NSDictionary *);
@end

@implementation SLVLocationService

- (void)getLocationWithCompletionHandler:(void (^)(NSDictionary *parameters))completionHandler{
    if(!self.locationManager){
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate=self;
        self.locationManager.desiredAccuracy= kCLLocationAccuracyHundredMeters;
        self.locationManager.distanceFilter = 100;
    }
    if (CLLocationManager.authorizationStatus != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager requestWhenInUseAuthorization];
    }else{
        [self.locationManager startUpdatingLocation];
    }
    self.completionHandler=completionHandler;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [self.locationManager stopUpdatingLocation];
    self.locationManager=nil;
    self.location = [locations lastObject];
    NSDictionary *parameters = @{@"location": self.location, @"opennow":@"", @"pagetoken":@"pagetoken"};
    self.completionHandler(parameters);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [manager stopUpdatingLocation];
    NSLog(@"error%@",error);
    NSString *errorMessage;
    switch([error code])
    {
        case kCLErrorNetwork:
        {
            errorMessage = @"please check your network connection or that you are not in airplane mode";
        }
            break;
        case kCLErrorDenied:{
            errorMessage = @"user has denied to use current Location";
        }
            break;
        default:
        {
            errorMessage = @"something went wrong. restart the app";
        }
    }
    UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"location error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:okAction];
    /*
    [self presentViewController:alert animated:YES completion:^{
        NSLog(@"FAKING LOCATION BECAUSE OF ERROR");
        CLLocation *fakeLocation = [[CLLocation alloc]initWithLatitude:55.632907 longitude:37.53569];
        [self locationManager:self.locationManager didUpdateLocations:@[fakeLocation]];
    }];
     */
}


@end
