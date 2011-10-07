//
//  JobAnnotation.h
//  jobFinder
//
//  Created by mario greco on 04/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Job.h"
#import <MapKit/MapKit.h>


@interface JobAnnotation : NSObject <MKAnnotation>{
    //Job *job;
    CLLocationCoordinate2D coordinate; //struct
    BOOL isMultiple;
    BOOL isAnimated;
}

//@property(nonatomic,retain) Job *job;
//propery coordinate dichiarata nel protocollo
@property(nonatomic, assign) BOOL isMultiple;
@property(nonatomic, assign) BOOL isAnimated;
-(id) initWithCoordinate:(CLLocationCoordinate2D)coord;

@end
