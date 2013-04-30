//
//  RegionAnnotation.h
//  BacabTracker
//
//  Created by Mocion Dany on 9/04/13.
//  Copyright (c) 2013 mocionsoft. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface RegionAnnotation : NSObject <MKAnnotation> {
    
}

@property (nonatomic, retain) CLRegion *region;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite) CLLocationDistance radius;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;

- (id)initWithCLRegion:(CLRegion *)newRegion;

@end