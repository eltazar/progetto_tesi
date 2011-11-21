//
//  TextAreaCell.m
//  jobFinder
//
//  Created by mario greco on 01/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextAreaCell.h"

@implementation TextAreaCell
@synthesize textView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDictionary:(NSDictionary *)dictionary {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withDictionary:dictionary]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textView = [[[UITextView alloc] initWithFrame:CGRectZero]autorelease];
        self.textView.font = [UIFont systemFontOfSize:17];
        self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
        self.textView.text = [dictionary objectForKey:@"placeholder"];
        self.textView.keyboardType = [[dictionary objectForKey:@"keyboardType"] integerValue];
        self.textView.tag = 1111;
        //self.textView.delegate = self;
        CGRect frame = self.frame;
        frame.size.height *=2;
        [self setFrame:frame];
        [self addSubview:self.textView];
        //CGRect frame = CGRectMake(0, 0, self.window.frame.size.width, 44.0);
        
    }
    return self;
}

// per far scomparire la tastiera con il tasto return, se questa classe implementasse il textViewDelegate

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    
//    if([text isEqualToString:@"\n"]) {
//        [self.textView resignFirstResponder];
//        return NO;
//    }
//    
//    return YES;
//}

//-(void) textFieldFinished: (id) sender
//{   //intenzionalmente vuoto
//    //    [sender resignFirstResponder];
//}


//- (void)endTextViewEditing
//{
//    [self.textView resignFirstResponder];
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [textView resignFirstResponder];

    [super touchesBegan:touches withEvent:event];
}

-(void) setDelegate:(id<UITextViewDelegate>)delegate
{
    self.textView.delegate = delegate; 
}


#define LEFT_MARGIN 15
#define TOP_MARGIN 5
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width - (LEFT_MARGIN *2);
    CGFloat height = self.frame.size.height - (TOP_MARGIN *2);
    self.textView.frame = CGRectMake(LEFT_MARGIN, TOP_MARGIN, width, height);     
    
//    NSLog(@"SIZE CELL %f",self.frame.size.height);
    
//    [self addSubview:self.textView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
   // [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) dealloc{
    [textView release];
    [super dealloc];
}

@end
