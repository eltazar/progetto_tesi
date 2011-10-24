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

@protocol ConfigViewControllerDelegate;

@interface ConfigViewController : UITableViewController <UITableViewDataSource,MFMailComposeViewControllerDelegate, SearchZoneDelegate >{
    
    NSArray *sectionDescripition;
    NSArray *sectionData;
    SearchZoneViewController *searchZone;
    id<ConfigViewControllerDelegate> delegate;
}
@property(nonatomic,assign) id<ConfigViewControllerDelegate> delegate;
@end

@protocol ConfigViewControllerDelegate <NSObject>

-(void)didSelectedFavouriteZone:(CLLocationCoordinate2D) coordinate;

@end
