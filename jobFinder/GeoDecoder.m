//
//  SearchAddress.m
//  jobFinder
//
//  Created by mario greco on 20/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GeoDecoder.h"
#import "NSDictionary_JSONExtensions.h"

@implementation GeoDecoder
@synthesize dictionary, delegate;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) searchCoordinatesForAddress:(NSString *)inAddress
{
    //Build the string to Query Google Maps.
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true",inAddress];    
    
    //Replace Spaces with a '+' character.
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
    //Create NSURL string from a formate URL string.
    NSURL *url = [NSURL URLWithString:urlString];
    
    //Setup and start an async download.
    //Note that we should test for reachability!.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection release];
    [request release];
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    if (receivedGeoData) 
    {
        [receivedGeoData release];
        receivedGeoData = nil;
        receivedGeoData = [[NSMutableData alloc] init];
    }
    else
        receivedGeoData = [[NSMutableData alloc] init];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{   
    [receivedGeoData appendData:data]; 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *jsonResult = [[NSString alloc] initWithData:receivedGeoData encoding:NSUTF8StringEncoding];
    NSString *jsonResult = [[[NSString alloc] initWithData:receivedGeoData encoding:NSUTF8StringEncoding] autorelease]; //giusto sto autorelease?
    NSError *theError = NULL;
    dictionary = [NSMutableDictionary dictionaryWithJSONString:jsonResult error:&theError];
    
//    NSLog(@"%@",dictionary);
//    NSLog(@"JSON is: %@",jsonResult);
    
    int numberOfSites = [[dictionary objectForKey:@"results"] count];
//    NSLog(@"count is %d ",numberOfSites);      
    
    [delegate didReceivedGeoDecoderData:dictionary];
}


-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Handle the error properly
}


#pragma mark - Memory Management

-(void) dealloc
{
    [receivedGeoData release];
    [super dealloc];

}


@end
