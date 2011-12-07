//
//  jobFinderAppDelegate.m
//  jobFinder
//
//  Created by mario greco on 15/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "jobFinderAppDelegate.h"
#import "CoreLocation/CoreLocation.h"
#import "DatabaseAccess.h"
#import "Utilities.h"
#import "Reachability.h"
#import "MapViewController.h"
#import "InfoJobViewController.h"
#import "FBConnect.h"

@implementation jobFinderAppDelegate

@synthesize window = _window;
@synthesize navController, mapController, fb;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{            
    self.window.rootViewController = self.navController;
    
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    
    tokenSended = NO;
    
    //############# controlla se i servizi di localizzazione sono attivi #################
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"GPS non attivo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil];
    
    if([CLLocationManager locationServicesEnabled]){
        
        if ([CLLocationManager respondsToSelector:@selector(authorizationStatus)]){
            if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
                NSLog(@"PRIMO");
                //[alert show];
            }
        }
    }  
    else{
        NSLog(@"SECONDO");
        //[alert show];
    }
        
    [alert release];
    
    
    //################ controlla presenza rete al primo avvio dell'app ###################
    
    if(![Utilities networkReachable]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Per favore controlla le impostazioni di rete e riprova" message:@"Impossibile collegarsi ad internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    
    //per controllare quando cambia stato connessione
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    reachability = [[Reachability reachabilityForInternetConnection] retain];         
    [reachability startNotifier];       
    
    
    
    //###############   registrazione device a notifiche push #######################
    #if !TARGET_IPHONE_SIMULATOR
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    #endif
    
    // Clear application badge when app launches
    application.applicationIconBadgeNumber = 0;
    
    
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
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{   
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    //We are unable to make a internet connection at this time. Some functionality will be limited until a connection is made.
    
    //controlla tra le impostazioni dell'iphone se l'app ha le notifiche attive
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types == UIRemoteNotificationTypeNone) 
        NSLog(@"push disabilitate");
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - Metodi per gestire le push notification

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken{
    
    //TODO: prima di inviare i dati sul server controllare la presenza della zona preferita
    
    NSString* newToken = [devToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"################");
    NSLog(@"DID REGISTER: \nIl token è %@, ed è lungo %d", newToken, [newToken length]);

    //se c'è connessione internet
    if([Utilities networkReachable]){
            
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];    
        NSLog(@"pefs lat = %f, long = %f", [[pref objectForKey:@"lat"] doubleValue],[[pref objectForKey:@"long"] doubleValue]);
        
        //se coordinate sono settate e token è valido
        if([pref objectForKey: @"lat"] != nil &&
           [pref objectForKey: @"long"] != nil &&
           ![newToken isEqualToString:@""]){
            
            NSLog(@" APP DELEGATE : preferito settato");
            DatabaseAccess *dbAccess = [[DatabaseAccess alloc] init];
            [dbAccess setDelegate:self];
            [dbAccess registerDevice:newToken];
            [dbAccess release];
        }
        else{
            
            NSLog(@" APP DELEGATE : nessun preferito");
            tokenSended = NO;
        }
    }
    else{
        NSLog(@"INTERNET NN DISPONIBILE : TOKEN NN INVIATO");
        tokenSended = NO;
    }
        
    NSLog(@"################");
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)err{
    
    NSLog(@"%@, %@, %@", [err localizedDescription], [err localizedFailureReason], [err localizedRecoverySuggestion]);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@" DID RECEIVE");
    //apre la mappa nella posizione preferita
    [self.mapController refreshViewMap];
    //mostrare alert quando l'applicazione è in foreground
}


//si accorge se cambia stato connessione, e se il token non è stato ancora inviato lo invia sul db
- (void) reachabilityChanged:(NSNotification *)notice
{  
    NSLog(@"################");
    NSLog(@"HANDLE NETWORK CHANGE");
    
    NetworkStatus remoteStatus = [reachability currentReachabilityStatus];  
    
    //se internet è raggiungibile e il token non è stato ancora inviato
    if(remoteStatus != NotReachable && !tokenSended){
        NSLog(@"DENTRO IF");
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
       
        if([pref objectForKey: @"lat"] != nil &&
           [pref objectForKey: @"long"] != nil){
            
            NSLog(@" APP DELEGATE : preferito settato");
        #if !TARGET_IPHONE_SIMULATOR
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
        #endif
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [reachability stopNotifier];
        }
        else{
            NSLog(@" APP DELEGATE : nessun preferito");        
            tokenSended = NO;
        }
    }

    NSLog(@"################");
} 

#pragma mark - DatabaseAccessDelegate

- (void) didReceiveResponsFromServer:(NSString *)receivedData {
    NSLog(@"%s", [receivedData UTF8String]);
    
    //se scrittura su db è andata a buon fine
    if([receivedData isEqualToString:@"OK"]){
        tokenSended = YES;
        NSLog(@"token inviato");
    }
    else{
        tokenSended = NO;
        NSLog(@"TOKEN NN INVIATO");
    }
}

#pragma mark - FacebookDelegate

// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"DENTRO APP DELEGATE2");

    return [fb handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@"DENTRO APP DELEGATE, facebook = %p",fb);
    return [fb handleOpenURL:url]; 
}




#pragma mark - memory management

- (void)dealloc
{   
    [reachability release];
    [navController release];
    [_window release];
    [super dealloc];
}

@end
