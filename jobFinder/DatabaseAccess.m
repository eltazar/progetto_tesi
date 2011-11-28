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
#import "Utilities.h"
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

//invia richiesta registrazione token device sul db
-(void)registerDevice:(NSString*)token
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://www.sapienzaapps.it/jobfinder/registerDevice.php"];
    
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSURL *url = [[[NSURL alloc] initWithString:urlString] autorelease];
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *postFormatString = @"token=%@&latitude=%f&longitude=%f";
    NSString *postString = [NSString stringWithFormat:postFormatString,
                            token,[[pref objectForKey:@"lat"] doubleValue],[[pref objectForKey:@"long"] doubleValue]];

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
        //mostrare alert all'utente che la connessione è fallita??
    }

    
    
}

//invia richiesta lettura da db
-(void)jobReadRequestOldRegion:(MKCoordinateRegion)oldRegion newRegion:(MKCoordinateRegion)newRegion field:(NSString*)field
{
    NSLog(@"DATABASE ACCESS FIELD 1 = %@",field);
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://www.sapienzaapps.it/jobfinder/read2.php"];
    
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSURL *url = [[[NSURL alloc] initWithString:urlString] autorelease];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *postFormatString = @"oldLatitude=%f&oldLongitude=%f&oldLatSpan=%f&oldLongSpan=%f&newLatitude=%f&newLongitude=%f&newLatSpan=%f&newLongSpan=%f&field=%@";
    NSString *postString = [NSString stringWithFormat:postFormatString,
                            oldRegion.center.latitude,oldRegion.center.longitude,oldRegion.span.latitudeDelta,oldRegion.span.longitudeDelta,
                                newRegion.center.latitude,newRegion.center.longitude,newRegion.span.latitudeDelta,newRegion.span.longitudeDelta,field];
    
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
        //mostrare alert all'utente che la connessione è fallita??
    }
}   

-(void)jobReadRequest:(MKCoordinateRegion)region field:(NSString*)field
{
     NSLog(@"DATABASE ACCESS FIELD 2 = %@",field);
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://www.sapienzaapps.it/jobfinder/read.php"];
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSURL *url = [[[NSURL alloc] initWithString:urlString] autorelease];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *postFormatString = @"latitude=%f&longitude=%f&latSpan=%f&longSpan=%f&field=%@";
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


//invia richiesta scrittura su db
-(void)jobWriteRequest:(Job *)job
{ 
    
    NSLog(@"JOB CODE: %@", job.code);
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://www.sapienzaapps.it/jobfinder/write.php"];    
    //Replace Spaces with a '+' character.
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];  
    NSURL *url = [[[NSURL alloc] initWithString:urlString] autorelease]; //aggiunto autorelease
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *postFormatString = @"description=%@&phone=%@&email=%@&url=%@&date=%@&latitude=%f&longitude=%f&field=%@";
    NSString *postString = [NSString stringWithFormat:postFormatString,
        job.description,
        job.phone,
        job.email,
        job.urlAsString,
        job.date,
        job.coordinate.latitude,
        job.coordinate.longitude,
        job.code
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
    
    //esempio se richiedo connessione quando rete non disponibile, mostrare allert view?
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
    //NSLog(@"JSON  %@", json);
    
    if([readConnections containsObject:connection]){
        //creo array di job
        NSError *theError = NULL;
        NSArray *dictionary = [NSMutableDictionary dictionaryWithJSONString:json error:&theError];
       // NSLog(@"TIPO DEL DIZIONARIO %@",[dictionary class]);
       // NSLog(@"%@",dictionary);
        NSMutableArray *jobsArray = [[NSMutableArray alloc]initWithCapacity:dictionary.count];
    
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        //    return [f dateFromString:dateString];
        //NSLog(@"FORMATTER = %p",formatter);
       for(int i=0; i < dictionary.count-1; i++){
           NSDictionary *tempDict = [dictionary objectAtIndex:i];
           CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[tempDict objectForKey:@"latitude"] doubleValue],[[tempDict objectForKey:@"longitude"] doubleValue]);        
           Job *job = [[[Job alloc] initWithCoordinate:coordinate] autorelease]; //aggiunto 7 nov
                       
            //sistemare il tipo ritornato da field e da date
           job.employee = [Utilities sectorFromCode:[tempDict objectForKey:@"field"]];
           job.idDb = [[tempDict objectForKey:@"id"] integerValue];
           job.code = [tempDict objectForKey:@"field"];
           job.date = [formatter dateFromString: [tempDict objectForKey:@"date"]];
           job.description = [tempDict objectForKey:@"description"];
           job.phone = [tempDict objectForKey:@"phone"];
           //NSLog(@"########### email = %@",[tempDict objectForKey:@"email"] );
           job.email = [tempDict objectForKey:@"email"];
           [job setUrlWithString:[tempDict objectForKey:@"url"]];
            
            [jobsArray addObject:job];
        }
        
        if(delegate != nil &&[delegate respondsToSelector:@selector(didReceiveJobList:)])
            [delegate didReceiveJobList:jobsArray];
        
        [readConnections removeObject:connection];
        [jobsArray release]; //aggiunto 7 novembre
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
    [readConnections release];
    [writeConnections release];
    [dataDictionary release];
    [super dealloc];
}

@end
