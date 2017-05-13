//
//  Decorator.m
//  SLVATM
//
//  Created by 1 on 13.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import "Decorator.h"

@implementation Decorator

+ (UIButton *)roundButtonWithlabel:(NSString*)label image:(UIImage*)image frame:(CGRect)frame {
    UIButton *button = [UIButton new];
    button.frame=frame;
    button.layer.cornerRadius=frame.size.width/2;
    button.layer.shadowOffset=CGSizeMake(2, 2);
    button.layer.shadowRadius=0.5;
    button.layer.borderColor=[UIColor grayColor].CGColor;
    button.layer.borderWidth=0.1;
    button.backgroundColor=[UIColor redColor];
    button.layer.opacity=0.7;
    [button setTitle:label forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    if (image){
        button.layer.contents=CFBridgingRelease([image CGImage]);
        button.layer.contentsGravity=kCAGravityResize;
        button.layer.masksToBounds=YES;
        button.layer.shouldRasterize=YES;
    }
    return button;
}


@end
