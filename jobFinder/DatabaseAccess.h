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
    NSMutableArray *readConnections;
    NSMutableArray *writeConnections;
}

@property(nonatomic,assign) id<DatabaseAccessDelegate> delegate;

-(void)jobWriteRequest:(Job*)job;
-(void)jobReadRequest:(MKCoordinateRegion)region field:(NSInteger)field;
-(void)jobReadRequestOldRegion:(MKCoordinateRegion)oldRegion newRegion:(MKCoordinateRegion)oldRegion field:(NSInteger)field;
-(void)registerDevice:(NSString*)token;

@end


@protocol DatabaseAccessDelegate <NSObject>
@optional
-(void)didReceiveResponsFromServer:(NSString*) receivedData;
@optional
-(void)didReceiveJobList:(NSArray*)jobList;
@end