//
//  jobFinderAppDelegate.h
//  jobFinder
//
//  Created by mario greco on 15/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reachability;

@interface jobFinderAppDelegate : NSObject <UIApplicationDelegate>{
    UINavigationController *navController; 
    Reachability *internetReach;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;

@end
