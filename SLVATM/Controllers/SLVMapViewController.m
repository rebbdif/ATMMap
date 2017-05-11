//
//  SLVMapViewController.m
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import "SLVMapViewController.h"
#import "SLVLocationService.h"
#import "SLVTableModel.h"
#import "SLVATMModel.h"
@import GooglePlaces;
@import CoreLocation;
@import GoogleMaps;

@interface SLVMapViewController () <GMSMapViewDelegate>

@property (strong,nonatomic) SLVLocationService *slvLocationService;
@property (strong,nonatomic) SLVTableModel *model;

@end

@implementation SLVMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.slvLocationService = [SLVLocationService new];
    self.model = [SLVTableModel new];
    __weak typeof(self) weakself=self;
    [self.slvLocationService getLocationWithCompletionHandler:^(NSDictionary *parameters) {
        CLLocation *currentLocation = parameters[@"location"];
        GMSCameraPosition *currentLocationCameraPosition = [GMSCameraPosition cameraWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude zoom:12];
        [((GMSMapView *)weakself.view) setCamera:currentLocationCameraPosition];
        [weakself.model downloadAtmArrayWithParameters:parameters withCompletionHandler:^(NSArray *results){
            for (SLVATMModel *atm in results) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CLLocationCoordinate2D markerPosition = CLLocationCoordinate2DMake([atm.latitude doubleValue], [atm.longitude doubleValue]);
                    GMSMarker *marker = [GMSMarker markerWithPosition:markerPosition];
                    marker.title = atm.name;
                    marker.map = ((GMSMapView *)weakself.view);
                });
            }
        }];
    }];
}

- (void)loadView{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:55.741 longitude:37.621 zoom:12];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.settings.compassButton = YES;
    mapView.delegate = self;
    self.view = mapView;
}


@end
