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
#import "SLVLocationService.h"
@import CoreLocation;

@interface SVLTableViewController () <UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) SLVLocationService *slvLocationService;

@end

@implementation SVLTableViewController

static NSString * const reuseID = @"atmCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect frame = self.view.frame;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(frame), CGRectGetHeight(frame)-64)];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.tableView registerClass:[SLVTableViewCell class] forCellReuseIdentifier:reuseID];
    self.tableView.rowHeight = 64;
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak typeof(self) weakself = self;
    [self.model runWithCompletionHandler:^(NSArray *results, NSError *error) {
        [weakself.tableView reloadData];
    }];
}

#pragma Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SLVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    SLVATMModel *currentAtm = self.model.atmsArray[indexPath.row];
    cell.name.text=currentAtm.name;
    cell.adress.text=currentAtm.adress;
    CGSize textSize = [currentAtm.adress sizeWithAttributes:@{@"NSFontAttributeName": currentAtm.adress}];
    if (textSize.width>cell.adress.bounds.size.width+20) {
        cell.adress.numberOfLines=2;
        cell.adress.adjustsFontSizeToFitWidth=YES;
    }else {
        cell.adress.numberOfLines=1;
    }
    cell.openNow.text=currentAtm.openNow;
    if([cell.openNow.text isEqualToString:@"closed"]) {
        cell.openNow.textColor=[UIColor lightGrayColor];
    }else {
        cell.openNow.textColor=[UIColor blackColor];
    }
    cell.distance.text=[NSString stringWithFormat:@"%@", (currentAtm.distance)?(currentAtm.distance):@" "];
    if (!currentAtm.logo) {
        if ([currentAtm.type isEqual:@"atm"]) {
            cell.logo.image = [UIImage imageNamed:@"atm"];
        }else if ([currentAtm.type isEqual:@"bank"]) {
            cell.logo.image = [UIImage imageNamed:@"bank"];
        }
    }
    if (indexPath.row==self.model.atmsArray.count-1 && indexPath.row>15) {
        NSDictionary *parameters = @{@"opennow":@"", @"pagetoken":@"pagetoken"};
        __weak typeof(self) weakself = self;
        [self.model downloadAtmArrayWithParameters:parameters withCompletionHandler:^(NSArray *results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.tableView reloadData];
            });
        }];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.atmsArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}




@end
