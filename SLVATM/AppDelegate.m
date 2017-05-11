//
//  AppDelegate.m
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import "AppDelegate.h"
#import "SLVMapViewController.h"
#import "SVLTableViewController.h"
#import "SLVTableModel.h"

@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GMSServices provideAPIKey:@"AIzaSyCazMVbBSXWGczcdsVJfQTuEwJlOAIg4V0"];
    
    SLVTableModel *model = [SLVTableModel new];
    
    self.window= [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    SLVMapViewController *mapViewController =[SLVMapViewController new];
    mapViewController.model=model;
    mapViewController.title=@"map";
    SVLTableViewController *tableViewController = [SVLTableViewController new];
    
    tableViewController.title=@"table";
    tableViewController.model=model;
    UITabBarController *tabBarController = [UITabBarController new];
    tabBarController.viewControllers=@[tableViewController, mapViewController];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
