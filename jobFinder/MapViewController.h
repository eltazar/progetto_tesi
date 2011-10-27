//
//  MapViewController.h
//  jobFinder
//
//  Created by mario greco on 15/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "PublishViewController.h"
#import "ConfigViewController.h"
#import "Job.h"
#import "FavouriteAnnotation.h"
#import "DatabaseAccess.h"

@interface MapViewController : UIViewController <PublishViewControllerDelegate,  MKMapViewDelegate, ConfigViewControllerDelegate, UIActionSheetDelegate>{
    
    MKMapView *map;
    UIToolbar *toolBar;  
    UIBarButtonItem *publishBtn; // bottone "segnala"
    UIBarButtonItem *refreshBtn; //bottone "refresh"
    UIBarButtonItem *infoBarButtonItem;
    UIBarButtonItem *filterButton;
    UIBarButtonItem *bookmarkButtonItem;
    Job *jobToPublish;
    Job *jobDiprova;
    UIView *alternativeToolbar;
    UIButton *publishAlternativeBtn;
    UIButton *back;
    
    CLLocationDegrees lastSpan;
    NSMutableArray *arrayJOBtemp; 
    MKAnnotationView *favouriteAnnView;
    FavouriteAnnotation *favouriteAnnotation;
    
    UILongPressGestureRecognizer *longPressGesture;
    
    BOOL isDragPinOnMap;
    BOOL isLongTapEnabled;
    
    //PublishViewController *publishViewCtrl;
//    ConfigViewController *configView;
    //InfoJobViewController *infoJobView;
    
    DatabaseAccess *dbAccess;
    
}
@property(nonatomic, retain) IBOutlet UIButton *back;
@property(nonatomic, retain) IBOutlet UIButton *publishAlternativeBtn;
@property(nonatomic, retain) IBOutlet UIView *alternativeToolbar;
@property(nonatomic, retain) IBOutlet MKMapView *map;
@property(nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic, retain)  IBOutlet UIBarButtonItem *filterButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *publishBtn;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *refreshBtn;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *bookmarkButtonItem;
//@property(nonatomic, retain) PublishViewController *publishViewCtrl;
//@property(nonatomic, retain) ConfigViewController *configView;
//@property(nonatomic, retain) RootJobViewController *infoJobView;

-(IBAction)showKindOfPublishingJob:(id)sender;
-(IBAction)publishAlternativeBtnClicked:(id)sender;
-(IBAction)bookmarkBtnClicked:(id)sender;
-(IBAction)infoButtonClicked:(id)sender;
-(IBAction) showUserLocationButtonClicked:(id)sender;
-(IBAction)backBtnClicked:(id)sender;
-(void)filterAnnotation:(NSArray *) annotations;
-(double) fRand;
-(IBAction)filterBtnClicked:(id)sender;
@end

