//
//  SLVTableViewCell.h
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLVTableViewCell : UITableViewCell

@property (strong,nonatomic) UILabel *name;
@property (strong,nonatomic) UILabel *adress;
@property (strong,nonatomic) UILabel *openNow;
@property (strong,nonatomic) UILabel *type;
@property (strong,nonatomic) UILabel *weekDays;
@property (strong,nonatomic) UIImageView *logo;
@property (strong,nonatomic) UILabel *distance;

@end
