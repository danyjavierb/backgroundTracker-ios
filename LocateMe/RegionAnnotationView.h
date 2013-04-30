//
//  RegionAnnotationView.h
//  BacabTracker
//
//  Created by Mocion Dany on 9/04/13.
//  Copyright (c) 2013 mocionsoft. All rights reserved.
//


#import <MapKit/MapKit.h>

@class RegionAnnotation;



@interface RegionAnnotationView : MKPinAnnotationView {
@private
	MKCircle *radiusOverlay;
	BOOL isRadiusUpdated;
}

@property (nonatomic, assign) MKMapView *map;
@property (nonatomic, assign) RegionAnnotation *theAnnotation;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation;
- (void)updateRadiusOverlay;
- (void)removeRadiusOverlay;

@end