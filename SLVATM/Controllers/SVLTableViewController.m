//
//  SVLTableViewController.m
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import "SVLTableViewController.h"
#import "SLVATMModel.h"
#import "SLVTableModel.h"
#import "SLVTableViewCell.h"
@import CoreLocation;

@interface SVLTableViewController () <UITableViewDelegate,UITableViewDataSource, CLLocationManagerDelegate>

@property(strong,nonatomic) UITableView *tableView;
@property(strong,nonatomic) SLVTableModel *model;
@property(strong,nonatomic) CLLocationManager *locationManager;

@end

@implementation SVLTableViewController

static NSString * const reuseID = @"atmCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.model = [SLVTableModel new];
    
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect frame = self.view.frame;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(frame), CGRectGetHeight(frame)-64)];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.tableView registerClass:[SLVTableViewCell class] forCellReuseIdentifier:reuseID];
    self.tableView.rowHeight = 64;
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getLocation];
}

#pragma Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SLVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    SLVATMModel *currentAtm = self.model.atmsArray[indexPath.row];
    cell.name.text=currentAtm.name;
    cell.adress.text=currentAtm.adress;
    CGSize textSize = [currentAtm.adress sizeWithAttributes:@{@"NSFontAttributeName": currentAtm.adress}];
    if (textSize.width>cell.adress.bounds.size.width+20){
        cell.adress.numberOfLines=2;
        cell.adress.adjustsFontSizeToFitWidth=YES;
    }else{
        cell.adress.numberOfLines=1;
    }
    cell.openNow.text=currentAtm.openNow;
    cell.distance.text=[NSString stringWithFormat:@"%@", (currentAtm.distance)?(currentAtm.distance):@" "];
    if (!currentAtm.logo){
        if ([currentAtm.type isEqual:@"atm"]){
            cell.logo.image = [UIImage imageNamed:@"atm"];
        }else if ([currentAtm.type isEqual:@"bank"]){
            cell.logo.image = [UIImage imageNamed:@"bank"];
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.model.atmsArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma Location

- (void)getLocation{
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
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation* location = [locations lastObject];
    NSDictionary *parameters = @{@"location": location, @"opennow":@""};
    __weak typeof(self) weakself = self;
    [self.model downloadAtmArrayWithParameters:parameters withCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
        });
    }];
    [self.locationManager stopUpdatingLocation];
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
    [self presentViewController:alert animated:YES completion:^{
        NSLog(@"FAKING LOCATION BECAUSE OF ERROR");
        CLLocation *fakeLocation = [[CLLocation alloc]initWithLatitude:55.632907 longitude:37.53569];
        [self locationManager:self.locationManager didUpdateLocations:@[fakeLocation]];
    }];
}


@end
