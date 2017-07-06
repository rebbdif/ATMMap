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

@interface SLVTableModel()

@property (strong, nonatomic, readonly) SLVNetworkService *networkService;
@property (copy, nonatomic) NSString *nextPageToken;

@end

static const char apiKeyChar[] = "AIzaSyCazMVbBSXWGczcdsVJfQTuEwJlOAIg4V0";

@implementation SLVTableModel

- (instancetype) init {
    self = [super init];
    if (self) {
        _atmsArray = [NSArray new];
        _networkService = [SLVNetworkService new];
        _slvLocationService = [SLVLocationService new];
        _nextPageToken = @"";
    }
    return self;
}

- (void)runWithCompletionHandler:(void(^)(NSArray *results, NSError *error))presentingCompletionHandler {
    if(0 == self.atmsArray.count) {
        __weak typeof(self) weakself = self;
        [self.slvLocationService getLocationWithCompletionHandler:^(NSDictionary *parameters, NSError *error) {
            if (parameters) {
                [weakself downloadAtmArrayWithParameters:parameters withCompletionHandler:^(NSArray *results) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        presentingCompletionHandler(results, nil);
                    });
                }];
            } else {
                presentingCompletionHandler(nil, error);
            }
        }];
    } else {
        presentingCompletionHandler(self.atmsArray, nil);
    }
}

- (void)downloadAtmArrayWithParameters:(NSDictionary *)parameters withCompletionHandler:(void (^)(NSArray *results))completionHandler {
    if ([parameters[@"resetPreviousResults"] isEqual:@YES]){
        self.atmsArray = [NSArray new];
        self.nextPageToken = @"";
        NSLog(@"new location so i reset results");
    }
    CLLocation *location = parameters[@"location"];
    if (!location) {
        location=self.slvLocationService.location;
    }
    NSString *openNow = parameters [@"opennow"];
    NSString *pagetoken = [NSString stringWithFormat:@"pagetoken=%@", self.nextPageToken];
    if([self.nextPageToken isEqualToString:@"ended"]){
        return;
    }
    NSString *apiKey = [NSString stringWithCString:apiKeyChar encoding:1];
    NSString* url= [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&type=bank&rankby=distance&language=RU&%@%@&key=%@", location.coordinate.latitude, location.coordinate.longitude, openNow, pagetoken, apiKey];
    
    [self.networkService downloadDataFromUrl:[NSURL URLWithString:url] withCompletionHandler:^(NSData *data) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (!json) {
            NSLog(@"NSJSONSerialization error %@",error);
        } else {
            if (json[@"error_message"]) {
                NSLog(@"error %@", json[@"error_message"]);
            } else {
                NSMutableArray *newItems = [NSMutableArray new];
                for (NSDictionary *dict in json[@"results"]) {
                    SLVATMModel *newAtm =[SLVATMModel atmWithDictionary:dict];
                    [newItems addObject: newAtm];
                    __weak typeof(self) weakself = self;
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
                        [weakself downloadRouteFromLocation:weakself.slvLocationService.location.coordinate toLocation:CLLocationCoordinate2DMake([newAtm.latitude doubleValue], [newAtm.longitude doubleValue]) withPresentingCompletionHandler:^(NSDictionary *json) {
                            newAtm.distance = json[@"results"][@"distance"];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                ///ui stuff
                            });
                        }];
                    });
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
- (void)downloadRouteFromLocation:(CLLocationCoordinate2D)start toLocation:(CLLocationCoordinate2D)finish withPresentingCompletionHandler:(void (^)(NSDictionary* json)) presentinCompletionHandler  {
    NSString *origin = [NSString stringWithFormat:@"origin=%f,%f", start.latitude, start.longitude];
    NSString *destination = [NSString stringWithFormat:@"destination=%f,%f", finish.latitude, finish.longitude];
    NSString *mode = @"mode=walking";
    NSString *key = @"AIzaSyCazMVbBSXWGczcdsVJfQTuEwJlOAIg4V0";
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?%@&%@&%@&key=&%@", origin, destination, mode, key];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"network error when getting route %@",error.userInfo);
        } else {
            NSError *jsonError=nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (!json) {
                NSLog(@"serialization Error");
            } else {
                if (json[@"routes"]) {
                    presentinCompletionHandler(json);
                }
            }
        }
    }];
    [task resume];
}



@end
