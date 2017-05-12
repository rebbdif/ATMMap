//
//  SLVTableModel.h
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SLVLocationService;

@interface SLVTableModel : NSObject

@property (copy, nonatomic) NSArray *atmsArray;
@property (strong,nonatomic) SLVLocationService *slvLocationService;

- (void) downloadAtmArrayWithParameters: (NSDictionary *)parameters withCompletionHandler:(void (^)(NSArray *results))completionHandler;
- (void)runWithCompletionHandler:(void(^)(NSArray *results, NSError *_Nullable error))presentingCompletionHandler;

@end
