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

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *adress;
@property (copy, nonatomic) NSString *openNow;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *weekDays;

@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;

@property (copy, nonatomic) NSString *logoURL;
@property (strong, nonatomic) UIImage *logo;
@property (strong, nonatomic) NSNumber *distance;

+ (SLVATMModel *)atmWithDictionary:(NSDictionary *)dictionary;

@end
