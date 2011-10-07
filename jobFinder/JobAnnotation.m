//
//  JobAnnotation.m
//  jobFinder
//
//  Created by mario greco on 04/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JobAnnotation.h"

@implementation JobAnnotation
@synthesize /*job,*/ coordinate, isMultiple, isAnimated;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        isMultiple = FALSE;
        isAnimated = TRUE;
    }
    
    return self;
}

-(id) initWithCoordinate:(CLLocationCoordinate2D)coord
{
    self = [super init];
    if (self) {
        // Initialization code here.
        //self.job = [[[Job alloc] init] autorelease];
        coordinate = coord; // ????????? MEMORIA??? usare setCoordinate?
    }
    return self;
}

- (NSString *)title {
//    return self.job.employee;
    return @"Titolo";
}

- (NSString *)subtitle {
//    return self.job.street;
    return @"Sottotitolo";
}


-(void) dealloc
{
    [super dealloc];
   // [job release];
}
//- (CLLocationCoordinate2D)coordinate {
//	CLLocationCoordinate2D theCoordinate;
//	theCoordinate.latitude = shop.latitude;
//	theCoordinate.longitude = shop.longitude;
//	return theCoordinate; 
//}

@end
