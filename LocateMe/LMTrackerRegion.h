//
//  LMTrackerRegion.h
//  LocateMe
//
//  Created by mocion on 18/03/13.
//  Copyleft (c) 2013 Dany bautista. @danyjavierb 
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LMRegion.h"


@class Reachability;

@interface LMTrackerRegion : NSObject

@property (nonatomic) Reachability* internetReachable;
@property (nonatomic) Reachability* hostReachable;

@property (nonatomic) NSMutableArray* regiones;

@property (nonatomic) CLLocation* posAnterior;

@property (nonatomic) int totalRegiones;

@property (nonatomic)BOOL internetActive;
@property (nonatomic)BOOL anteriorEstado;

@property (nonatomic)BOOL hostActive;

@property(nonatomic) NSMutableArray* erroresPeticiones;


-(void) agregarRegion:(LMRegion*)regionNueva;

-(void) eliminarRegion:(LMRegion*)region;

-(void) verificarRegion:( CLLocation*)punto ;

//verificar la coneccion a internet para decidir sobre la subida de datos

-(void) checkNetworkStatus:(NSNotification *)notice;

//metodos de la clase
- (CLLocationDistance)distanceBetweenCoordinate:(CLLocationCoordinate2D)originCoordinate andCoordinate:(CLLocationCoordinate2D)destinationCoordinate;

-(void) enviarPeticion:(int)codigo withData:(CLLocation*)laPosicion;

-(void)generarNotificacion: (int) tipo withPosicion:(CLLocation*)laPosicion;

//traer errores

- (NSMutableArray* ) getErrores ;
-(void) deleteErroresDb;

+ (id)LMTrackerRegionGetInstance;
@end
