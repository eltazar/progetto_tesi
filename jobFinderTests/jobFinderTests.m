//
//  jobFinderTests.m
//  jobFinderTests
//
//  Created by mario greco on 15/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "jobFinderTests.h"
#import "DatabaseAccess.h"
#import "Job.h"

@implementation jobFinderTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    db = [[[[DatabaseAccess alloc]init] retain] retain];
    jobs = [[NSMutableArray alloc]initWithCapacity:25];
    [db setDelegate:self];
    
    //NSLog(@"ESEGUITO");
    
    controlString = @"";
    
    for(int i=0;i < 25; i++){          
        CGFloat latDelta = rand()*.11/RAND_MAX -.02;
        CGFloat longDelta = rand()*.11/RAND_MAX -.015;
        CLLocationCoordinate2D newCoord = {41.891672+ latDelta,12.493515+ longDelta };
        Job *jobAnn = [[Job alloc] initWithCoordinate:newCoord];
        jobAnn.employee = [NSString stringWithFormat:@"%d",i];
        jobAnn.description = @"bla";
        jobAnn.phone = @"1234";
        jobAnn.date = @"2011-11-01";
        [jobs addObject:jobAnn];
        controlString = [controlString stringByAppendingString:@"Connesso con successo1[false]"]; 
    }
    
    testCompleteness = 0;
    
    
}

- (void)tearDown
{
    // Tear-down code here.
//    [db release];
//    [jobs release];
    [super tearDown];
}

-(void)didReceiveResponsFromServer:(NSString *)receivedData
{
    
    testCompleteness++;
    //NSLog(@"##RECEIVED DATA = %@", receivedData);
    STAssertTrue(([receivedData compare:
                   @"Connesso con successo1[false]È considerata l'opera più rappresentativa del Risorgimento e del romanticismo italiano e una delle massime opere della letteratura italiana. Dal punto di vista strutturale è il primo romanzo moderno nella storia di tutta la letteratura italiana. Lopera ebbe anche un'enorme influenza nella definizione di una lingua nazionale italiana[2].Considerato principalmente un romanzo storico, in realtà l'opera va benoltre i ristretti limiti di tale genere letterario: il Manzoni infatti, attraverso la ricostruzione dell'Italia del '600, non tratteggia soltanto un grande affresco storico, ma prefigura degli evidenti parallelismi con i processi storici di cui era testimone nel suo tempo, non limitandosi ad indagare il passato ma tracciando anche una idea ben precisa del senso della storia, e del rapporto che il singolo ha con gli eventi storici che lo coinvolgono[3].È al tempo stesso romanzo di formazione (si veda in particolare il percorso umano di Renzo), ma per alcune ambientazioni e vicende presenti (la Monaca di Monza, il rapimento di Lucia segregata poi nel castello), ha anche caratteristiche che lo possono accomunare ai romanzi gotici gioco dei contrapposti egoismi genera effetti a volte disastrosi nella storia, ma Dio non abbandona gli uomini, e la fede nella Provvidenza, nell'opera manzoniana, permette di dare un senso ai fatti e alla storia dell'uomo.Dopo un lungo dibattere e cercare insieme, conclusero che i guai vengono bensì spesso, perché ci si è dato cagione; ma che la condotta più cauta e più innocente non basta a tenerli lontani, e che quando vengono, o per colpa o senza colpa, la fiducia in Dio li raddolcisce, e li rende utili per una vita migliore. (I promessi sposi, cap. XXXVIII) »In particolare il romanzo ha un suo punto di forza nella scelta e nella raffigurazione dei personaggi, resi tutti con grande forza narrativa, scolpiti a tutto tondo dal punto di vista psicologico e umano, tanto che alcuni di essi sono diventati degli stereotipi umani, usati ancora oggi nel linguaggio comune (si pensi ad esempio a un don Abbondio o alla figura di un Azzeccagarbugli o di una Perpetua). Una rappresentazione psicologica così accurata dei suoi personaggi fa sì che, salvo poche eccezioni, quasi nessuno di essi sia completamente positivo o negativo. Anche il malvagio trova un'occasione di umanità e redenzione, così come anche il personaggio positivo, quale ad esempio Renzo, non è immune da difetti, azioni violente e riprovevoli ed errori anche gravi. La stessa Lucia viene tacciata spesso come egoista e addirittura solipsista, e non sempre a torto: il discorso di padre Cristoforo a Lucia al Lazzaretto, benché paterno e benevolo, è durissimo. Lo stesso Padre Cristoforo, il personaggio forse più positivo del romanzo assieme al Cardinale Federigo Borromeo (e anchegli non è esente da tragici errori, come si vede dal Romanzo stesso e dalla Colonna Infame), ha anche lui una grave macchia nel suo passato.È anche questa caratteristica quindi a consentire al romanzo di elevarsi ben al di sopra del livello medio dei romanzi storici e gotici dell'Ottocento.La maestria del Manzoni nel tratteggiare i suoi personaggi emerge soprattutto nei dialoghi, scritti con sottile cura, che spesso sono i veri rivelatori dei personaggi, della loro psicologia e delle loro motivazioni."] == NSOrderedSame), @"");
}

-(void)testConnection
{
    for(int i=0;i < 25; i++){
        //NSLog(@"############");
        //NSLog(@"job %@", [jobs objectAtIndex:i]);
        [db jobWriteRequest:[jobs objectAtIndex:i]];
        //sleep(1);
    }
    
    NSRunLoop *theRL = [NSRunLoop currentRunLoop];
    
    // Begin a run loop terminated when the downloadComplete it set to true
    while (testCompleteness < 25 && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:30.0]]);

}

-(void)testReadConnection
{
    MKCoordinateRegion region;
    region.center.latitude = 37.0;
    region.center.longitude = -122.0;
    region.span.latitudeDelta = 2.0;
    region.span.longitudeDelta = 2.0;
    
    [db jobReadRequest:region field:0];
    NSRunLoop *theRL = [NSRunLoop currentRunLoop];
    
    // Begin a run loop terminated when the downloadComplete it set to true
    while (testCompleteness < 1 && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:30.0]]);
    
}

//- (void)testExample
//{
//    STFail(@"Unit tests are not implemented yet in jobFinderTests");
//}

//- (void) testPass {
//    STAssertTrue(TRUE, @"");
//}

//- (void) testFail {
//    STFail(@"Must fail to succeed.");
//}
@end
