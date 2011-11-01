//
//  DatabaseAccess.h
//  jobFinder
//
//  Created by mario greco on 25/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NSString* key(NSURLConnection* con);

@protocol DatabaseAccessDelegate;

@class Job;
@interface DatabaseAccess : NSObject{
    //NSMutableData *receivedData;
    id<DatabaseAccessDelegate> delegate;
    //NSMutableDictionary *connectionDictionary;
    NSMutableDictionary *dataDictionary;
}



-(void)jobWriteRequest:(Job*)job;
-(void)jobReadRequest:(MKCoordinateRegion)region;

@property(nonatomic,assign) id<DatabaseAccessDelegate> delegate;

@end


@protocol DatabaseAccessDelegate <NSObject>

-(void)didReceiveResponsFromServer:(NSString*) receivedData;
-(void)didReceiveJobList:(NSArray*)jobList;
@end