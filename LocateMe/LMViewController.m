//
/* @author Dany Javier Bautista
*@email dany.bautista@mocionsoft.com
 
 */

#import "LMViewController.h"
#import "TTLocationHandler.h"
#import "LMAnnotation.h"
#import "LMPinTracker.h"
#import "LMRegion.h"
#import "LMTrackerRegion.h"
#import "RegionAnnotation.h"
#import "RegionAnnotationView.h"

@interface LMViewController ()
// Outlets

@property (nonatomic, weak) IBOutlet UIButton *resetButton;
@property (nonatomic, weak) IBOutlet UIButton *enviarUltimaPos;
@property (nonatomic, weak) IBOutlet UIButton *activarRegion;
@property (nonatomic, weak) IBOutlet UISwitch *backgroundToggleSwitch;
@property (nonatomic, weak) IBOutlet UITextField *refreshIntervalField;
@property (nonatomic, weak) IBOutlet UIStepper *refreshIntervalStepper;
@property (nonatomic, weak) IBOutlet UIButton *walkModeToggleButton;
// Private Properties
@property (nonatomic, strong)NSArray *locationsArray;
@property (nonatomic, weak)IBOutlet MKMapView *mapView;

//location manager test
@property (nonatomic, copy) CLLocation *lastKnownLocation;
// Private Methods
-(void)handleLocationUpdate;
-(void)updateLocationsArray;
-(void)refreshMapView;
-(void)clearStoredLocations;
// Actions
-(IBAction)resetButtonTouched:(id)sender;
-(IBAction)backgroundSwitchTouche:(id)sender;
-(IBAction)intervalStepActivated:(id)sender;
-(IBAction)toggleWalkMode:(id)sender;
-(IBAction)activarRegion:(id)sender;
- (IBAction)deleteLogBD:(UIButton *)sender;




@end




@implementation LMViewController
{
    BOOL _currentWalkMode;
    
    
   
}

@synthesize updatesTableView , updateEvents ,navigationBar;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSNotificationCenter *defaultNotificatoinCenter = [NSNotificationCenter defaultCenter];
    [defaultNotificatoinCenter addObserver:self selector:@selector(handleLocationUpdate) name:PinLoggerDidSaveNewLocation object:nil];
    
    TTLocationHandler *sharedHandler = [TTLocationHandler sharedLocationHandler];
    NSInteger interval = sharedHandler.recencyThreshold;
    self.refreshIntervalStepper.value = interval;
    self.refreshIntervalField.text = [NSString stringWithFormat:@"%i sec",interval];
    
    self.backgroundToggleSwitch.on = sharedHandler.continuesUpdatingOnBattery;
    _currentWalkMode = sharedHandler.walkMode;
    [self updateWalkButtonText];
    
    sharedHandler = nil;
    self.updateEvents = [[NSMutableArray alloc ] init];
    self.updatesTableView.delegate=self;
    self.updatesTableView.dataSource=self;
    
    //restar location manager every hour
    
    
    [self startTimer];
    
  
    
    

    // Set up our view
    [self updateLocationsArray];
    [self refreshMapView];
}


