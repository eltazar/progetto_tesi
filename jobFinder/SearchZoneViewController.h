//
//  SearchZoneViewController.h
//  jobFinder
//
//  Created by mario greco on 19/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeoDecoder.h"
#import "CoreLocation/CLLocation.h"


@protocol SearchZoneDelegate;

/*Mostra la view per la ricerca di un indirizzo preferito
 */
@interface SearchZoneViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, GeoDecoderDelegate>{
    
    NSMutableArray *tableData;

    UITableView *theTableView;
    UISearchBar *theSearchBar;
    
    UIView *disableViewOverlay;
        
    id<SearchZoneDelegate> delegate;
    GeoDecoder *geoDec;

    
}
@property(retain) NSMutableArray *tableData;
@property(retain) UIView *disableViewOverlay;

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;
@property(nonatomic, assign)  id<SearchZoneDelegate> delegate;

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active;

@end

@protocol SearchZoneDelegate <NSObject>

-(void) didSelectedPreferredAddress:(NSString *)address withLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees) longitude;

@end
