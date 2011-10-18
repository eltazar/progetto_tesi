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
    NSArray *list;
    NSString *selectedCell;
    NSMutableArray *selectedCells;
    NSIndexPath *indexPathSelected;
    BOOL firsTime;
    id<SectorTableDelegate> secDelegate;
}

@property(nonatomic,readonly) NSString *selectedCell;
@property(nonatomic,assign) id<SectorTableDelegate> secDelegate;
@end

@protocol SectorTableDelegate <NSObject>

-(void)receiveSectorFromTable:(NSString*)jobSector;
@end