- (void) startTimer {
    [NSTimer scheduledTimerWithTimeInterval:3600
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) tick:(NSTimer *) timer {
    [self clearStoredLocations];
    NSArray *emptyArray = [NSArray array];
    self.locationsArray = emptyArray;
    [self refreshMapView];
    
    /* Setting lastKnown to nil and then asking for location is just a hacky
     * way of getting it to ignore the distance and recency filter and try for a new
     * accurate location right away.
     */
    TTLocationHandler *handler = [TTLocationHandler sharedLocationHandler];
    [handler setLastKnownLocation:nil];
    CLLocation *ourLocation = handler.lastKnownLocation;
    NSLog(@"Reset all location info\n%@",ourLocation);
    /*
     */
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *defaultNotificationCenter = [NSNotificationCenter defaultCenter];
    [defaultNotificationCenter removeObserver:self name:PinLoggerDidSaveNewLocation object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *defaultNotificatoinCenter = [NSNotificationCenter defaultCenter];
    [defaultNotificatoinCenter addObserver:self selector:@selector(handleLocationUpdate) name:PinLoggerDidSaveNewLocation object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

-(void)refreshMapView
{
    NSArray *oldAnnotations = [_mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!(self isKindOfClass: %@)", [MKUserLocation class]]];
    [self.mapView removeAnnotations:oldAnnotations];
    MKMapRect zoomRect = MKMapRectNull;
    
    NSUInteger totalMarcadores= self.locationsArray.count;
    
    int contador =0;
   
    
    //dibujo regiones ojo
    
    if([[LMTrackerRegion LMTrackerRegionGetInstance] totalRegiones]>0){
        
        NSMutableArray* regionesActuales = [[LMTrackerRegion LMTrackerRegionGetInstance] regiones];
        
        
        for ( CLRegion* region in regionesActuales ){
        
            RegionAnnotation* anotacionTemporal = [[ RegionAnnotation alloc] initWithCLRegion:region];
            
            [self.mapView addAnnotation:anotacionTemporal];
        
        
        }
    
    }
    
    
    
    
    
    
   

    
    for (id <MKAnnotation> annotation in self.locationsArray) {
        
            
            
            
            CLLocationCoordinate2D thisLocation = annotation.coordinate;
            if (CLLocationCoordinate2DIsValid(thisLocation) && ![annotation isKindOfClass:[MKUserLocation class]]) {
                
                //se agrega el marcador de posicion
                [self.mapView addAnnotation:annotation];
                
                // determine limits of map
                MKMapPoint annotationPoint = MKMapPointForCoordinate(thisLocation);
                MKMapRect pointRect = MKMapRectMake(annotationPoint.x - 4500.0, annotationPoint.y - 6000.0, 9000.0, 12000.0);
                if (MKMapRectIsNull(zoomRect)) {
                    zoomRect = pointRect;
                } else {
                    zoomRect = MKMapRectUnion(zoomRect, pointRect);
                }
            }

            
        
        
        
    }
    [self.mapView setVisibleMapRect:zoomRect animated:YES];
}

-(void)handleLocationUpdate
{
    [self updateLocationsArray];
    [self refreshMapView];
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if([annotation isKindOfClass:[RegionAnnotation class]]) {
		RegionAnnotation *currentAnnotation = (RegionAnnotation *)annotation;
		NSString *annotationIdentifier = [currentAnnotation title];
		RegionAnnotationView *regionView = (RegionAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		
		if (!regionView) {
			regionView = [[RegionAnnotationView alloc] initWithAnnotation:annotation] ;
			regionView.map = self.mapView;
			
			// Create a button for the left callout accessory view of each annotation to remove the annotation and region being monitored.
			UIButton *removeRegionButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[removeRegionButton setFrame:CGRectMake(0., 0., 25., 25.)];
			[removeRegionButton setImage:[UIImage imageNamed:@"RemoveRegion"] forState:UIControlStateNormal];
			
			regionView.leftCalloutAccessoryView = removeRegionButton;
            // Update or add the overlay displaying the radius of the region around the annotation.
            [regionView updateRadiusOverlay];
            
            return regionView;
		} else {
			regionView.annotation = annotation;
			regionView.theAnnotation = annotation;
            // Update or add the overlay displaying the radius of the region around the annotation.
            [regionView updateRadiusOverlay];
            
            return regionView;
		}
        
        
        static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
        MKAnnotationView *pinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
        
        
        if (pinView) {
            pinView.annotation = annotation;
            return pinView;
        } else {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier];
            [pinView setDraggable:NO];
            pinView.canShowCallout = YES;
            return pinView;
        }
        
        
        
        
        
        
		
		
	}
	
	return nil;
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	if([overlay isKindOfClass:[MKCircle class]]) {
		// Create the view for the radius overlay.
		MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay] ;
		circleView.strokeColor = [UIColor greenColor];
		circleView.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
		
		return circleView;
	}
	
	return nil;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	
}


/*
 This method adds the region event to the events array and updates the icon badge number.
 */
- (void)updateWithEvent:(NSString *)event {
    // Add region event to the updates array.
    [updateEvents insertObject:event atIndex:0];
      [self.updatesTableView reloadData];
    
    
    if (!updatesTableView.hidden) {
       // [updatesTableView reloadData];
    }
}

-(void)updateLocationsArray
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int numberOfPins = [defaults integerForKey:@"NUMBER_OF_PINS_SAVED"];
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:numberOfPins];
    
    for (int index = 0; index < numberOfPins; index++) {
        NSString *theKey = [NSString stringWithFormat:@"location%i", index];
        NSDictionary *savedDict = [defaults objectForKey:theKey];
        
        if (savedDict) {
            LMAnnotation *theAnnotation = [[LMAnnotation alloc] init];
            CLLocationDegrees lat = [[savedDict valueForKey:@"LATITUDE"] doubleValue];
            CLLocationDegrees Long = [[savedDict valueForKey:@"LONGITUDE"] doubleValue];
            CLLocationCoordinate2D theCoordinate = CLLocationCoordinate2DMake(lat, Long);
            theAnnotation.coordinate = theCoordinate;
            theAnnotation.title = [NSString stringWithFormat:@"Location%i", index];
            
            [mArray addObject:theAnnotation];
        }
    }
    
    self.locationsArray = [NSArray arrayWithArray:mArray];
}

-(void)clearStoredLocations
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int numberOfPins = [defaults integerForKey:@"NUMBER_OF_PINS_SAVED"];
    
    for (int counter = 0; counter < numberOfPins; counter++) {
        NSString *key = [NSString stringWithFormat:@"location%i",counter];
        [defaults removeObjectForKey:key];
    }
}

-(void)updateWalkButtonText
{
    if (_currentWalkMode) {
        [self.walkModeToggleButton setTitle:@"Walk" forState:UIControlStateNormal];
    } else {
        [self.walkModeToggleButton setTitle:@"Vehicle" forState:UIControlStateNormal];
    }
}


-(void) enviarPeticion:(int)codigo withData:(CLLocationCoordinate2D )laPosicion {
    
    NSString * latitud = [NSString stringWithFormat:@"\"longitud\":\"%f\"", laPosicion.longitude];
    NSString * longitud = [NSString stringWithFormat:@"\"latitud\":\"%f\"",laPosicion.latitude];
    NSString * idmovil = [NSString stringWithFormat:@"\"idmovil\":\"heel\""];
    NSString * idevento = [NSString stringWithFormat:@"\"idevento\":\"%d\"",codigo];
    
    
    
    
    //Se organiza la estructura de la URL para la peticion NSMutableURLRequest or NSURLRequest
    NSMutableURLRequest *request =
    [NSMutableURLRequest
     requestWithURL:[
                     NSURL URLWithString:@"http://apibacab.mocionsoft.com/actalizarPosicionMovil"
                     ]
     cachePolicy:NSURLRequestUseProtocolCachePolicy
     timeoutInterval:60.0
     ];
    
    
    
    //organizando el cuerpo de la peticion como un json
    
    NSString *params = [[NSString alloc] initWithFormat:@"{%@,%@,%@,%@}",latitud,longitud,idmovil,idevento];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Se hace la peticion a la URL organizada
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (theConnection) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aviso"
                                                        message:[NSString stringWithFormat: @"%@",  @"Dato enviado" ]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        
        
    } else {
        // Inform the user that the connection failed.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aviso"
                                                        message:[NSString stringWithFormat: @"%@",  @"Dato no enviado" ]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    
}




#pragma mark - Actions

-(IBAction)activarRegion:(id)sender
{
     TTLocationHandler *handler = [TTLocationHandler sharedLocationHandler];
      
     CLLocation *ourLocation = handler.lastKnownLocation;
     
     
    // NSLog(@"Reset all location info\n%@",ourLocation);
     
    CLLocationCoordinate2D posActual = ourLocation.coordinate;
    LMRegion *geocerca = [[LMRegion alloc] initRegionWithidDb:0 andRadio:500 andCentro:posActual andNombre:@"region 1" ];
    [[LMTrackerRegion LMTrackerRegionGetInstance ] agregarRegion:geocerca];
    
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aviso"
                                                    message:[NSString stringWithFormat: @"%@",  @"Geocerca establecida" ]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    
    
    
    
    
}

- (IBAction)deleteLogBD:(UIButton *)sender {
    
    [[LMTrackerRegion LMTrackerRegionGetInstance] deleteErroresDb ];
}



-(IBAction)enviarUltimaPos:(id)sender
{
    TTLocationHandler *handler = [TTLocationHandler sharedLocationHandler];
    
    CLLocation *ourLocation = handler.lastKnownLocation;
    
    
    // NSLog(@"Reset all location info\n%@",ourLocation);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self enviarPeticion:9 withData:ourLocation.coordinate];
    });
    
    
    
}


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    
}

