//
//  SearchViewController.h
//  jobFinder
//
//  Created by mario greco on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController{
    NSMutableArray *addresses;
}

@property(nonatomic,retain) NSMutableArray *addresses;

@end
