//
//  SearchZoneViewController.h
//  jobFinder
//
//  Created by mario greco on 19/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchZoneViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource>{
    
    NSMutableArray *tableData;

    UITableView *theTableView;
    UISearchBar *theSearchBar;
    
    UIView *disableViewOverlay;

    
}
@property(retain) NSMutableArray *tableData;
@property(retain) UIView *disableViewOverlay;

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active;

@end