- (IBAction)switchViews {
	// Swap the hidden status of the map and table view so that the appropriate one is now showing.
	self.mapView.hidden = !self.mapView.hidden;
   
	self.updatesTableView.hidden = !self.updatesTableView.hidden;
	
	// Adjust the "add region" button to only be enabled when the map is shown.
	NSArray *navigationBarItems = [NSArray arrayWithArray:self.navigationBar.items];
	UIBarButtonItem *addRegionButton = [[navigationBarItems objectAtIndex:0] rightBarButtonItem];
	addRegionButton.enabled = !addRegionButton.enabled;
	
	// Reload the table data and update the icon badge number when the table view is shown.
	if (!updatesTableView.hidden) {
		[updatesTableView reloadData];
	}
}

-(IBAction)resetButtonTouched:(id)sender
{
    [self clearStoredLocations];
    NSArray *emptyArray = [NSArray array];
    self.locationsArray = emptyArray;
    [self refreshMapView];
    
    /* Setting lastKnown to nil and then asking for location is just a hacky
     * way of getting it to ignore the distance and recency filter and try for a new
     * accurate location right away.
     */
    TTLocationHandler *handler = [TTLocationHandler sharedLocationHandler];
    [handler setLastKnownLocation:nil];
    CLLocation *ourLocation = handler.lastKnownLocation;
    NSLog(@"Reset all location info\n%@",ourLocation);
    /*
     */
}

