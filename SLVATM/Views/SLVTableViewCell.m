//
//  SLVTableViewCell.m
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import "SLVTableViewCell.h"
@import Masonry;

@implementation SLVTableViewCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        _name = [UILabel new];
        _adress = [UILabel new];
        _adress.font = [UIFont systemFontOfSize:14];
        _openNow = [UILabel new];
        _distance = [UILabel new];
        _distance.textAlignment = NSTextAlignmentCenter;
        _distance.font = [UIFont systemFontOfSize:10];
        _logo = [UIImageView new];
        _logo.layer.masksToBounds=YES;
        _logo.layer.cornerRadius=20;
        _logo.layer.borderWidth=1;
        _logo.layer.borderColor=[UIColor lightGrayColor].CGColor;
        _logo.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
        
        NSArray *views = @[_name, _adress, _openNow, _distance,_logo];
        for (id view in views) {
            [SLVTableViewCell decorateView:view];
            [self addSubview:view];
        }
    }
    return self;
}

+ (void)decorateView:(UIView *)view{
   // view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.5];
}

+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (void)updateConstraints{
    UIEdgeInsets padding =UIEdgeInsetsMake(6, 8, 4, 8);
    UIView *contentView = self.contentView;
    
    [self.logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView.mas_top).with.offset(padding.top);
        make.left.equalTo(contentView.mas_left).with.offset(padding.left);
        make.size.equalTo(@40);
    }];
    
    [self.openNow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView.mas_top).with.offset(padding.top);
        make.right.equalTo(contentView.mas_right).with.offset(-padding.right);
        make.width.equalTo(@40);
        make.height.equalTo(@20);
    }];
    [self.openNow setAdjustsFontSizeToFitWidth:YES];
    self.openNow.textAlignment = NSTextAlignmentCenter;
    self.openNow.font = [UIFont boldSystemFontOfSize:12.0];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView.mas_top).with.offset(padding.top);
        make.left.equalTo(self.logo.mas_right).with.offset(padding.left);
        make.right.equalTo(self.openNow.mas_left).with.offset(-8);
        make.height.equalTo(@20);
    }];
    
    [self.adress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.name.mas_left);
        make.right.equalTo(contentView.mas_right).with.offset(-padding.right);
        make.top.equalTo(self.name.mas_bottom).with.offset(4);
        make.bottom.equalTo(contentView.mas_bottom).with.offset(-padding.bottom);
    }];
    
    [self.distance mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.logo.mas_left).with.offset(4);
        make.right.equalTo(self.logo.mas_right).with.offset(-4);
        make.top.greaterThanOrEqualTo(self.logo.mas_bottom).with.offset(2);
        make.bottom.equalTo(contentView.mas_bottom).with.offset(-padding.bottom);
    }];
    
    [super updateConstraints];
}




@end
