//
//  SLVTableModel.m
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import "SLVTableModel.h"
#import "SLVNetworkService.h"
#import "SLVATMModel.h"

@interface SLVTableModel()

@property(strong,nonatomic,readonly) SLVNetworkService *networkService;

@end

@implementation SLVTableModel

- (instancetype) init{
    self=[super init];
    if(self){
        _atmsArray = [NSArray new];
        _networkService = [SLVNetworkService new];
    }
    return self;
}

- (void) downloadAtmArrayFromUrl: (NSString *)url withCompletionHandler:(void (^)(void))completionHandler{
    [self.networkService downloadDataFromUrl:[NSURL URLWithString:url] withCompletionHandler:^(NSData *data) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(!json){
            NSLog(@"NSJSONSerialization error %@",error);
        }else{
            NSMutableArray *newItems = [NSMutableArray new];
            for (NSDictionary *dict in json[@"results"]) {
                [newItems addObject:[SLVATMModel atmWithDictionary:dict]];
            }
            self.atmsArray = newItems;
        }
    }];
}


@end
