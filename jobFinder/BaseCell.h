//
//  BaseCell.h
//  jobFinder
//
//  Created by mario greco on 18/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseCell : UITableViewCell{

    NSString *dataKey;
}

-(void) setDelegate:(id)delegate;

@property(nonatomic, retain) NSString *dataKey;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDictionary:(NSDictionary *)dictionary;
-(void) setImg:(id)image;
//-(void) setPlaceHolder:(NSString *)placeholder;
//-(void) setKeyboardType:(UIKeyboardType) keyboardType;

@end