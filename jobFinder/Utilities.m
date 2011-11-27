//
//  Utilities.m
//  jobFinder
//
//  Created by mario greco on 23/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import "Reachability.h"

@implementation Utilities

+(BOOL)networkReachable {
    Reachability *r = [[Reachability reachabilityForInternetConnection] retain];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    BOOL result = NO;
    
    if(internetStatus == ReachableViaWWAN){
            //NSLog(@"3g");
            result =  YES;

    }
    else if(internetStatus == ReachableViaWiFi){
            //NSLog(@"Wifi");
            result = YES;

   }
   else if(internetStatus == NotReachable){
            result = NO;        
   }
    
    [r release];
    
    return  result;
}

+(NSUserDefaults*)userDefaults{
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    return pref;
}



@end
