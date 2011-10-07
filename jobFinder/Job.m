//
//  Job.m
//  jobFinder
//
//  Created by mario greco on 17/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Job.h"

@implementation Job

@synthesize employee, street, city, description, phone, url, email, coordinate, latitude, longitude;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        //prova
//        self->coordinate.longitude = -122.084095;
//        self->coordinate.latitude = 37.422006;
//        self.employee = @"Meccanico";
//        self.street = @"via roma 2";
        
    }
    
    return self;
}


-(void) dealloc
{
    [super dealloc];
    [description release];
    [email release];
    [employee release];
    [street release];
    [phone release];
    [url release];
    
}
@end
