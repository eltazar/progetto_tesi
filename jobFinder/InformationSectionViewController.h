//
//  InformationSectionViewController.h
//  jobFinder
//
//  Created by mario greco on 31/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigViewController.h"


@protocol InformationSectionViewControllerDelegate;


@interface InformationSectionViewController : UITableViewController<ConfigViewControllerDelegate>{
    
    
    NSArray *sectionDescripition;
    NSArray *sectionData;

}

@property(nonatomic, assign) id<InformationSectionViewControllerDelegate> delegate;

@end

@protocol InformationSectionViewControllerDelegate <NSObject>

-(void)didSelectedFavouriteZone:(CLLocationCoordinate2D) coordinate;

@end