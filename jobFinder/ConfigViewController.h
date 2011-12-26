//ConfigViewController.h
//  jobFinder
//
//  Created by mario greco on 29/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldCell.h"
#import "SearchZoneViewController.h"
#import "DatabaseAccess.h"
#import "CreditsViewController.h"

/* Mostra la view relativa alle configurazioni utente
 */

@protocol ConfigViewControllerDelegate;

@interface ConfigViewController : UITableViewController <UITableViewDataSource, SearchZoneDelegate, DatabaseAccessDelegate >{
    
    NSArray *sectionDescripition;
    NSArray *sectionData;
    SearchZoneViewController *searchZone;
    id<ConfigViewControllerDelegate> delegate;
    CreditsViewController *creditsViewController;
    
}
@property(nonatomic,assign) id<ConfigViewControllerDelegate> delegate;
@end

@protocol ConfigViewControllerDelegate <NSObject>

-(void)didSelectedFavouriteZone:(CLLocationCoordinate2D) coordinate;

@end
