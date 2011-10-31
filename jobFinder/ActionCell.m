//
//  ActionCell.m
//  jobFinder
//
//  Created by mario greco on 02/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActionCell.h"

@implementation ActionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDictionary:(NSDictionary *)dictionary 
{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withDictionary:dictionary]) {
		// Custom initialization
        [self setSelectionStyle:UITableViewCellSelectionStyleBlue]; 
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self.textLabel setAdjustsFontSizeToFitWidth:YES];
        self.textLabel.minimumFontSize = 11;
        UIImage *image = [UIImage imageNamed: [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"img"]]];
        self.imageView.image = image;
        //NSLog(@"IMAGE SIZE action %f, %f",image.size.width,image.size.height);
        
    }
    return self;
}

//- (void)layoutSubviews {
//	[super layoutSubviews];
//    
//	CGRect labelRect = CGRectMake(self.textLabel.frame.origin.x,
//                                  self.textLabel.frame.origin.y,
//                                  self.contentView.frame.size.width * .35,
//                                  self.textLabel.frame.size.height);
//	[self.textLabel setFrame:labelRect];
//}


@end
