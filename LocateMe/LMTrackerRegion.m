//
//  LMTrackerRegion.h
//  LocateMe
//
//  Created by mocion on 18/03/13.
//  Copyleft (c) 2013 Dany bautista. @danyjavierb
//

#import "LMTrackerRegion.h"
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"

#import "FMDatabase.h"
#import "FMResultSet.h"

@implementation LMTrackerRegion

@synthesize regiones;
@synthesize posAnterior;
@synthesize totalRegiones;
@synthesize internetReachable;
@synthesize hostReachable;
@synthesize internetActive;
@synthesize hostActive;
@synthesize anteriorEstado;
@synthesize erroresPeticiones;


-(id)init{
    
    if(self=[super init]){
        
        self.regiones= [[NSMutableArray alloc] init];
        self.totalRegiones=0;
        self.anteriorEstado=NO;
        
        
        // se observa el estado de la conexion
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        
        internetReachable = [Reachability reachabilityForInternetConnection] ;
        [internetReachable startNotifier];
        
        // url de el sitio al que nos interesa llegar siempre
        hostReachable = [Reachability reachabilityWithHostname: @"www.google.com"] ;
        [hostReachable startNotifier];
        
        
        
        // observador activo
        erroresPeticiones = [[NSMutableArray alloc] init];
        
    }
    
    
    return self;
}


-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"se cayo el internet");
            
            
            
            self.anteriorEstado=YES;
            self.internetActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"conectado a WIFI.");
            self.internetActive = YES;
                        
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"conectado a  WWAN.");
            self.internetActive = YES;
            
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
           // NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
           // NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
           // NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            
            break;
        }
    }
}


+ (id)LMTrackerRegionGetInstance {
    static dispatch_once_t pred;
    static LMTrackerRegion *regionTrackerSingleton = nil;
    
    dispatch_once(&pred, ^{
        regionTrackerSingleton = [[LMTrackerRegion alloc] init];
    });
    
    return regionTrackerSingleton;
}

- (CLLocationDistance)distanceBetweenCoordinate:(CLLocationCoordinate2D)originCoordinate andCoordinate:(CLLocationCoordinate2D)destinationCoordinate {
    CLLocation *originLocation = [[CLLocation alloc] initWithLatitude:originCoordinate.latitude longitude:originCoordinate.longitude];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:destinationCoordinate.latitude longitude:destinationCoordinate.longitude];
    CLLocationDistance distance = [originLocation distanceFromLocation:destinationLocation];
    
    
    return distance;
}

-(void) enviarPeticion:(int)codigo withData:(CLLocation* )laPosicion {
    
    NSString * latitud = [NSString stringWithFormat:@"\"longitud\":\"%f\"", laPosicion.coordinate.longitude];
    NSString * longitud = [NSString stringWithFormat:@"\"latitud\":\"%f\"",laPosicion.coordinate.latitude];
     NSString * rumbo = [NSString stringWithFormat:@"\"rumbo\":\"%f\"",laPosicion.course];
    NSString * idmovil = [NSString stringWithFormat:@"\"idmovil\":\"id-to-store-in-database\""];
    
    
    
    
    
    //Se organiza la estructura de la URL para la peticion NSMutableURLRequest or NSURLRequest
    NSMutableURLRequest *request =
    [NSMutableURLRequest
     requestWithURL:[
                     NSURL URLWithString:@"http://RESTAPIURLHERE"
                     ]
     cachePolicy:NSURLRequestUseProtocolCachePolicy
     timeoutInterval:60.0
     ];
    
    
    
    //organizando el cuerpo de la peticion como un json
    
    NSString *params = [[NSString alloc] initWithFormat:@"{%@,%@,%@,%@,%@}",latitud,longitud,idmovil,idevento,rumbo];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Se hace la peticion a la URL organizada
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = [[NSError alloc] init];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    NSString *event = [NSString stringWithFormat:@"Prueba  fecha %@", [NSDate date]];
	
	
    
    
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        //receivedData = [[NSMutableData data] retain];
        
        
        if (self.anteriorEstado==YES && self.internetActive==YES) {
            
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docsPath = [paths objectAtIndex:0];
            NSString *path = [docsPath stringByAppendingPathComponent:@"movil.sqlite"];
            
            FMDatabase *movil = [FMDatabase databaseWithPath:path];
            
            BOOL abrioDb= [movil open];
            if (abrioDb==YES){
                
                NSLog(@"cargada exitosamente base de datos sin conexion para envio al conectar de nuevo");
                
            }
            
            
            
            
            FMResultSet *s = [movil executeQuery:@"SELECT * FROM movil"];
            while ([s next]) {
                double longitud=[s doubleForColumn:@"longitud"];
                double latitud=[s doubleForColumn:@"latitud"];
                double rumbo = [s doubleForColumn:@"rumbo"];
                int idevento = 9;
                
                CLLocation *posicionAlmacenada = [[CLLocation alloc] initWithCoordinate:(CLLocationCoordinate2DMake(latitud, longitud)) altitude:0 horizontalAccuracy:0 verticalAccuracy:0 course:rumbo speed:0 timestamp:0 ];
                  __block BOOL enviado= YES;
                if (enviado){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self enviarPeticion:idevento withData:posicionAlmacenada];
                       enviado = NO;
                        NSLog(@"enviando dato al server despues de conectar");
                   
                    });
                    
                     }
                
            }
            
            [movil executeUpdate:@"delete from movil"];
            [movil close];
            
        
            
            self.anteriorEstado=NO;
            
            
        }
        
        
    
    

        
    
    
    }
    else
    {
    
        self.anteriorEstado=YES;
    
    }
            
}

