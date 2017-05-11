//
//  SLVATMModel.m
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import "SLVATMModel.h"

@implementation SLVATMModel

+ (SLVATMModel *)atmWithDictionary: (NSDictionary *)dictionary{
    SLVATMModel *atm = [SLVATMModel new];
    atm.name = dictionary[@"name"];
    atm.adress = dictionary[@"vicinity"];
    [dictionary[@"opening_hours"][@"open_now"] boolValue]?(atm.openNow=@"open"):(atm.openNow=@"closed");
    
    NSSet *types=[NSSet setWithArray:dictionary[@"types"]];
    if ([types containsObject:@"atm"]){
        atm.type=@"atm";
    }else if([types containsObject:@"bank"]){
        atm.type=@"bank";
    }else{
        atm.type=@"?";
    }
    atm.weekDays=dictionary[@"weekday_text"];
    
    NSDictionary *coordinate = dictionary[@"geometry"][@"location"];
    atm.latitude=coordinate[@"lat"];
    atm.longitude=coordinate[@"lng"];
    
    return atm;
}

@end
