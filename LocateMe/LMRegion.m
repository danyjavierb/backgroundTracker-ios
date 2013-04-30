//
//  LMRegion.m
//  LocateMe
//
//  Created by mocion on 18/03/13.
//  Copyright (c) 2013 Dean Davids. All rights reserved.
//

#import "LMRegion.h"

@implementation LMRegion

@synthesize nombre;
@synthesize idDb;
@synthesize radio;
@synthesize centro;
@synthesize regionEntidad;


-(id)init {

    
    if(self=[super init]){    
    
    }

    return self;

}



-(id)initRegionWithidDb:(NSNumber *)elIdDb andRadio:(CLLocationDistance )elRadio andCentro:(CLLocationCoordinate2D )elCentro andNombre:(NSString *)elNombre {

    if(self = [super init]){
        
        self.nombre=elNombre;
        self.radio= elRadio;
        self.centro= elCentro;
        self.idDb=elIdDb;
        
        
        
       self.regionEntidad=[[CLRegion alloc] initCircularRegionWithCenter:self.centro radius:self.radio identifier:self.nombre ];
        
       
    
    }

    return self;
}


@end

