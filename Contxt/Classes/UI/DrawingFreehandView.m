//
//  DrawingFreehandView.m
//  Contxt
//
//  Created by Chad Morris on 6/19/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "DrawingFreehandView.h"
#import "AnnotationPoint.h"
#import "AnnotationSize.h"

#import "DataController.h"

#define dW self.delta.width
#define dH self.delta.height
#define BRUSH_TRANSPARENCY 0.5

#define PEN_LINE_WIDTH   3
#define BRUSH_LINE_WIDTH 10


@implementation DrawingFreehandView

@synthesize points = _points;


#pragma mark -

- (void)assignAnnotation:(DrawingAnnotation *)oAnnotation initialize:(BOOL)setUpView
{
    self.annotation = oAnnotation;
    
    if( setUpView )
    {
        self.shapeType = (DrawShapeType)[self.annotation.drawingType intValue];
        self.color = [DrawingView shapeColorToUIColor:(ShapeColor)[self.annotation.color intValue]];

        [_points removeAllObjects];
        _points = nil;
        
        for( int i = 0 ; i < self.annotation.customPoints.count ; i++ )
        {
            AnnotationPoint * anPt = (AnnotationPoint *)[self.annotation.customPoints objectAtIndex:i];
            CGPoint point = CGPointMake( [anPt.x floatValue] , [anPt.y floatValue] );
            
            [self updatePoint:point];
        }
        
        [self setNeedsDisplay];
    }
}

- (void)updateAnnotation
{
    self.annotation.drawingType = [NSNumber numberWithInt:(int)self.shapeType];
    self.annotation.color = [NSNumber numberWithInt:(int)[DrawingView uiColorToShapeColor:self.color]];

    NSOrderedSet * set = [self.annotation removeAllCustomPointsObjects];
    for( AnnotationPoint * pt in set )
    {
        [[[DataController sharedController] managedObjectContext] deleteObject:pt];
    }
    
    for( int i = 0 ; i < _points.count ; i++ )
    {
        AnnotationPoint * anPt = [[DataController sharedController] newAnnotationPoint];
        anPt.parentDrawingAnnotation = self.annotation;
        
        CGPoint pt = [[_points objectAtIndex:i] CGPointValue];
        anPt.x = [NSNumber numberWithFloat:pt.x + self.delta.width];
        anPt.y = [NSNumber numberWithFloat:pt.y + self.delta.height];
        
        [self.annotation addCustomPointsObject:anPt];
    }
}


#pragma mark -

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (BOOL)containsPoint:(CGPoint)point
{
    CGPoint min = [self topLeftPoint];
    min.x += self.delta.width;
    min.y += self.delta.height;
    
    CGPoint max = [self bottomRightPoint];
    max.x += self.delta.width;
    max.y += self.delta.height;

    if( point.x >= min.x && point.x <= max.x &&
        point.y >= min.y && point.y <= max.y )
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)containsPoint:(CGPoint)point withAllowableError:(CGFloat)length
{
    CGPoint min = [self topLeftPoint];
    min.x += self.delta.width;
    min.y += self.delta.height;
    
    CGPoint max = [self bottomRightPoint];
    max.x += self.delta.width;
    max.y += self.delta.height;
    
    min.x -= length/2;
    min.y -= length/2;
    max.x += length/2;
    max.y += length/2;
    
    if( point.x >= min.x && point.x <= max.x &&
       point.y >= min.y && point.y <= max.y )
    {
        return YES;
    }
    
    return NO;
}

- (CGPoint)centerPoint
{
    CGPoint min = [self topLeftPoint];
    min.x += self.delta.width;
    min.y += self.delta.height;
    
    CGPoint max = [self bottomRightPoint];
    max.x += self.delta.width;
    max.y += self.delta.height;
    
    return CGPointMake( min.x + (max.x - min.x)/2 , min.y + (max.y - min.y)/2 );
}

- (void)adjustPointsByDistance:(CGSize)distance
{
    NSMutableArray * newPoints = [[NSMutableArray alloc] init];
    
    for( int i = 0; i < [_points count]; i++ )
    {
        CGPoint p = [[_points objectAtIndex:i] CGPointValue];
        p.x += distance.width;
        p.y += distance.height;
        [newPoints addObject:[NSValue valueWithCGPoint:p]];
    }
    
    [_points removeAllObjects];
    [_points arrayByAddingObjectsFromArray:newPoints];
}

- (CGPoint)topLeftPoint
{
    return _min;
}

- (CGPoint)bottomRightPoint
{
    return _max;
}

