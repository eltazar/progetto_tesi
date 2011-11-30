//
//  Utilities.h
//  jobFinder
//
//  Created by mario greco on 23/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+(BOOL)networkReachable;
+(NSUserDefaults*)userDefaults;
+(NSString*)sectorFromCode:(NSString*)code; 
+(NSString*) createFieldsString;
+(NSString *) createLocalizedStringDate:(NSDate*)date;
@end
