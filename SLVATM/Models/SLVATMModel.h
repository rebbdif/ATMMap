//
//  SLVATMModel.h
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface SLVATMModel : NSObject

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *adress;
@property (strong,nonatomic) NSString *openNow;
@property (strong,nonatomic) NSString *type;
@property (strong,nonatomic) NSString *weekDays;

@property (strong,nonatomic) NSNumber *latitude;
@property (strong,nonatomic) NSNumber *longitude;

@property (strong,nonatomic) NSString *logoURL;
@property (strong,nonatomic) UIImage *logo;
@property (strong,nonatomic) NSNumber *distance;

+ (SLVATMModel *)atmWithDictionary: (NSDictionary *)dictionary;

@end
