#import "PbDoubleTapGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface PbDoubleTapGestureRecognizer ()
@property (nonatomic) int tapCount;
@property (nonatomic) NSTimeInterval startTimestamp;
@end

@implementation PbDoubleTapGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        _maximumDoubleTapDuration = 0.3f; // assign default value
    }
    return self;
}

-(void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)reset {
    [super reset];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    self.tapCount = 0;
    self.startTimestamp = 0.f;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (touches.count != 1 ) {
        self.state = UIGestureRecognizerStateFailed;
    } else {
        if (self.tapCount == 0) {
            self.startTimestamp = event.timestamp;
            [self performSelector:@selector(timeoutMethod) withObject:self afterDelay:self.maximumDoubleTapDuration];
        }
        self.tapCount++;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (self.tapCount > 2) {
        self.state = UIGestureRecognizerStateFailed;
    } else if (self.tapCount == 2 && event.timestamp < self.startTimestamp + self.maximumDoubleTapDuration) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        NSLog(@"Recognized in %f", event.timestamp - self.startTimestamp);
        self.state = UIGestureRecognizerStateRecognized;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.state = UIGestureRecognizerStateFailed;
}

- (void)timeoutMethod {
    self.state = UIGestureRecognizerStateFailed;
}

@end
