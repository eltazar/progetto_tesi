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