//delegates nsurl conecction


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  
    if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode >= 400 && statusCode <=600)
        { //errores de coneccion y servidor
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docsPath = [paths objectAtIndex:0];
            NSString *path_errores = [docsPath stringByAppendingPathComponent:@"errores.sqlite"];
            FMDatabase *errores = [FMDatabase databaseWithPath:path_errores];
            BOOL abrioErrores= [errores open];
            if (abrioErrores==YES){
                
                NSLog(@"Base de datos errores creada o cargada exitosamente");
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [errores executeUpdate:@" create table if not exists errores  ( \"error\" varchar(256))" ];
                
                
                NSString *stringFecha;
                NSDate *now = [NSDate date];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
                stringFecha = [dateFormatter stringFromDate:now];
                
                BOOL insertado= [errores executeUpdate:@"insert into  errores (error) values (?)",[NSString stringWithFormat:@"Error : codigo %d fecha: %@ ", statusCode ,stringFecha ],nil ];
                
                
                
                [errores close];
                
                
                
            });
            
        }
        
        
        
        
        
    }
}



- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
        NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
         [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path_errores = [docsPath stringByAppendingPathComponent:@"errores.sqlite"];
    FMDatabase *errores = [FMDatabase databaseWithPath:path_errores];
    BOOL abrioErrores= [errores open];
    if (abrioErrores==YES){
        
        NSLog(@"Base de datos errores creada o cargada exitosamente");
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        [errores executeUpdate:@" create table if not exists errores  ( \"error\" varchar(256))" ];

        NSString *stringFecha;
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
        stringFecha = [dateFormatter stringFromDate:now];
        
        
        
        BOOL insertado= [errores executeUpdate:@"insert into  errores (error) values (?)",[NSString stringWithFormat:@"Error : %@  ,  %@ fecha: %@ ",  [error localizedDescription] , [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey], stringFecha],nil ];
        
        
        
        [errores close];
        
             
        
    });
     
    NSString *path = [docsPath stringByAppendingPathComponent:@"movil.sqlite"];
    
    FMDatabase *movil = [FMDatabase databaseWithPath:path];
    
    BOOL abrioDb= [movil open];
    if (abrioDb==YES){
        
        NSLog(@"Base de datos creada o cargada exitosamente");
        
    }
    __block BOOL insertadoDb = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (insertadoDb){
        
        [movil executeUpdate:@" create table if not exists movil  ( \n"
         "\"idmovil\" varchar(22),\n"
         " \"receiverstatus\" varchar(1),\n"
         "\"longitud\" float8,\n"
         "\"latitud\" float8,\n"
         "\"velocidad\" float4,\n"
         "\"fechahora\" timestamp(6) NULL,\n"
         "\"altitud\" float4,\n"
         "\"fechasystem\" timestamp(6) NOT NULL,\n"
         "\"rumbo\" varchar(10),\n"
         "\"motivo\" char(10),\n"
         "\"procesado\" char(1),\n"
         "\"estado\" int2,\n"
         "\"gpsapiheader\" varchar(6),\n"
         "\"nmeagptype\" varchar(8),\n"
         "\"datetimeofsigfix\" timestamp(6) NULL,\n"
         "\"magvariation\" float4,\n"
         "\"signalfixkind\" char(2),\n"
         "\"gpio\" char(6),\n"
         "\"rawmessage\" bytea,\n"
         "\"messagelength\" int4,\n"
         "\"inputevent\" varchar(32),\n"
         "\"outputevent\" varchar(32),\n"
         "\"idevento\" int2 \n"
         ") " ];
        
        
        NSDate *myDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        
        NSString *GMTDateString = [dateFormatter stringFromDate: myDate];
        
        
        
        BOOL insertado= [movil executeUpdate:@"insert into  movil (idmovil,longitud,latitud,idevento,fechasystem,rumbo) values (?,?,?,?,?,?)",@"dev",[NSNumber numberWithDouble: self.posAnterior.coordinate.longitude],[NSNumber numberWithDouble: self.posAnterior.coordinate.latitude], [NSNumber numberWithInt:9],GMTDateString,[NSString stringWithFormat:@"%f", posAnterior.course ],nil ];
        // testeo almacenamiento
        NSLog(@"insert data offline, %f,%f", self.posAnterior.coordinate.latitude ,self.posAnterior.coordinate.longitude);
        
            
            NSLog(@"Error %d: %@", [movil lastErrorCode], [movil lastErrorMessage]);
        
        [movil close];
    
            insertadoDb = NO;
        }
        
    
    });

    
    
}

