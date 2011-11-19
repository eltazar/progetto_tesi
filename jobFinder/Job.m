//
//  Job.m
//  jobFinder
//
//  Created by mario greco on 17/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Job.h"

@implementation Job

@synthesize employee, date, address, city, description, phone, url, email, coordinate, subtitle, idDb;
@synthesize isAnimated, isMultiple, isDraggable;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        idDb = 0;
        isMultiple = FALSE;
        isAnimated = TRUE;
        isEmailValid = TRUE;
        isURLvalid = TRUE;
        isDraggable = NO;
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
    if(employee != nil)
        return employee;
    return @"Sposta il pin se vuoi";
}

- (NSString *)subtitle {
    
    if(date != nil){
        //setto data creazione annuncio
        NSLocale *locale = [NSLocale currentLocale];
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease]; 
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyyMMMd" options:0 locale:locale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:locale];
        
        return [NSString stringWithFormat:@"Inserito: %@", [formatter stringFromDate:date]];
    }
    else return @"";
}

-(NSString*)stringFromDate
{
    if(date != nil){
        //setto data creazione annuncio
        NSLocale *locale = [NSLocale currentLocale];
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease]; 
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyyMMMd" options:0 locale:locale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:locale];
        
        return [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
    }
    else return @"Non disponibile";
}

-(void) setEmail:(NSString*)newEmail
{
    NSString* emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if(newEmail == nil)
        isEmailValid = TRUE;
    else if([newEmail isKindOfClass:[NSNull class]] || [newEmail isEqualToString:@""]){
        isEmailValid = TRUE;
        [newEmail release];
        newEmail = nil;
    }
    else isEmailValid = [emailTest evaluateWithObject:newEmail];
  
    
    if(isEmailValid){
        [newEmail retain];
        [email release];
        email = newEmail;
    }
}

-(void)setPhone:(NSString *)newPhone
{
    /*SE NEWPHONE è NIL VIENE AUTOMATICAMENTE SALVATO A NIL*/
    //NSLog(@"NEW PHONE = %@",newPhone);
    if([newPhone isKindOfClass:[NSNull class]] || [newPhone isEqualToString:@""]){
        [newPhone release];
        newPhone = nil;
    }
   
    [newPhone retain];
    [phone release];
    phone = newPhone;
    
//    NSLog(@"PHONE = %p, %@",phone,phone);
    
}


//problemi con questo metodo, vedere commit 7 novembre
-(void)setDescription:(NSString *)newDescription
{
    //NSLog(@"NEW DESCR: %@",newDescription);
        
    if([newDescription isKindOfClass:[NSNull class]] || [newDescription isEqualToString:@""]){ //aggiunto 7 novembre xchè app crash
//        [newDescription release];
//        newDescription = nil;
        
        description = @"";
        return;
    }
    
    [newDescription retain];
    [description release];
    description = newDescription;
}

