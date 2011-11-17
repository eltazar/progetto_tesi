//
//  jobFinderAppDelegate.m
//  jobFinder
//
//  Created by mario greco on 15/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "jobFinderAppDelegate.h"
#import "Reachability.h"
#import "CoreLocation/CoreLocation.h"

void myExceptionHandler (NSException *ex)
{
    NSLog(@"Eccezione");
    NSLog(@"*** %@ \n*** %@ \n*** %@", ex.name, ex.reason, ex.userInfo);
}
@implementation jobFinderAppDelegate

@synthesize window = _window;
@synthesize navController;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    //NSSetUncaughtExceptionHandler (&myExceptionHandler);
    
    self.window.rootViewController = self.navController;
    
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    
    
    //per controllare quando cambia stato connessione
//    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    //controlla se i servizi di localizzazione sono attivati.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"GPS non attivo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil];
    
    if([CLLocationManager locationServicesEnabled]){
        
        if ([CLLocationManager respondsToSelector:@selector(authorizationStatus)]){
            if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
                NSLog(@"PRIMO");
                [alert show];
            }
        }
    }  
    else{
        NSLog(@"SECONDO");
        [alert show];
    }
        
    [alert release];
    
    
    //controlla presenza rete al primo avvio dell'app
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    
    switch (netStatus)
    {
        case ReachableViaWWAN:
        {
            //NSLog(@"3g");
            break;
        }
        case ReachableViaWiFi:
        {
            //NSLog(@"Wifi");
            break;
        }
        case NotReachable:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Per favore controlla le impostazioni di rete e riprova" message:@"Impossibile collegarsi ad internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
            break;
        }
            
    }

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    //We are unable to make a internet connection at this time. Some functionality will be limited until a connection is made.
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

/*chiamato ogni volta che lo stato della connettività cambia. Da sistemare perchè
 *quando cade la connessione l'alert è mostrato più volte.
 */
////Called by Reachability whenever status changes.
//- (void) reachabilityChanged: (NSNotification* )note
//{
//    Reachability* curReach = [note object];
//    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
//    
//    NetworkStatus netStatus = [curReach currentReachabilityStatus];
//    switch (netStatus)
//    {
//        case ReachableViaWWAN:
//        {
//            break;
//        }
//        case ReachableViaWiFi:
//        {
//            break;
//        }
//        case NotReachable:
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"CHANGED: NO CONNECTION" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [alert show];
//            [alert release];
//            break;
//        }
//    }
//}

- (void)dealloc
{
    [navController release];
    [_window release];
    [super dealloc];
}

@end
