//
//  SectorTableViewController.h
//  jobFinder
//
//  Created by mario greco on 12/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SectorTableDelegate;

@interface SectorTableViewController : UITableViewController{
   
    id<SectorTableDelegate> secDelegate;
    NSArray *structureFromPlist;
    NSDictionary *tableStructure;
    NSArray *sections;
    NSString *plistName;

}

@property(nonatomic, retain) NSArray *structureFromPlist;
@property(nonatomic, retain) NSDictionary *tableStructure;
@property(nonatomic, retain) NSArray *sections;
@property(nonatomic,assign) id<SectorTableDelegate> secDelegate;

-(id) initWithPlist:(NSString *)plist;

@end

@protocol SectorTableDelegate <NSObject>

-(void)didReceiveSectorFromTable:(NSString*)jobSector;
@end