//


#import <Foundation/Foundation.h>

@interface LMPinTracker : NSObject
@property(nonatomic)NSTimeInterval uploadInterval;
@end

// Notification names
extern NSString *const PinLoggerDidSaveNewLocation;