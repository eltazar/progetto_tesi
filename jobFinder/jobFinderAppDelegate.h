//
//  jobFinderAppDelegate.h
//  jobFinder
//
//  Created by mario greco on 15/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseAccess.h"
@class Reachability;
@class MapViewController;
@interface jobFinderAppDelegate : NSObject <UIApplicationDelegate, DatabaseAccessDelegate>{
    UINavigationController *navController; 
    DatabaseAccess *dbAccess;
    NSString *tokenDevice;
    BOOL tokenSended;
    Reachability *reachability;

}

@property(nonatomic, retain) IBOutlet MapViewController *mapController;
@property(nonatomic, retain)NSString *tokenDevice;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;

@end
