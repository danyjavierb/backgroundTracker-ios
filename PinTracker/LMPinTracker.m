//


#import "LMPinTracker.h"
#import "TTLocationHandler.h"
#import "LMTrackerRegion.h"


@interface LMPinTracker()

{
    NSDate *_mostRecentUploadDate;
}

-(void)storeMostRecentLocationInfo;
-(void)handleLocationUpdate;
-(void)uploadCurrentData;

@end

@implementation LMPinTracker

-(id)init
{
    self = [super init];
    if (self) {
        
        NSNotificationCenter *defaultNotificatoinCenter = [NSNotificationCenter defaultCenter];
        [defaultNotificatoinCenter addObserver:self selector:@selector(handleLocationUpdate) name:LocationHandlerDidUpdateLocation object:nil];
        
    }

    
    return self;
}

-(void)storeMostRecentLocationInfo
{
    static int locationIndex = 0;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *lastKnowLocationInfo = [defaults objectForKey:@"LAST_KNOWN_LOCATION"];
    if (!lastKnowLocationInfo) {
        return;
    }
    
    // store the location info
    NSString *theKey = [NSString stringWithFormat:@"location%i", locationIndex];
    [defaults setObject:[NSDictionary dictionaryWithDictionary:lastKnowLocationInfo] forKey:theKey];
    
    int numberOfPinsSaved = [defaults integerForKey:@"NUMBER_OF_PINS_SAVED"];
    
    if (locationIndex == numberOfPinsSaved) {
        locationIndex = 0;
        return;
    }
    
    locationIndex++;
}

-(void)handleLocationUpdate
{
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier locationUpdateTaskID = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (locationUpdateTaskID != UIBackgroundTaskInvalid) {
                // *** CONSIDER MORE APPROPRIATE RESPONSE TO EXPIRATION *** //
                [app endBackgroundTask:locationUpdateTaskID];
                locationUpdateTaskID = UIBackgroundTaskInvalid;
            }
        });
    }];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        
        
        
        //Enter Background Operations here
        [self storeMostRecentLocationInfo];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *lastKnowLocationInfo = [defaults objectForKey:@"LAST_KNOWN_LOCATION"];
        
        // Alternately, lastKnownLocation could be obtained directly like so:
        CLLocation *lastKnownLocation = [[TTLocationHandler sharedLocationHandler] lastKnownLocation];
        
        
        
        
      //  NSLog(@"Alternate location object directly from handler is \n%@",lastKnownLocation);
        
        if (!lastKnowLocationInfo) {
            return;
        }
        
        // Store the location into your sqlite database here
      //  NSLog(@"Retrieved from defaults location info: \n%@ \n Ready for store to database",lastKnowLocationInfo);
        
        
      
        
         
        
        NSTimeInterval timeSinceLastUpload = [_mostRecentUploadDate timeIntervalSinceNow] * -1;
       
        
        
        //envio de peticiones con respecto a la region, revisar casos en LMTrackerRegion
        
            
            [[LMTrackerRegion LMTrackerRegionGetInstance] verificarRegion:lastKnownLocation];
        
       
        
        
        
        //subida de datos al servidor
      //  [self performSelectorOnMainThread:@selector(uploadCurrentData:) withObject:lastKnowLocationInfo waitUntilDone:NO];
       // NSLog(@"posicion conocida en %f,%f",lastKnownLocation.coordinate.latitude,lastKnownLocation.coordinate.longitude);
        
     
         
       
        
        if (timeSinceLastUpload == 0 || timeSinceLastUpload >= self.uploadInterval) {
           // [self uploadCurrentData:lastKnowLocationInfo];
        }
            
        // Close out task Idenetifier on main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            // Send notification for any class that needs to know
            NSNotification *aNotification = [NSNotification notificationWithName:PinLoggerDidSaveNewLocation object:[lastKnownLocation copy]];
            [[NSNotificationCenter defaultCenter] postNotification:aNotification];
            
            if (locationUpdateTaskID != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:locationUpdateTaskID];
                locationUpdateTaskID = UIBackgroundTaskInvalid;
            }
        });
    });
}




-(void)uploadCurrentData: (NSDictionary *)position
{
    
  
    
   
    
    _mostRecentUploadDate = [NSDate date];
  //  NSLog(@"Terminado envio datos al servidor \n");
}



@end

// Notification names
NSString* const PinLoggerDidSaveNewLocation = @"PinLoggerDidSaveNewLocation";