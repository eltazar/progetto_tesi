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
    NSInteger idDb;
    NSString *field; //cambiare nome in field
    NSDate *date;
    NSString *description;
    NSString *phone;
    NSString *email;
    NSURL *url;
    NSString *code;   
    NSString *time;
    
    NSString *address;
//    NSString *city;
    
    BOOL isEmailValid;
    BOOL isURLvalid;
    BOOL isDraggable;
    CLLocationCoordinate2D coordinate;
}

@property(nonatomic,retain) NSString *time;
@property(nonatomic, retain) NSString *code;
@property(nonatomic, assign) NSInteger idDb;
@property(nonatomic, assign) BOOL isDraggable;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property(nonatomic, retain) NSString *field;
@property(nonatomic, retain) NSDate *date;
@property(nonatomic, retain) NSString *address;
//@property(nonatomic, retain) NSString *city;
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
-(void) _setPhone:(NSString*) _phone;
-(BOOL) isValid;
-(NSString*) invalidReason;
-(NSString*)urlAsString;
-(NSString*)stringFromDate;
+(NSInteger)jobBinarySearch:(NSArray*)array withID:(NSInteger) x;
+(void)orderJobsByID:(NSMutableArray*)jobs;
+(void)mergeArray:(NSArray*)totalArray withArray:(NSArray*)jobs;

@end
