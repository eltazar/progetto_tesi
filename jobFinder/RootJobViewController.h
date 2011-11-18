//
//  RootJobViewController.h
//  jobFinder
//
//  Created by mario greco on 03/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"

/*Classe madre per le tabelle di creazione e visualizzazione di un job
 */

@interface RootJobViewController : UITableViewController <UITableViewDataSource/*,UITextFieldDelegate*/>{
    @protected
    NSArray *sectionDescripition;
    NSArray *sectionData;
    Job *job;
}

@property(nonatomic, retain) Job *job;


@end
