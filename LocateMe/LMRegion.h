//
//  LMRegion.h
//  LocateMe
//
//  Created by mocion on 18/03/13.
//  Copyleft (c) 2013 Dany Bautista. @danyjavierb
// dany.bautista@mocionsoft.com
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LMRegion : NSObject

@property (nonatomic,strong) NSString* nombre;
@property (nonatomic) NSNumber* idDb;
@property  (nonatomic)CLLocationDistance radio;
@property (nonatomic)CLLocationCoordinate2D centro;
@property (nonatomic) CLRegion* regionEntidad;


-(id)initRegionWithidDb:(NSNumber *)elIdDb andRadio:(CLLocationDistance )elRadio andCentro:(CLLocationCoordinate2D )elCentro andNombre:(NSString *)elNombre;

@end

