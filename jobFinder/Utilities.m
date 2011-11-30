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

+(NSString*) createFieldsString
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *stringFields = @"";
    
    if([prefs boolForKey:@"switch"]){
         NSArray *arrayFields = [[NSArray alloc] initWithArray:[prefs objectForKey:@"selectedCells"]];
        if(arrayFields.count != 0){
            for(int i=0; i < arrayFields.count-1; i++){
                NSLog(@"FIELD = %@",[arrayFields objectAtIndex:i]);
               stringFields = [stringFields stringByAppendingFormat:@"%@ ", [arrayFields objectAtIndex:i]];
            }    
            stringFields = [stringFields stringByAppendingFormat:@"%@", [arrayFields objectAtIndex:(arrayFields.count-1)]];
        }
        [arrayFields release];
    }
    else{ 
        stringFields = [stringFields stringByAppendingFormat:@"%@", @"ALL"];
    }

    //NSLog(@"STRING FIELD = %@", stringFields);
    
    return stringFields;
}


+(NSString*)sectorFromCode:(NSString*)code
{
    NSString *plisStructure = [[NSBundle mainBundle] pathForResource:@"sectors" ofType:@"plist"];
    //array di dizionari
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plisStructure];
    
    NSString *sector = [NSString stringWithFormat:@"%@",[dict objectForKey:code]];
    
    [dict release];
    
    if(sector != nil)
        return sector;
    else return @"job no code";
}

+(NSString *) createLocalizedStringDate:(NSDate*)date
{
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init]; 
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyyMMMd" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    
    NSString *stringDate = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
    
    [formatter release];
    
    return  stringDate;
}

@end
