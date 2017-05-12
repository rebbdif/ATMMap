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
#import "SLVLocationService.h"
#import "SLVMapViewController.h"
#import "SVLTableViewController.h"
@import CoreLocation;

@interface SLVTableModel()

@property (strong,nonatomic,readonly) SLVNetworkService *networkService;
@property (strong,nonatomic) NSString *nextPageToken;

@end

static NSString *const apiKey = @"AIzaSyCazMVbBSXWGczcdsVJfQTuEwJlOAIg4V0";

@implementation SLVTableModel

- (instancetype) init {
    self=[super init];
    if(self){
        _atmsArray = [NSArray new];
        _networkService = [SLVNetworkService new];
        _slvLocationService = [SLVLocationService new];
        _nextPageToken = @"";
    }
    return self;
}

- (void)runWithCompletionHandler:(void(^)(NSArray *results, NSError *error))presentingCompletionHandler {
    if(0==self.atmsArray.count) {
        __weak typeof(self) weakself=self;
        [self.slvLocationService getLocationWithCompletionHandler:^(NSDictionary *parameters, NSError *error) {
            if (parameters) {
            [weakself downloadAtmArrayWithParameters:parameters withCompletionHandler:^(NSArray *results) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    presentingCompletionHandler(results,nil);
                });
            }];
            } else {
                presentingCompletionHandler(nil, error);
            }
        }];
    } else {
        presentingCompletionHandler(self.atmsArray,nil);
    }
}

- (void)downloadAtmArrayWithParameters:(NSDictionary *)parameters withCompletionHandler:(void (^)(NSArray *results))completionHandler {
    CLLocation *location = parameters[@"location"];
    if (!location){
        location=self.slvLocationService.location;
    }
    NSString *openNow = parameters [@"opennow"];
    NSString *pagetoken = [NSString stringWithFormat:@"pagetoken=%@",self.nextPageToken];
    if([self.nextPageToken isEqualToString:@"ended"]){
        // потому что апи отдает только 60 результатов, потом перестает присылать nextPageToken
        return;
    }
    NSString* url= [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&type=bank&rankby=distance&language=RU&%@%@&key=%@",location.coordinate.latitude,location.coordinate.longitude,openNow,pagetoken,apiKey];
    
    [self.networkService downloadDataFromUrl:[NSURL URLWithString:url] withCompletionHandler:^(NSData *data) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(!json){
            NSLog(@"NSJSONSerialization error %@",error);
        }else{
            if (json[@"error_message"]) {
                NSLog(@"error %@", json[@"error_message"]);
            }else {
                NSMutableArray *newItems = [NSMutableArray new];
                for (NSDictionary *dict in json[@"results"]) {
                    [newItems addObject:[SLVATMModel atmWithDictionary:dict]];
                }
                self.atmsArray = [self.atmsArray arrayByAddingObjectsFromArray:newItems];
                NSLog(@"sel.atmsarray.count%lu",(unsigned long)self.atmsArray.count);
                if ([json objectForKey:@"next_page_token"]){
                    self.nextPageToken = json[@"next_page_token"];
                }else{
                    self.nextPageToken = @"ended";
                }
                completionHandler(self.atmsArray);
            }
        }
    }];
}




@end
