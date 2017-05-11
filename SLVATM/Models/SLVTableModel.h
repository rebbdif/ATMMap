//
//  SLVTableModel.h
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLVTableModel : NSObject

@property (copy, nonatomic) NSArray *atmsArray;

- (void) downloadAtmArrayWithParameters: (NSDictionary *)parameters withCompletionHandler:(void (^)(NSArray *results))completionHandler;

@end
