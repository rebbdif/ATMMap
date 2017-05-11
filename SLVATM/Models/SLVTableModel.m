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
@import CoreLocation;

@interface SLVTableModel()

@property (strong,nonatomic,readonly) SLVNetworkService *networkService;
@property (strong,nonatomic) NSString *nextPageToken;

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

- (void) downloadAtmArrayWithParameters: (NSDictionary *)parameters withCompletionHandler:(void (^)(NSArray *results))completionHandler{
    CLLocation *location = parameters[@"location"];
    NSString *openNow = parameters [@"opennow"];
    if (!self.nextPageToken) {
        self.nextPageToken=@"";
    }
    NSString *pagetoken = [NSString stringWithFormat:@"pagetoken=%@",self.nextPageToken];
    NSString *token = @"AIzaSyC593iluNjtK6A-NYWtD6f9sl10c8I8JQU";
    token = @"AIzaSyCazMVbBSXWGczcdsVJfQTuEwJlOAIg4V0";
    NSString* url= [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&type=bank&rankby=distance&language=RU&%@%@&key=%@",location.coordinate.latitude,location.coordinate.longitude,openNow,pagetoken,token];
    __weak typeof(self) weakself=self;
    [self.networkService downloadDataFromUrl:[NSURL URLWithString:url] withCompletionHandler:^(NSData *data) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(!json){
            NSLog(@"NSJSONSerialization error %@",error);
        }else{
            if (json[@"error_message"]){
                NSLog(@"error %@",json[@"error_message"]);
            }else{
                NSMutableArray *newItems = [NSMutableArray new];
                for (NSDictionary *dict in json[@"results"]) {
                    [newItems addObject:[SLVATMModel atmWithDictionary:dict]];
                }
                weakself.atmsArray = [weakself.atmsArray arrayByAddingObjectsFromArray:newItems];
                NSLog(@"sel.atmsarray.count%lu",(unsigned long)weakself.atmsArray.count);
                weakself.nextPageToken=json[@"next_page_token"];
                completionHandler(weakself.atmsArray);
            }
        }
    }];
}




@end
