//
//  SearchAddress.m
//  jobFinder
//
//  Created by mario greco on 20/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GeoDecoder.h"
#import "NSDictionary_JSONExtensions.h"
#import "CoreLocation/CLLocation.h"

@implementation GeoDecoder
@synthesize geoDataDictionary, delegate;


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
        
    if(connection){
        //NSLog(@"IS CONNECTION TRUE");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    else{
        NSLog(@"theConnection is NULL");
        //mostrare alert all'utente che la connessione è fallita
    }
    
    [connection release];
    [request release];
}

-(void)searchAddressForCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",coordinate.latitude,coordinate.longitude];    
    
    //Replace Spaces with a '+' character.
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    //Create NSURL string from a formate URL string.
    NSURL *url = [NSURL URLWithString:urlString];
    
    //Setup and start an async download.
    //Note that we should test for reachability!.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
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
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *jsonResult = [[[NSString alloc] initWithData:receivedGeoData encoding:NSUTF8StringEncoding] autorelease]; //giusto sto autorelease?
    NSError *theError = NULL;
    geoDataDictionary = [NSMutableDictionary dictionaryWithJSONString:jsonResult error:&theError];
    
   // NSLog(@"%@",dictionary);
//    NSLog(@"JSON is: %@",jsonResult);
    
    if(delegate && [delegate respondsToSelector:@selector(didReceivedGeoDecoderData:)])
        [delegate didReceivedGeoDecoderData:geoDataDictionary];
}


-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSLog(@"ERRORE GEOCODING %@", [error localizedFailureReason] );
    // Handle the error properly
}


#pragma mark - Memory Management

-(void) dealloc
{
    [receivedGeoData release];
    [super dealloc];

}


@end
