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
@property (nonatomic, copy, nullable) void (^completionHandler)(NSDictionary *, NSError *);
@end

@implementation SLVLocationService

- (void) getLocationWithCompletionHandler:(void (^_Nullable)(NSDictionary * _Nullable parameters, NSError *_Nullable error))completionHandler{
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
    self.completionHandler(parameters,nil);
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
    NSError *humanUnderstandableError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{@"info":errorMessage}];
    self.completionHandler(nil,humanUnderstandableError);
           NSLog(@"FAKING LOCATION BECAUSE OF ERROR");
        CLLocation *fakeLocation = [[CLLocation alloc]initWithLatitude:55.632907 longitude:37.53569];
        [self locationManager:self.locationManager didUpdateLocations:@[fakeLocation]];
}


@end
