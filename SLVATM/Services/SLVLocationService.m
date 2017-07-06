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

@property (copy, nonatomic, nullable) void (^completionHandler)(NSDictionary *, NSError *);
@property (assign, nonatomic) CLAuthorizationStatus previousAuthorizationStatus;

@end

@implementation SLVLocationService

- (void)getLocationWithCompletionHandler:(void (^_Nullable)(NSDictionary * _Nullable parameters, NSError *_Nullable error))completionHandler{
    if (!self.locationManager) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.distanceFilter = 500;
        self.locationManager.headingFilter = 10;
    }
    self.previousAuthorizationStatus = [CLLocationManager authorizationStatus];
    if (self.previousAuthorizationStatus != 4) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self.locationManager startUpdatingLocation];
    }
    self.completionHandler = completionHandler;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (self.previousAuthorizationStatus != 4) {
        if (status == 4){
            [self.locationManager startUpdatingLocation];
        } if (status == 2){
            NSString *errorMessage = @"Вам необходимо разрешить приложению доступ к геолокации. Вы можете сделать это в настройках";
            NSError *humanUnderstandableError = [NSError errorWithDomain:kCLErrorDomain code:1 userInfo:@{@"info":errorMessage}];
            self.completionHandler(nil, humanUnderstandableError);
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *newLocation = [locations lastObject];
    CLLocation *previousLocation = self.location;
    
    if ((newLocation.horizontalAccuracy <= previousLocation.horizontalAccuracy &&
         [newLocation distanceFromLocation:previousLocation] <= newLocation.horizontalAccuracy) ||
        [newLocation.timestamp timeIntervalSinceDate:previousLocation.timestamp]<5)
    {
        return;
    } else {
        self.location = newLocation;
        NSDictionary *parameters = @{@"location": self.location, @"opennow":@"", @"pagetoken":@"", @"resetPreviousResults":@YES};
        self.completionHandler(parameters,nil);
    }
}

@end
