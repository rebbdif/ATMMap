//
//  SLVNetworkService.h
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLVNetworkService : NSObject

- (void)downloadDataFromUrl: (NSURL *)url withCompletionHandler: (void (^)(NSData *data))completionHandler;

@end
