//
//  FavouriteAnnotation.m
//  jobFinder
//
//  Created by mario greco on 24/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FavouriteAnnotation.h"

@implementation FavouriteAnnotation
@synthesize address;
@synthesize coordinate = _coordinate;
@synthesize title,subtitle;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id) initWithCoordinate:(CLLocationCoordinate2D) coordinate{
    self=[super init];
    if(self){
        _coordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    return @"Zona preferita";
}

-(NSString *) subtitle{
    return address;
}

-(void) dealloc{
    self.address = nil;
    [title release];
    [subtitle release];
    [super dealloc];
}


@end
