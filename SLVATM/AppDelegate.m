//
//  AppDelegate.m
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import "AppDelegate.h"
#import "SLVTabBarController.h"
#import "SLVMapViewController.h"
#import "SVLTableViewController.h"
#import "SLVATMModel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window= [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    SLVMapViewController *mapViewController =[SLVMapViewController new];
    mapViewController.title=@"map";
    SVLTableViewController *tableViewController = [SVLTableViewController new];
    tableViewController.title=@"table";
    SLVTabBarController *tabBarController = [SLVTabBarController new];
    tabBarController.viewControllers=@[tableViewController, mapViewController];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
