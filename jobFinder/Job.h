//
//  Job.h
//  jobFinder
//
//  Created by mario greco on 17/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "CoreLocation/CoreLocation.h"
#import <MapKit/MapKit.h>

@interface Job : NSObject <MKAnnotation>{
    
    NSString *employee;
    NSString *date;
    NSString *description;
    NSString *phone;
    NSString *email;
    NSURL *url;
       
    NSString *address;
    NSString *city;
    
    BOOL isEmailValid;
    BOOL isURLvalid;
    BOOL isDraggable;
    CLLocationCoordinate2D coordinate;
}
@property(nonatomic, assign) BOOL isDraggable;
@property(nonatomic, retain) NSString *subtitle;
@property(nonatomic, retain) NSString *employee;
@property(nonatomic, retain) NSString *date;
@property(nonatomic, retain) NSString *address;
@property(nonatomic, retain) NSString *city;
@property(nonatomic, retain) NSString *phone;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *description;
@property(nonatomic, retain) NSURL *url;
@property(nonatomic) CLLocationCoordinate2D coordinate;

@property(nonatomic, assign) BOOL isMultiple;
@property(nonatomic, assign) BOOL isAnimated;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coord;
-(void) setEmail:(NSString*)newEmail;
-(void) setUrlWithString:(NSString *) urlString;
-(BOOL) isValid;
-(NSString*) invalidReason;

@end
