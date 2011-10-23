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

@interface MapViewController : UIViewController <PublishViewControllerDelegate,  MKMapViewDelegate>{
    
    MKMapView *map;
    UIToolbar *toolBar;  
    UIBarButtonItem *publishBtn; // bottone "segnala"
    UIBarButtonItem *refreshBtn; //bottone "refresh"
    UIBarButtonItem *infoBarButtonItem;
    Job *jobToPublish;
    Job *jobDiprova;
    
    CLLocationDegrees lastSpan;
    NSMutableArray *arrayJOBtemp; 
    
    UILongPressGestureRecognizer *longPressGesture;
    //PublishViewController *publishViewCtrl;
//    ConfigViewController *configView;
    //InfoJobViewController *infoJobView;
    
}

@property(nonatomic, retain) IBOutlet MKMapView *map;
@property(nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *publishBtn;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *refreshBtn;
@property(nonatomic, retain) IBOutlet UIButton *infoBtn;
//@property(nonatomic, retain) PublishViewController *publishViewCtrl;
//@property(nonatomic, retain) ConfigViewController *configView;
//@property(nonatomic, retain) RootJobViewController *infoJobView;

-(IBAction)publishBtnClicked:(id)sender coordinate:(CLLocationCoordinate2D)coord;
-(void)infoButtonClicked:(id)sender;
-(IBAction) showUserLocationButtonClicked:(id)sender;
-(void)filterAnnotation:(NSArray *) annotations;

@end
