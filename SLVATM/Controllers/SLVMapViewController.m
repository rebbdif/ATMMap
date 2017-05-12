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
@import GoogleMaps;

@interface SLVMapViewController () <GMSMapViewDelegate>

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UILabel *hintView = [UILabel new];
    hintView.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:0.2];
    CGRect frame = self.view.frame;
    hintView.frame=CGRectMake(8, 25, CGRectGetWidth(frame)-16, 20);
    hintView.text = @"Чтобы построить маршрут нажмите на описание банкомата";
    hintView.font = [UIFont systemFontOfSize:10];
    hintView.numberOfLines = 2;
    [hintView adjustsFontSizeToFitWidth];
    [self.view addSubview:hintView];
    [UIView animateWithDuration:2 delay:5 options:UIViewAnimationOptionTransitionNone animations:^{
        hintView.layer.opacity = 0;
    } completion:^(BOOL finished) {
        hintView.hidden=YES;
    }];
}

- (void)addMarkersForController: (UIViewController *) weakself {
    
    
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(nonnull GMSMarker *)marker {
    CLLocation *myLocation = ((GMSMapView*)(self.view)).myLocation;
    NSString *origin=[NSString stringWithFormat:@"origin=%f,%f",myLocation.coordinate.latitude,myLocation.coordinate.longitude];
    NSString *destination=[NSString stringWithFormat:@"destination=%f,%f",marker.position.latitude,marker.position.longitude];;
    NSString *mode =@"mode=walking";
    NSString *key=@"AIzaSyCazMVbBSXWGczcdsVJfQTuEwJlOAIg4V0";
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?%@&%@&%@&key=&%@",origin,destination,mode,key];
    
    __weak typeof(self) weakself=self;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error){
            NSLog(@"network error when getting route %@",error.userInfo);
        }else{
            NSError *jsonError=nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (!json) {
                NSLog(@"serialization Error");
            }else{
                if (json[@"routes"]) {
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
                        polyline.map=((GMSMapView *)weakself.view);
                    });
                }
            }
        }
    }];
    [task resume];
}

@end




