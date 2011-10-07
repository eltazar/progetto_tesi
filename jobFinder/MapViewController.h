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
#import "InfoJobViewController.h"
#import "JobAnnotation.h"

@interface MapViewController : UIViewController <PublishViewControllerDelegate,  MKMapViewDelegate>{
    
    MKMapView *map;
    UIToolbar *toolBar;  
    UIBarButtonItem *publishBtn; // bottone "segnala"
    UIBarButtonItem *refreshBtn; //bottone "refresh"
    UIBarButtonItem *infoBarButtonItem;
    
    Job *jobToPublish;
    CLLocationDegrees lastSpan;
    NSMutableArray *arrayJOBtemp;
    
    
    //PublishViewController *publishViewCtrl;
    ConfigViewController *infoView;
    InfoJobViewController *detailJobView;
    
}

@property(nonatomic, retain) IBOutlet MKMapView *map;
@property(nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *publishBtn;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *refreshBtn;
@property(nonatomic, retain) IBOutlet UIButton *infoBtn;
//@property(nonatomic, retain) PublishViewController *publishViewCtrl;
@property(nonatomic, retain) ConfigViewController *infoView;
@property(nonatomic, retain) RootJobViewController *detailJobView;

-(IBAction)publishBtnClicked:(id)sender;
-(void)infoButtonClicked:(id)sender;
-(IBAction) updateButtonClicked:(id)sender;
-(void)filterAnnotation:(NSArray *) annotations;

@end