-(IBAction)backgroundSwitchTouche:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    TTLocationHandler *sharedHandler = [TTLocationHandler sharedLocationHandler];
    sharedHandler.continuesUpdatingOnBattery = theSwitch.on;
    sharedHandler = nil;
}

-(IBAction)intervalStepActivated:(id)sender
{
    UIStepper *stepper = (UIStepper *)sender;
    int newInterval = stepper.value;
    TTLocationHandler *sharedHandler = [TTLocationHandler sharedLocationHandler];
    sharedHandler.recencyThreshold = newInterval;
    sharedHandler = nil;
    self.refreshIntervalField.text = [NSString stringWithFormat:@"%i sec",newInterval];
    
    if (newInterval >= 60) {
        stepper.stepValue = 120;
    } else if (newInterval >= 30) {
        stepper.stepValue = 15;
    } else {
        stepper.stepValue = 5;
    }
    
}



-(void)toggleWalkMode:(id)sender
{
    TTLocationHandler *handler = [TTLocationHandler sharedLocationHandler];
    _currentWalkMode = !_currentWalkMode;
    handler.walkMode = _currentWalkMode;
    
    [self updateWalkButtonText];
    
    handler = nil;
}



#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[LMTrackerRegion LMTrackerRegionGetInstance] getErrores ] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] ;
    }
    
	cell.textLabel.font = [UIFont systemFontOfSize:12.0];
	cell.textLabel.text = [[[LMTrackerRegion LMTrackerRegionGetInstance] getErrores ] objectAtIndex:indexPath.row];
	cell.textLabel.numberOfLines = 4;
	
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}










- (void)viewDidUnload {
    [self setDeleteLogDb:nil];
    [super viewDidUnload];
}
@end
