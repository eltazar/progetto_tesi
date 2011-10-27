//
//  PublishViewController.h
//  jobFinder
//
//  Created by mario greco on 30/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootJobViewController.h"
#import "EditJobViewController.h"
#import "Job.h"

@protocol PublishViewControllerDelegate;

/* si occupa di presentare la tabella per l'inserimento dei dati di un lavoro
 * e di ritornare un job alla vista che l'ha chiamata.
 */


@interface PublishViewController : UINavigationController{
    //punta al delegato di questa vista
    id<PublishViewControllerDelegate> pwDelegate;
    //la tabella per la raccolta dati dell'utente
    RootJobViewController *tableView;
    Job *newJob;
    //coordinate dell'utente
    CLLocationCoordinate2D jobCoordinate;
    
    @private
    NSString *addressGeocoding;
}

@property(nonatomic, retain) Job *newJob;
@property(nonatomic, assign) id<PublishViewControllerDelegate> pwDelegate;
@property(nonatomic, assign) CLLocationCoordinate2D jobCoordinate;
@property(nonatomic, retain) NSString *addressGeocoding;


- (id) initWithStandardRootViewController;
-(void)insertBtnPressed: (id)sender;
-(void)cancelBtnPressed: (id)sender;

@end

////metodi protocollo
@protocol PublishViewControllerDelegate <NSObject>
//-(void)publishViewControllerDidInsert:(PublishViewController *)viewController aJob:(Job *)job;
-(void)didInsertNewJob:(Job *) newJob;
-(void)didCancelNewJob:(PublishViewController *)viewController;
@end