- (void)createStartPoint:(CGPoint)start
{
    _points = [[NSMutableArray alloc] init];
    [_points addObject:[NSValue valueWithCGPoint:start]];
    self.delta = CGSizeMake( 0 , 0 );
    
    _start.x = 9999;
    _start.y = 9999;
    _end.x = -9999;
    _end.y = -9999;
    
    _min.x = 9999;
    _min.y = 9999;
    _max.x = -9999;
    _max.y = -9999;
}

- (void)updatePoint:(CGPoint)point
{
    if( !_points )
        [self createStartPoint:point];
    else
        [_points addObject:[NSValue valueWithCGPoint:point]];
    
    _start.x = MIN(_start.x , point.x);
    _start.y = MIN(_start.y , point.y);
    _end.x = MAX(_end.x , point.x);
    _end.y = MAX(_end.y , point.y);
    
    _min.x = MIN( _min.x , point.x );
    _min.y = MIN( _min.y , point.y );
    _max.x = MAX( _max.x , point.x );
    _max.y = MAX( _max.y , point.y );
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delta = CGSizeMake( 0 , 0 );
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    CGPoint currentPoint , prevPoint , prevPoint2;
    
    if( !_points || [_points count] <= 0 )
        return;
    
    if( self.isSelected )
        [self drawRectangleOutline];
    
    int i = 0;
    if( [_points count] == 1 )
    {
        i = 1;
        prevPoint2 = prevPoint = currentPoint = [[_points objectAtIndex:0] CGPointValue];
    }
    else if( [_points count] == 2 )
    {
        i = 2;
        prevPoint2 = prevPoint = [[_points objectAtIndex:0] CGPointValue];
        currentPoint = [[_points objectAtIndex:1] CGPointValue];
    }
    else
    {
        i = 3;
        prevPoint2 = [[_points objectAtIndex:0] CGPointValue];
        prevPoint = [[_points objectAtIndex:1] CGPointValue];
        currentPoint = [[_points objectAtIndex:2] CGPointValue];
    }
    
    [self drawWith:currentPoint and:prevPoint and:prevPoint2];
    for( ; i < [_points count] ; i++ )
    {
        prevPoint2 = prevPoint;
        prevPoint = currentPoint;
        currentPoint = [[_points objectAtIndex:i] CGPointValue];
        
        [self drawWith:prevPoint2 and:prevPoint and:currentPoint];
    }
    
    if( self.shapeType == DrawShapeTypeCustomBrush )
        self.alpha = BRUSH_TRANSPARENCY;
}

- (void)drawWith:(CGPoint)currentPoint and:(CGPoint)previousPoint1 and:(CGPoint)previousPoint2
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGPoint mid1 = midPoint(previousPoint1, previousPoint2);
    CGPoint mid2 = midPoint(currentPoint, previousPoint1);
    
    CGContextMoveToPoint(ctx, mid1.x + dW, mid1.y + dH);
    CGContextAddQuadCurveToPoint(ctx, previousPoint1.x + dW, previousPoint1.y + dH, mid2.x + dW, mid2.y + dH);
    
    //could probably modify these settings to add a double stroke
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, (self.shapeType == DrawShapeTypeCustomPen ? PEN_LINE_WIDTH : BRUSH_LINE_WIDTH) );
    float normal[1]={1};
    CGContextSetLineDash(ctx,0,normal,0);

    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.7;
    [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    CGContextSetRGBStrokeColor( ctx , red , green , blue , 1.0 );
    CGContextStrokePath(ctx);
    
    CGContextDrawPath(ctx, kCGPathStroke);
}

- (void)drawRectangleOutline
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint min = [self topLeftPoint];
    CGPoint max = [self bottomRightPoint];
    CGRect myOval = { min.x - 5 + self.delta.width
                    , min.y - 5 + self.delta.height
                    , max.x - min.x + 10
                    , max.y - min.y + 10
                    };
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    
    [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
    CGContextSetRGBFillColor( context , red , green , blue , 0.2 );

    [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
    CGContextSetRGBStrokeColor( context , red , green , blue , 1.0 );
    
    CGFloat dashArray[] = {4};
    CGContextSetLineDash(context, 8, dashArray, 1);
    
    CGContextSetLineCap( context, kCGLineCapButt);
    CGContextSetLineWidth( context , self.strokeWidth/2 );
    
    CGContextStrokeRect(context, myOval);
    CGContextAddRect(context, myOval);
    
    CGContextFillPath(context);
}



@end
