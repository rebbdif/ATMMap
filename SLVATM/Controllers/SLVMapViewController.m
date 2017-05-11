//
//  SLVMapViewController.m
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import "SLVMapViewController.h"
@import GooglePlaces;
@import CoreLocation;

@interface SLVMapViewController () 
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UIButton *getCurrentPlaceButton;
@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (assign, nonatomic) BOOL showsUserLocation;
@property (strong ,nonatomic) CLLocationManager *locationManager;
@end

@implementation SLVMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    CGRect frame = self.view.frame;
    self.nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(8, 28, CGRectGetWidth(frame)-16, 20)];
    self.addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 56, CGRectGetWidth(frame)-16, 20)];
    [self.view addSubview:[self decorateView:self.nameLabel]];
    [self.view addSubview:[self decorateView:self.addressLabel]];
    self.getCurrentPlaceButton =[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(frame)/2-40, CGRectGetHeight(frame)-44-20-8, 80, 20)];
    [self.getCurrentPlaceButton setTitle:@"Л" forState:UIControlStateNormal];
    self.getCurrentPlaceButton.backgroundColor = [UIColor redColor];
    [self.getCurrentPlaceButton addTarget:self action:@selector(getCurrentPlace:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.getCurrentPlaceButton];
    _placesClient = [GMSPlacesClient sharedClient];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.showsUserLocation = YES;
    } else {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
}

- (UIView *) decorateView: (UIView *) view{
    view.backgroundColor = [UIColor whiteColor];
    view.tintColor = [UIColor blackColor];
    view.layer.borderColor = [UIColor blueColor].CGColor;
    view.layer.borderWidth = 1;
    return view;
}

- (IBAction)getCurrentPlace:(UIButton *)sender {
    
    [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        self.nameLabel.text = @"No current place";
        self.addressLabel.text = @"";
        
        if (placeLikelihoodList != nil) {
            GMSPlace *place = [[[placeLikelihoodList likelihoods] firstObject] place];
            if (place != nil) {
                self.nameLabel.text = place.name;
                self.addressLabel.text = [[place.formattedAddress componentsSeparatedByString:@", "]
                                          componentsJoinedByString:@"\n"];
            }
        }
    }];
}



@end
