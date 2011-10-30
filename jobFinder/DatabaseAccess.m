//
//  DatabaseAccess.m
//  jobFinder
//
//  Created by mario greco on 25/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DatabaseAccess.h"
#import "NSDictionary_JSONExtensions.h"
#import "Job.h"

@implementation DatabaseAccess

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


-(void)jobWriteRequest:(Job *)job
{ 
    //NSLog(@"@@@@@@@@@@@@@@@@");
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://jobfinder.altervista.org/write.php"];    
    //Replace Spaces with a '+' character.
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];  
    NSURL *url = [[[NSURL alloc] initWithString:urlString] autorelease]; //aggiunto autorelease
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *postFormatString = @"description=%@&phone=%@&email=%@&url=%@&date=%@&latitude=%f&longitude=%f&field=0";
    NSString *postString = [NSString stringWithFormat:postFormatString,
        job.description,
        job.phone,
        job.email,
        job.url,
        @"2011-01-03",
        job.coordinate.latitude,
        job.coordinate.longitude
    ];
        
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    [request addValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPMethod:@"POST"];
  
    [request setHTTPBody:postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(connection){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

        receivedData = [[NSMutableData data] retain];
    }
    else{
        NSLog(@"theConnection is NULL");
        //mostrare alert all'utente che la connessione è fallita
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength: 0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"XXXX %@",data);
    [receivedData appendData:data];
}

//If an error is encountered during the download, the delegate receives a connection:didFailWithError:
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSLog(@"ERROR with theConenction");
    [connection release];
    [receivedData release];
}

//if the connection succeeds in downloading the request, the delegate receives the connectionDidFinishLoading:
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    NSLog(@"DONE. Received Bytes: %d", [receivedData length]);
    NSString *json = [[NSString alloc] initWithBytes: [receivedData mutableBytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
    NSLog(@"JSON %p %@",json, json);
    
    //rilascio risorse, come spiegato sula documentazione apple
    [json release];
    [connection release];
    [receivedData release];
}

-(void)enqueueJobWriteRequest:(Job*)job
{
}

@end
