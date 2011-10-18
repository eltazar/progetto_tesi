//
//  ActionCell.m
//  jobFinder
//
//  Created by mario greco on 02/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActionCell.h"

@implementation ActionCell
@synthesize email, phone, url,dataKey;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
		// Custom initialization
        [self setSelectionStyle:UITableViewCellSelectionStyleBlue]; 
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
    
	CGRect labelRect = CGRectMake(self.textLabel.frame.origin.x,
                                  self.textLabel.frame.origin.y,
                                  self.contentView.frame.size.width * .35,
                                  self.textLabel.frame.size.height);
	[self.textLabel setFrame:labelRect];
}


@end
