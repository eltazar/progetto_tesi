//
//  jobFinderAppDelegate.h
//  jobFinder
//
//  Created by mario greco on 15/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseAccess.h"
#import "FBConnect.h"

@class Reachability;
@class MapViewController;
@interface jobFinderAppDelegate : NSObject <UIApplicationDelegate, DatabaseAccessDelegate, FBSessionDelegate>{
    UINavigationController *navController; 
    BOOL tokenSended;
    Reachability *reachability;
    Facebook *fb;
}
@property(nonatomic, retain) Facebook *fb;
@property(nonatomic, retain) IBOutlet MapViewController *mapController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;

@end