- (NSMutableArray *) getErrores {

    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"errores.sqlite"];
    
    FMDatabase *errores = [FMDatabase databaseWithPath:path];
    
    BOOL abrioDb= [errores open];
    if (abrioDb==YES){
        
        NSLog(@"cargada exitosamente base de datos errores");
        
    }
    
    //vaciar el arreglo o se copiaran los mismos datos al arreglo existente
    [self.erroresPeticiones removeAllObjects];
    
    FMResultSet *s = [errores executeQuery:@"SELECT * FROM errores"];
    while ([s next]) {
        NSString* error=[s stringForColumn:@"error"];
        [self.erroresPeticiones insertObject:error atIndex:0 ];
    }
    
    [errores close];
    
    
    return self.erroresPeticiones;
    

}


-(void)  deleteErroresDb {



    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"errores.sqlite"];
    
    FMDatabase *errores = [FMDatabase databaseWithPath:path];
    
    BOOL abrioDb= [errores open];
    if (abrioDb==YES){
        
        NSLog(@"cargada exitosamente base de datos errores");
        
    }
    
    
    
    //vaciar el arreglo o se copiaran los mismos datos al arreglo existente
   
   
    
    [errores executeUpdate:@"delete from errores"];
    [self.erroresPeticiones removeAllObjects];
    
    [errores close];
    
 

}


-(void)generarNotificacion: (int) tipo withPosicion:(CLLocation*)laPosicion{
    
    
    if (tipo == 1){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [self enviarPeticion:25 withData:laPosicion];
        });
    
    
    }
    
    if(tipo == 2){
    
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self enviarPeticion:26 withData:laPosicion];
        });
    
    
    
    
    }
    
    if(tipo == 3){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self enviarPeticion:9 withData:laPosicion];
        });
        
        
     
        
        
    }
    
        
}


-(void) agregarRegion:(LMRegion*)regionNueva {
    [self.regiones addObject:regionNueva.regionEntidad];
    self.totalRegiones++;
    
    
}
-(void) eliminarRegion:(LMRegion*)region {
    
    [regiones removeObject:region.regionEntidad];
    
    
}

-(void) verificarRegion:(CLLocation*)punto {
    
    
    
    if (self.totalRegiones==0){
    
        [self generarNotificacion:3 withPosicion:punto];
          self.posAnterior = punto;
    
    
    }
    else{
    
        NSLog(@"tamaño regiones agregadas %d",[self.regiones count]);
    
        for (CLRegion *theRegion in self.regiones) {
        
        NSLog(@"centro region analizada en %f,%f",theRegion.center.latitude,theRegion.center.longitude);
        
        BOOL puntoNuevoEnRegion = [theRegion containsCoordinate:punto.coordinate ];
        BOOL puntoAnteriorEnRegion = [theRegion containsCoordinate:self.posAnterior.coordinate ];
        
        
        //CLLocationDistance distancia = [self distanceBetweenCoordinate:punto andCoordinate:theRegion.center];
        
        if ( self.posAnterior.coordinate.longitude==0 && self.posAnterior.coordinate.latitude==0) {
            self.posAnterior = punto;
            
        }
        
        else{
            
            if((puntoAnteriorEnRegion==YES && puntoNuevoEnRegion==YES) || (puntoAnteriorEnRegion==NO && puntoNuevoEnRegion==NO) ){
                
                self.posAnterior = punto;
                
                 [self generarNotificacion:3 withPosicion:punto];
                
            }
            
            
            //entro a una region cual? @juan
            if(puntoAnteriorEnRegion==NO && puntoNuevoEnRegion==YES){
                
                 self.posAnterior = punto;
                [self generarNotificacion:1 withPosicion:punto];
                
               
                
                
            }
            
            //salio de una region cual? @juan
            
            if(puntoAnteriorEnRegion==YES && puntoNuevoEnRegion==NO){
                 self.posAnterior = punto;
                NSLog(@"Salio de region puesta en el punto con centro %f,%f",theRegion.center.latitude,theRegion.center.longitude);
                [self generarNotificacion:2 withPosicion:punto];
                
               
                
                
            }
            
        }
        
        
        
    }
    
    }
    
    
}






@end
