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
#import "Decorator.h"
@import GoogleMaps;

@interface SLVMapViewController () <GMSMapViewDelegate>

@property (assign,nonatomic) float currentZoom;

@end

@implementation SLVMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadView {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:55.741 longitude:37.621 zoom:12];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.settings.compassButton = YES;
    mapView.settings.myLocationButton = YES;
    mapView.myLocationEnabled=YES;
    mapView.delegate = self;
    mapView.padding = UIEdgeInsetsMake(0, 0, 44, 0);
    self.view = mapView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) weakself=self;
    [self.model runWithCompletionHandler:^(NSArray *results, NSError *error) {
        if (error){
            UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"location error" message:error.userInfo[@"info"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        if (results){
            CLLocation *currentLocation = self.model.slvLocationService.location;
            dispatch_async(dispatch_get_main_queue(), ^{
                GMSCameraPosition *currentLocationCameraPosition = [GMSCameraPosition cameraWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude zoom:14];
                [((GMSMapView *)weakself.view) setCamera:currentLocationCameraPosition];
                for (SLVATMModel *atm in results) {
                    CLLocationCoordinate2D markerPosition = CLLocationCoordinate2DMake([atm.latitude doubleValue], [atm.longitude doubleValue]);
                    GMSMarker *marker = [GMSMarker markerWithPosition:markerPosition];
                    marker.title = atm.name;
                    marker.snippet = [NSString stringWithFormat:@"%@ | %@",atm.openNow, atm.adress];
                    marker.map = ((GMSMapView *)weakself.view);
                    if ([atm.openNow isEqualToString:@"closed"]){
                        marker.icon = [GMSMarker markerImageWithColor:[UIColor lightGrayColor]];
                    }
                }
            });
        }
    }];
    
    CGRect bounds=self.view.bounds;
    CGFloat w=bounds.size.width - 45;
    UIButton *zoomInButton= [Decorator roundButtonWithlabel:@"+" image:nil frame:CGRectMake(w, bounds.size.height/2-80 , 35, 35)];
    [zoomInButton addTarget:self action:@selector(zoomIn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zoomInButton];
    UIButton *zoomOutButton= [Decorator roundButtonWithlabel:@"-" image:nil frame:CGRectMake(w, bounds.size.height/2 - 40, 34, 34)];
    [zoomOutButton addTarget:self action:@selector(zoomOut:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zoomOutButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.currentZoom = 12;
    [self addAnimatedHint];
    if (self.model.selectedAtm){
        SLVATMModel *selectedAtm = self.model.selectedAtm;
        CLLocationCoordinate2D currentLocation = self.model.slvLocationService.location.coordinate;
        CLLocationCoordinate2D desiredLocation = CLLocationCoordinate2DMake([selectedAtm.latitude doubleValue], [selectedAtm.longitude doubleValue]);
        __weak typeof(self) weakself = self;
        [self.model downloadRouteFromLocation:currentLocation toLocation:desiredLocation withPresentingCompletionHandler:^(NSDictionary *json) {
            [self buildRoute:json forView:weakself.view];
        }];
        self.model.selectedAtm=nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [((GMSMapView*)(self.view)) clear];
}

- (void)addAnimatedHint {
    UILabel *hintView = [UILabel new];
    hintView.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:0.2];
    CGRect frame = self.view.frame;
    hintView.frame=CGRectMake(8, 25, CGRectGetWidth(frame)-16, 20);
    hintView.text = @"Чтобы построить маршрут нажмите на описание банкомата";
    hintView.font = [UIFont systemFontOfSize:10];
    hintView.numberOfLines = 2;
    [hintView adjustsFontSizeToFitWidth];
    [self.view addSubview:hintView];
    [UIView animateWithDuration:2 delay:4 options:UIViewAnimationOptionTransitionNone animations:^{
        hintView.layer.opacity = 0;
    } completion:^(BOOL finished) {
        hintView.hidden=YES;
    }];
}

#pragma mark GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(nonnull GMSMarker *)marker {
    CLLocationCoordinate2D myLocation = ((GMSMapView*)(self.view)).myLocation.coordinate;
    CLLocationCoordinate2D finishLocation = marker.position;
    __weak typeof(self) weakself = self;
    [self.model downloadRouteFromLocation:myLocation toLocation:finishLocation withPresentingCompletionHandler:^(NSDictionary *json) {
        [self buildRoute:json forView:weakself.view];
    }];
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    CLLocation *selectedLocation = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    NSDictionary *parameters = @{@"location": selectedLocation, @"opennow":@"", @"pagetoken":@"", @"resetPreviousResults":@YES};
    __weak typeof(self) weakself = self;
    [self.model downloadAtmArrayWithParameters:parameters withCompletionHandler:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GMSCameraPosition *currentLocationCameraPosition = [GMSCameraPosition cameraWithLatitude:selectedLocation.coordinate.latitude longitude:selectedLocation.coordinate.longitude zoom:14];
            [((GMSMapView *)weakself.view) setCamera:currentLocationCameraPosition];
            for (SLVATMModel *atm in results) {
                CLLocationCoordinate2D markerPosition = CLLocationCoordinate2DMake([atm.latitude doubleValue], [atm.longitude doubleValue]);
                GMSMarker *marker = [GMSMarker markerWithPosition:markerPosition];
                marker.title = atm.name;
                marker.snippet = [NSString stringWithFormat:@"%@ | %@",atm.openNow, atm.adress];
                marker.map = ((GMSMapView *)weakself.view);
                if ([atm.openNow isEqualToString:@"closed"]){
                    marker.icon = [GMSMarker markerImageWithColor:[UIColor lightGrayColor]];
                }
            }
        });
    }];
}

- (void)buildRoute:(NSDictionary *)json forView:(UIView *)view {
    GMSMutablePath *path = [GMSMutablePath path];
    NSDictionary *route = json[@"routes"][0];
    NSDictionary *legs = route[@"legs"][0];
    NSArray *steps = legs[@"steps"];
    for (NSDictionary * step in steps) {
        NSDictionary *startLocation = step[@"start_location"];
        NSDictionary *endLocation = step[@"end_location"];
        [path addLatitude:[startLocation[@"lat"]doubleValue] longitude:[startLocation[@"lng"]doubleValue]];
        [path addLatitude:[endLocation[@"lat"]doubleValue] longitude:[endLocation[@"lng"]doubleValue]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        polyline.strokeWidth =2.0;
        polyline.map=((GMSMapView *) view);
    });
}

-(IBAction)zoomIn:(id)sender{
    self.currentZoom++;
    [((GMSMapView*)self.view)animateToZoom:self.currentZoom];
}

-(IBAction)zoomOut:(id)sender{
    self.currentZoom--;
    [((GMSMapView*)self.view)animateToZoom:self.currentZoom];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.model.atmsArray = nil;
}

@end




