//
//  MagnifierView.m
//  SimplerMaskTest
//

#import "MagnifierView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MagnifierView
@synthesize viewToMagnify;
@dynamic touchPoint;
@synthesize magnificationPoint;

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame radius:118];
}

- (id)initWithFrame:(CGRect)frame radius:(int)r {
    int radius = r;
    
    if ((self = [super initWithFrame:CGRectMake(0, 0, radius, radius)])) {
        //Make the layer circular.
        self.layer.cornerRadius = radius / 2;
        self.layer.masksToBounds = YES;
    }
    
    return self;
}

- (void)setTouchPoint:(CGPoint)pt {
    touchPoint = pt;
    // whenever touchPoint is set, update the position of the magnifier (to just above what's being magnified)

    
    CGFloat touchOffset = (self.bounds.size.height / 2);
    
    CGFloat xOffset = 0;
    CGFloat yOffset = 0;
    
    CGFloat yVariance = pt.y - self.bounds.size.height;
    
    CGFloat xVariance = 0;
    
    if( pt.x <= touchOffset )
        xVariance = pt.x - touchOffset;
    else if( pt.x + touchOffset > self.superview.bounds.size.width )
        xVariance = (pt.x + touchOffset) - self.superview.bounds.size.width;
    
    // Start with left / right adjustment
    if( pt.x <= touchOffset || pt.x + touchOffset > self.superview.bounds.size.width )
    {
        if( yVariance >= 0 )
        {
            yOffset = touchOffset;
        }
        else
        {
            yOffset = pt.y - self.bounds.size.height + touchOffset;

            if( pt.x <= touchOffset )
                xVariance = MAX( xVariance + yVariance , -2 * touchOffset );
            else if( pt.x + touchOffset > self.superview.bounds.size.width )
                xVariance = MIN( xVariance - yVariance , 2 * touchOffset );
        }
        
        xOffset = xVariance;
    }
    else if( yVariance <= 0 )
    {
        yOffset = pt.y - self.bounds.size.height + touchOffset;
        
        if( pt.x <= self.superview.bounds.size.width /2 )
        {
            // TOUCH IS ON LEFT HALF OF SCREEN
            //   So...move me right
            xOffset = MAX( xVariance + yVariance , -2 * touchOffset );
        }
        else
        {
            // TOUCH IS ON RIGHT HALF OF SCREEN
            //   So...move me left
            xOffset = MIN( xVariance - yVariance , 2 * touchOffset );
        }
    }
    else
    {
        yOffset = touchOffset;
    }

    self.center = CGPointMake( pt.x - xOffset , pt.y - yOffset );
}

- (CGPoint)getTouchPoint {
    return touchPoint;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    CGImageRef mask = [UIImage imageNamed: @"loupe-mask@2x.png"].CGImage;
    UIImage *glass = [UIImage imageNamed: @"loupe-hi_target@2x.png"];
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, bounds, mask);
    CGContextFillRect(context, bounds);
    CGContextScaleCTM(context, 1.2, 1.2);
    
    //draw your subject view here
    CGContextTranslateCTM(context,1*(self.frame.size.width*0.5),1*(self.frame.size.height*0.5));
    //CGContextScaleCTM(context, 1.5, 1.5);
//    CGContextTranslateCTM(context,-1*(touchPoint.x),-1*(touchPoint.y));
    
    CGContextTranslateCTM(context,-1*(magnificationPoint.x),-1*(magnificationPoint.y));
    
    [self.viewToMagnify.layer renderInContext:context];
    
    CGContextRestoreGState(context);
    [glass drawInRect: bounds];
}

- (void)dealloc {
    [viewToMagnify release];
    [super dealloc];
}


@end