//
//  SLVTableModel.h
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@class SLVLocationService;
@class SLVATMModel;

@interface SLVTableModel : NSObject

@property (copy, nonatomic) NSArray *atmsArray;
@property (strong,nonatomic) SLVLocationService *slvLocationService;
@property (strong, nonatomic) SLVATMModel *selectedAtm;

- (void)downloadAtmArrayWithParameters:(NSDictionary *)parameters withCompletionHandler:(void (^)(NSArray *results))completionHandler;
- (void)runWithCompletionHandler:(void(^)(NSArray *results, NSError *_Nullable error))presentingCompletionHandler;
- (void)downloadRouteFromLocation:(CLLocationCoordinate2D) start toLocation:(CLLocationCoordinate2D) finish withPresentingCompletionHandler: (void (^)(NSDictionary* json))presentinCompletionHandler;

@end
