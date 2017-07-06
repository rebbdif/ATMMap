//
//  SLVNetworkService.m
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import "SLVNetworkService.h"

@interface SLVNetworkService()

@property (strong, nonatomic, readonly) NSURLSession *session;

@end

@implementation SLVNetworkService

- (instancetype)init {
    self = [super init];
    if (self) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

- (void)downloadDataFromUrl:(NSURL *)url withCompletionHandler:(void (^)(NSData *data))completionHandler{
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error){
            NSLog(@"network error %@",error.userInfo);
        }
        completionHandler(data);
    }];
    [task resume];
}


@end
