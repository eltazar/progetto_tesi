//
//  Job.h
//  jobFinder
//
//  Created by mario greco on 17/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"

@interface Job : NSObject{
    
    NSString *employee;
    NSString *date;
    NSString *description;
    NSString *phone;
    NSString *email;
    NSString *url;
    
    
    NSString *street;
    NSString *city;
//    CLLocationDegrees latitude;
//    CLLocationDegrees longitude;
    
    CLLocationCoordinate2D coordinate;
}

//valutare se le property servono, o se fare un metodo che ritorna oggetto job da un array o altro
@property(nonatomic, retain) NSString *employee;
@property(nonatomic, retain) NSString *date;
@property(nonatomic, retain) NSString *street;
@property(nonatomic, retain) NSString *city;
@property(nonatomic, retain) NSString *phone;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *description;
@property(nonatomic, retain) NSString *url;
@property(nonatomic) CLLocationDegrees latitude;
@property(nonatomic) CLLocationDegrees longitude;
@property(nonatomic) CLLocationCoordinate2D coordinate;



@end