-(void) setUrlWithString:(NSString *) newUrlString
{
    if(newUrlString == nil || [newUrlString isKindOfClass:[NSNull class]] || [newUrlString isEqualToString:@""]){
        
           isURLvalid = YES;
           self.url = [NSURL URLWithString:@""];
           return;
    }    
    
    NSURL *tmpURL;

    if ([newUrlString rangeOfString:@"http://"].location == NSNotFound) {
                    
        NSString *stringModified = [NSString stringWithFormat:@"http://%@",newUrlString];
        tmpURL = [[NSURL alloc]initWithString:stringModified];
    }
    else {
        tmpURL = [[NSURL alloc] initWithString:newUrlString];
    }
    
    if(tmpURL == nil)
        isURLvalid = NO;
    else isURLvalid = YES;
    
    if(isURLvalid){
        self.url = tmpURL;
    }
    
    [tmpURL release];

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


#warning fare i getter in modo tale che se la stringhe puntano a nil ritorna stringa @""


- (NSString *)description
{
    NSString *tmpDescription;
    if(description == nil){
        tmpDescription = @"";
    }
    else{
        tmpDescription = description;
    }
#warning come cazzo funzionano i getter con le properTy???
    return [[tmpDescription  retain] autorelease];
}

- (NSString *)email
{    
    NSString *tempEmail;
    if(email == nil){
        tempEmail = @"";
    }
    else{
        tempEmail = email;
    }
    return [[ tempEmail retain] autorelease];
}

- (NSString *)phone
{    
    NSString *tempPhone;
    
    if(phone == nil){
       tempPhone = @"";
    }
    else{
        tempPhone = phone;
    }
    return [[ tempPhone retain] autorelease];
}

//- (NSURL *)url
//{    
//    if(url == nil){
//        url = [[[NSURL alloc] initWithString:@""]autorelease];
//        NSLog(@"URL é : %@",[url absoluteString]);
//    }
//    return [[ url retain] autorelease];
//}

-(NSString*)urlAsString
{
    NSLog(@"URL = %@", [url absoluteString]);
    
    if(url == nil)
        return @"";
    else{
        return [url absoluteString];
    }
}

//effettua la ricerca binaria su un array di un dato un idDb di un'annotation
+(NSInteger)jobBinarySearch:(NSArray*)array withID:(NSInteger) x
{   
    //    NSLog(@"RICERCA BINARIA; ARRAY COUNT = %d",array.count);
    //NSLog(@"X = %d",x);
    NSInteger p;
    NSInteger u;
    NSInteger m;
    p = 0;
    u = [array count] - 1;
    //    NSLog(@"U = %d",u);
    NSObject *element = nil;
    
    while(p <= u) {
        m = (p+u)/2;
        element = [array objectAtIndex:m];
        //NSLog(@"M = %d",m);
        
        //NSLog(@"M.IDDB = %d",((Job*)[array objectAtIndex:m]).idDb);
        
        if(((Job*)element).idDb == x){ 
            //NSLog(@"TROVATO");
            return m; // valore x trovato alla posizione m
        }
        else if(((Job*)element).idDb > x)
            p = m+1;
        else{
            u = m-1;
        }
        
        //NSLog(@"P = %d ##### U = %d",p,u);
        
        
    }
    
    //NSLog(@"NON TROVATO");
    return -1;
}

+(void)orderJobsByID:(NSMutableArray*)jobs
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"idDb"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [jobs sortUsingDescriptors:sortDescriptors]; 
}

+(void)mergeArray:(NSMutableArray*)totalArray withArray:(NSArray*)jobs
{
    
//    if(totalArray.count == 0){
//        [totalArray addObjectsFromArray: jobs];
//        return;
//    }
        
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:([totalArray count]+[jobs count])];
    
    int i = 0;
    
    int a = 0;
    int b = [totalArray count];
    int c = 0;
    int d = [jobs count];
    
    while(a<b && c<d){
        
        if(((Job*)[totalArray objectAtIndex:a]).idDb >= ((Job*)[jobs objectAtIndex:c]).idDb){
            if((i-1 < 0) || ((Job*)[totalArray objectAtIndex:a]).idDb != ((Job*)[tempArray objectAtIndex:i-1]).idDb){
                [tempArray insertObject:[totalArray objectAtIndex:a] atIndex:i];
                ++i;
            }
            ++a;
        }
        else{
            if((i-1 < 0) || ((Job*)[jobs objectAtIndex:c]).idDb != ((Job*)[tempArray objectAtIndex:i-1]).idDb){
                [tempArray insertObject:[jobs objectAtIndex:c] atIndex:i];
                ++i;
            }
            ++c;
        }
    }
    
    if(a < b) {
        for (int p = a; p < b; p++) {
            [tempArray insertObject: [totalArray objectAtIndex:p] atIndex:i];
            i++;
        }
    } else {
        for (int p = c; p < d; p++) {
            [tempArray insertObject: [jobs objectAtIndex:p] atIndex:i];
            i++;
        }
    }
    
    
//    for(Job *j in tempArray)
//        NSLog(@"JOB ID = %d",j.idDb);
    
    [totalArray removeAllObjects];
    [totalArray addObjectsFromArray:tempArray];    
    [tempArray release];
}


-(void)dealloc{
    [subtitle release];
    [employee release];
    [date release];
    [address release];
    [city release];
    [phone release];
    [email release];
    [description release];
    [url release];
    url = nil;
    [super dealloc];
}

@end
