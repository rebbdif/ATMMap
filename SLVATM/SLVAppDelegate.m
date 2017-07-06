//
//  AppDelegate.m
//  SLVATM
//
//  Created by 1 on 08.05.17.
//  Copyright © 2017 serebryanyy. All rights reserved.
//

#import "SLVAppDelegate.h"
#import "SLVMapViewController.h"
#import "SVLTableViewController.h"
#import "SLVTableModel.h"

@import GoogleMaps;

@interface SLVAppDelegate ()

@end

@implementation SLVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GMSServices provideAPIKey:@"AIzaSyCazMVbBSXWGczcdsVJfQTuEwJlOAIg4V0"];
    SLVTableModel *model = [SLVTableModel new];
    SLVMapViewController *mapViewController = [SLVMapViewController new];
    mapViewController.model = model;
    mapViewController.title = @"map";
    SVLTableViewController *tableViewController = [SVLTableViewController new];
    tableViewController.model = model;
    tableViewController.title = @"table";
    UITabBarController *tabBarController = [UITabBarController new];
    tabBarController.viewControllers = @[tableViewController, mapViewController];
    [tabBarController.tabBar.items[0] setImage:[[UIImage imageNamed:@"tableTabbarImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarController.tabBar.items[1] setImage:[[UIImage imageNamed:@"mapTabbarImage"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    tabBarController.selectedIndex = 0;
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
