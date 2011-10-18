//
//  Job.m
//  jobFinder
//
//  Created by mario greco on 17/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Job.h"

@implementation Job

@synthesize employee, date, address, city, description, phone, url, email, coordinate;
@synthesize isAnimated, isMultiple;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        isMultiple = FALSE;
        isAnimated = TRUE;
        isEmailValid = TRUE;
        isURLvalid = TRUE;
    }
    
    return self;
}

-(id) initWithCoordinate:(CLLocationCoordinate2D)coord
{
    self = [super init];
    if (self) {
        // Initialization code here.
        //self.job = [[[Job alloc] init] autorelease];
        coordinate = coord; // ????????? MEMORIA??? usare setCoordinate?
        isMultiple = FALSE;
        isAnimated = TRUE;
        isEmailValid = TRUE;
        isURLvalid = TRUE;
    }
    
    return self;
}

//-(void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
//{
//    
//    [super addObserver:observer forKeyPath:keyPath options:options context:context];
//    
//    
//}

- (NSString *)title {
    return employee;
}

- (NSString *)subtitle {
    return address;
}


-(void) setEmail:(NSString*)newEmail
{
    NSString* emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    if(([newEmail isEqualToString:@""] || newEmail == nil))
        isEmailValid = TRUE;
    else isEmailValid = [emailTest evaluateWithObject:newEmail];
  
    if(isEmailValid){
        [newEmail retain];
        [email release];
        email = newEmail;
    }
}

-(void) setUrlWithString:(NSString *) urlString
{
    if([urlString isEqualToString:@""] || urlString == nil){
        isURLvalid = TRUE;
        self.url = nil;
    }    
    else {
        NSURL *tmpUrl = [[[NSURL alloc] initWithString:urlString]autorelease] ;
        if(tmpUrl == nil)
            isURLvalid = FALSE;
        else{
            if(tmpUrl.scheme == nil){ 
                NSString* modifiedURLString = [NSString stringWithFormat:@"http://%@", urlString];
                tmpUrl = [[[NSURL alloc] initWithString:modifiedURLString]autorelease];
            }
            isURLvalid = TRUE;
            self.url = tmpUrl;
//            [tmpUrl release];
        }
        //[tmpUrl release];
    }
    //NSLog(@"url in job = %@, resource specifier: %@", [url absoluteString], url.scheme);
    
}

-(BOOL) isValid
{
    return isURLvalid && isEmailValid;
}

-(NSString*) invalidReason
{
    if(!isURLvalid)
        return @"URL";
    else if(!isEmailValid)
        return @"E-mail";
    else return nil;    
}

-(void) dealloc
{
    [super dealloc];    
}
@end
