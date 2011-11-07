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

NSString* key(NSURLConnection* con)
{
    return [NSString stringWithFormat:@"%p",con];
}

@implementation DatabaseAccess
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        //connectionDictionary = [[NSMutableDictionary alloc] init];
        dataDictionary = [[NSMutableDictionary alloc] init];
        readConnections = [[NSMutableArray alloc]init];
        writeConnections = [[NSMutableArray alloc]init];
    }
    
    return self;
}

-(void)jobReadRequest:(MKCoordinateRegion)region field:(NSInteger)field
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://jobfinder.altervista.org/read.php"];
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSURL *url = [[[NSURL alloc] initWithString:urlString] autorelease];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *postFormatString = @"latitude=%f&longitude=%f&latSpan=%f&longSpan=%f&field=%d";
    NSString *postString = [NSString stringWithFormat:postFormatString,
                            region.center.latitude,region.center.longitude,region.span.latitudeDelta,region.span.longitudeDelta,field];
    
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    [request addValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(connection){
        //NSLog(@"IS CONNECTION TRUE");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        [readConnections addObject:connection];
        
        NSMutableData *receivedData = [[NSMutableData data] retain];
        //[connectionDictionary setObject:connection forKey:key(connection)];
        [dataDictionary setObject:receivedData forKey:key(connection)];
        //NSLog(@"RECEIVED DATA FROM DICTIONARY : %p",[dataDictionary objectForKey:connection]);
    }
    else{
        NSLog(@"theConnection is NULL");
        //mostrare alert all'utente che la connessione è fallita
    }
}   

-(void)jobWriteRequest:(Job *)job
{ 
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
        job.urlAsString,
        job.date,
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
        //NSLog(@"IS CONNECTION TRUE");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

        [writeConnections addObject:connection];
        
        NSMutableData *receivedData = [[NSMutableData data] retain];
        //[connectionDictionary setObject:connection forKey:key(connection)];
        [dataDictionary setObject:receivedData forKey:key(connection)];
        //NSLog(@"RECEIVED DATA FROM DICTIONARY : %p",[dataDictionary objectForKey:connection]);
    }
    else{
        NSLog(@"theConnection is NULL");
        //mostrare alert all'utente che la connessione è fallita
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"DID RECEIVE RESPONSE");
    
    NSMutableData *receivedData = [dataDictionary objectForKey:key(connection)];

    [receivedData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //sto log crea memory leak
    //NSLog(@"XXXX %@",[[NSString alloc] initWithBytes: [data bytes] length:[data length] encoding:NSASCIIStringEncoding]);
    NSMutableData *receivedData = [dataDictionary objectForKey:key(connection)];

    [receivedData appendData:data];
    //NSLog(@"RECEIVED DATA AFTER APPENDING %@",receivedData);
}

//If an error is encountered during the download, the delegate receives a connection:didFailWithError:
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSMutableData *receivedData = [dataDictionary objectForKey:key(connection)];
    [dataDictionary removeObjectForKey:key(connection)];
    
    [readConnections removeObject:connection];
    [writeConnections removeObject:connection];
    
    NSLog(@"ERROR with theConenction");
    [connection release];
    [receivedData release];
}

//if the connection succeeds in downloading the request, the delegate receives the connectionDidFinishLoading:
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSMutableData *receivedData = [dataDictionary objectForKey:key(connection)];

    //NSLog(@"DONE. Received Bytes: %d", [receivedData length]);
    NSString *json = [[NSString alloc] initWithBytes: [receivedData mutableBytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
    //NSLog(@"JSON %p %@",json, json);
    
    if([readConnections containsObject:connection]){
        //creo array di job
        NSError *theError = NULL;
        NSArray *dictionary = [NSMutableDictionary dictionaryWithJSONString:json error:&theError];
       // NSLog(@"TIPO DEL DIZIONARIO %@",[dictionary class]);
       NSLog(@"%@",dictionary);
        NSMutableArray *jobsArray = [[NSMutableArray alloc]initWithCapacity:dictionary.count];
    
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        //    return [f dateFromString:dateString];
        //NSLog(@"FORMATTER = %p",formatter);
       for(int i=0; i < dictionary.count-1; i++){
           NSDictionary *tempDict = [dictionary objectAtIndex:i];
           CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[tempDict objectForKey:@"latitude"] doubleValue],[[tempDict objectForKey:@"longitude"] doubleValue]);        
           Job *job = [[Job alloc] initWithCoordinate:coordinate];
            
            //sistemare il tipo ritornato da field e da date
           job.idDb = [[tempDict objectForKey:@"id"] integerValue];
           job.employee = [tempDict objectForKey:@"field"];
           job.date = [formatter dateFromString: [tempDict objectForKey:@"date"]];
           job.description = [tempDict objectForKey:@"description"];
           job.phone = [tempDict objectForKey:@"phone"];
           //NSLog(@"########### email = %@",[tempDict objectForKey:@"email"] );
           job.email = [tempDict objectForKey:@"email"];
           [job setUrlWithString:[tempDict objectForKey:@"url"]];
            
            [jobsArray addObject:job];
        }
        
        [delegate didReceiveJobList:jobsArray];
        [readConnections removeObject:connection];
        [formatter release];
        formatter = nil;
    
        
    }else{        
        [delegate didReceiveResponsFromServer:json];
        [writeConnections removeObject:connection];
    }
        //rilascio risorse, come spiegato sula documentazione apple
    [json release];
    
    [dataDictionary removeObjectForKey:key(connection)];
    
//    [readConnections removeObject:connection];
//    [writeConnections removeObject:connection];
    
    [connection release];
    [receivedData release];
}


-(void)dealloc
{
    [dataDictionary release];
    [super dealloc];
}

@end
