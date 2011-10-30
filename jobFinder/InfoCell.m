//
//  InfoCell.m
//  jobFinder
//
//  Created by mario greco on 02/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoCell.h"

@implementation InfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDictionary:(NSDictionary *)dictionary {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withDictionary:dictionary]) {
        // Initialization code
        self.detailTextLabel.text = [dictionary objectForKey:@"detailLabel"];
        self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        self.detailTextLabel.minimumFontSize = 11;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImage *image = [UIImage imageNamed: [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"img"]]];
        self.imageView.image = image; 
        //NSLog(@"IMAGE SIZE info %f, %f",image.size.width,image.size.height);

    }
    return self;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

@end
