//ConfigViewController.h
//  jobFinder
//
//  Created by mario greco on 29/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldCell.h"
#import <MessageUI/MessageUI.h>
#import "SearchZoneViewController.h"
#import "DatabaseAccess.h"

/* Mostra la view relativa alle configurazioni utente
 */

@protocol ConfigViewControllerDelegate;

@interface ConfigViewController : UITableViewController <UITableViewDataSource,MFMailComposeViewControllerDelegate, SearchZoneDelegate, DatabaseAccessDelegate >{
    
    NSArray *sectionDescripition;
    NSArray *sectionData;
    SearchZoneViewController *searchZone;
    id<ConfigViewControllerDelegate> delegate;
    
}
@property(nonatomic,retain) IBOutlet UIView *sapienzaImage;
@property(nonatomic,assign) id<ConfigViewControllerDelegate> delegate;
@end

@protocol ConfigViewControllerDelegate <NSObject>

-(void)didSelectedFavouriteZone:(CLLocationCoordinate2D) coordinate;

@end
