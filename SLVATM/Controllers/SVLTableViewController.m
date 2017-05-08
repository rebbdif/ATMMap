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

@interface SVLTableViewController () <UITableViewDelegate,UITableViewDataSource>

@property(strong,nonatomic) UITableView *tableView;
@property(strong,nonatomic) SLVTableModel *model;

@end

@implementation SVLTableViewController

static NSString * const reuseID = @"atmCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect frame = self.view.frame;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.tableView registerClass:[SLVTableViewCell class] forCellReuseIdentifier:reuseID];
    
    self.model = [SLVTableModel new];
    NSString *url = @" ";
    __weak typeof(self) weakself = self;
    [self.model downloadAtmArrayFromUrl:url withCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
        });
    }];
}

#pragma Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SLVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.model.atmsArray.count;
}


@end
