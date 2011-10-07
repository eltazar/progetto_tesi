//
//  ActionCell.h
//  jobFinder
//
//  Created by mario greco on 02/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionCell : UITableViewCell{
    
    NSString *url;
    NSString *email;
    NSString *phone;
    
    NSString *dataKey;
}

@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *phone;
@property(nonatomic, retain) NSString *dataKey;
@end
