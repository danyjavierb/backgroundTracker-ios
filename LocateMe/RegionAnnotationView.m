//
//  RegionAnnotationView.m
//  BacabTracker
//
//  Created by Mocion Dany on 9/04/13.
//  Copyright (c) 2013 mocionsoft. All rights reserved.
//

#import "RegionAnnotationView.h"
#import "RegionAnnotation.h"

@implementation RegionAnnotationView

@synthesize map, theAnnotation;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation {
	self = [super initWithAnnotation:annotation reuseIdentifier:[annotation title]];
	
	if (self) {
		self.canShowCallout	= YES;
		self.multipleTouchEnabled = NO;
		self.draggable = NO;
		self.animatesDrop = NO;
		self.map = nil;
		theAnnotation = (RegionAnnotation *)annotation;
		self.pinColor = MKPinAnnotationColorGreen;
		radiusOverlay = [MKCircle circleWithCenterCoordinate:theAnnotation.coordinate radius:theAnnotation.radius];
		
		[map addOverlay:radiusOverlay];
	}
	
	return self;
}


- (void)removeRadiusOverlay {
	// Find the overlay for this annotation view and remove it if it has the same coordinates.
	for (id overlay in [map overlays]) {
		if ([overlay isKindOfClass:[MKCircle class]]) {
			MKCircle *circleOverlay = (MKCircle *)overlay;
			CLLocationCoordinate2D coord = circleOverlay.coordinate;
			
			if (coord.latitude == theAnnotation.coordinate.latitude && coord.longitude == theAnnotation.coordinate.longitude) {
				[map removeOverlay:overlay];
			}
		}
	}
	
	isRadiusUpdated = NO;
}


- (void)updateRadiusOverlay {
	if (!isRadiusUpdated) {
		isRadiusUpdated = YES;
		
		[self removeRadiusOverlay];
		
		self.canShowCallout = NO;
		
		[map addOverlay:[MKCircle circleWithCenterCoordinate:theAnnotation.coordinate radius:theAnnotation.radius]];
		
		self.canShowCallout = YES;
	}
}


- (void)dealloc {
	
}


@end
