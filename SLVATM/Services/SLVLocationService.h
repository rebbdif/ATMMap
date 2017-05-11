//
//  SLVLocationService.h
//  SLVATM
//
//  Created by 1 on 11.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;




@interface SLVLocationService : NSObject

@property(strong,nonatomic) CLLocation *location;
@property(strong,nonatomic) CLLocationManager *locationManager;

- (void)getLocationWithCompletionHandler:(void (^)(NSDictionary *parameters))completionHandler;

@end
