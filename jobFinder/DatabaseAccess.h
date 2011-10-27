//
//  DatabaseAccess.h
//  jobFinder
//
//  Created by mario greco on 25/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Job;
@interface DatabaseAccess : NSObject{
    NSMutableData *receivedData;
}



-(void)jobWriteRequest:(Job*)job;
-(NSArray *)jobReadRequest:(MKCoordinateRegion)region;


@end
