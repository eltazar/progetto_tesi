//
//  SectorTableViewController.h
//  jobFinder
//
//  Created by mario greco on 12/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/* Mostra tabella contenenti i settori di lavoro
 */

@protocol SectorTableDelegate;

@interface SectorTableViewController : UITableViewController{
   
    id<SectorTableDelegate> secDelegate;
    NSArray *structureFromPlist;
    NSDictionary *tableStructure;
    NSMutableArray *sections;
    NSString *plistName;
    NSArray *indices;

}
@property(nonatomic, retain) NSArray *indices;
@property(nonatomic, retain) NSArray *structureFromPlist;
@property(nonatomic, retain) NSDictionary *tableStructure;
@property(nonatomic, retain) NSMutableArray *sections;
@property(nonatomic,assign) id<SectorTableDelegate> secDelegate;

-(id) initWithPlist:(NSString *)plist;

@end

@protocol SectorTableDelegate <NSObject>

-(void)didReceiveSectorFromTable:(NSString*)jobSector andCode:(NSString*)code;
@end