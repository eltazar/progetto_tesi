//
//  HelpViewController.m
//  jobFinder
//
//  Created by mario greco on 28/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"
#import "PagesControllerViewController.h"

static NSUInteger numeroTotalePagine = 4;

@implementation HelpViewController
@synthesize  scrollView, pageControl, arrayDelleView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// metodo che inserisce le pagine nella scrollView su richiesta

- (void)loadScrollViewWithPage:(int)page {
	
	// controllo che non sia l'ultima o la prima pagina quella passata
    if (page < 0) return;
    if (page >= numeroTotalePagine) return;
	
	// aggiorno il segnaposto se necessario
	
    PagesControllerViewController *controller = [arrayDelleView objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[PagesControllerViewController alloc] initWithnumeroPagina:page];
        [arrayDelleView replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
	
	// aggiungo la pagina alla scrollview
	
    if (nil == controller.view.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }
}


// metodo che gestisce lo scroll e decide quali pagine caricare (attuale, precedente, succesiva) in base a cosa gli è stato passato 

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	
	// impediamo che non si crei un loop quando un utente effettua lo scroll, per impedirlo ho creato un pageControlUsato che disabilita il delegato, quindi se il valore è vero non faccio niente e blocco il possibile loop
	
	if (pageControlUsato) {
        
        // non faccio nulla		
		
        return;
    }
	
    // cambio l'indicatore di quale è la pagina corrente non appena quando sto effettuando lo scroll visualizzo oltre del 50% della pagina successiva/precedente	
	
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
	
	// e allora ricarico la pagina attuale, la pagina precedente e la pagina successiva
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	
    // A possible optimization would be to unload the views+controllers which are no longer visible
	
}

// metodo che una volta terminato lo scroll imposta il pageControlUsato a NO (variabile che serve per non trovarsi in un loop di pagine appena scrollo)

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsato = NO;
}


// metodo da creare a modo per il tap on pulsantino in basso

- (IBAction)cambiaPagina:(id)sender {
    int page = pageControl.currentPage;
	
	// e allora ricarico la pagina attuale, la pagina precedente e la pagina successiva
	
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
	
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.	
	
    pageControlUsato = YES;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Help"];
    
    //[pageCtrl setCurrentPage:0];
    
    [pageControl setFrame:CGRectMake(pageControl.frame.origin.x, self.view.frame.size.height - 10, pageControl.frame.size.width, pageControl.frame.size.height)];
    
   //un dito swipe verso sinistra
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < numeroTotalePagine; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.arrayDelleView = controllers;
    [controllers release];
	
	
	// imposto la larghezza e altezza della scroll view che ho definito in IB - larga come la larghezza della scroll view moltiplicata per le pagine che ho - alta come l'altezza della scroll view
	
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numeroTotalePagine, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
	
	// imposto il pageControl e gli dico che le pagine totali sono quelle che ho impostato e che la pagina corrente è la 0 (sono in avvio)
	
    pageControl.numberOfPages = numeroTotalePagine;
    pageControl.currentPage = 0;
	
	
	// le pagine sono create quando richieste
    // carica la pagina visibile
    // carica la pagina precedente e successiva così da generare lo scroll avanti e indietro; adesso sono all'avvio quindi carico la pagina precedente (che però essendo all'avvio è sempre la pagina attuale ovvero 0) e la pagina successiva (1)
	
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc{
    
    [arrayDelleView release];
    [scrollView release];
    [pageControl release];

    [super dealloc];
}


@end
