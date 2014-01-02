//
//  DrawingView.m
//  Contxt
//
//  Created by Chad Morris on 6/13/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "DrawingView.h"
#import "AnnotationSize.h"
#import "AnnotationPoint.h"
#import "UIBezierPath+dqd_arrowhead.h"
#import "DataController.h"
#import "Utilities.h"

@implementation DrawingView

@synthesize annotation, shapeType , strokeWidth;
@synthesize start = _start;
@synthesize end = _end;
@synthesize originalFrame;
@synthesize isSelected = _isSelected;
@synthesize isDrawing;
@synthesize text;
@synthesize fontSize = _fontSize;
@synthesize color = _color;


#pragma - Color Conversions

+ (UIColor *)shapeColorToUIColor:(ShapeColor)color
{
    switch( color )
    {
        case ShapeColorBlack:  return [UIColor blackColor];
        case ShapeColorPurple: return [UIColor purpleColor];
        case ShapeColorBlue:   return [UIColor blueColor];
        case ShapeColorGreen:  return [UIColor greenColor];
        case ShapeColorYellow: return [UIColor yellowColor];
        case ShapeColorOrange: return [UIColor orangeColor];
        case ShapeColorRed:    return [UIColor redColor];
        case ShapeColorWhite:  return [Utilities lightGrayColor];
        default:               return [UIColor greenColor];
    }
}

+ (ShapeColor)uiColorToShapeColor:(UIColor *)color
{
    if( [color isEqual:[UIColor blackColor]] || [color isEqual:[UIColor darkGrayColor]]  )
        return ShapeColorBlack;
    
    if( [color isEqual:[UIColor purpleColor]] )
        return ShapeColorPurple;
    
    if( [color isEqual:[UIColor blueColor]] )
        return ShapeColorBlue;
    
    if( [color isEqual:[UIColor greenColor]] )
        return ShapeColorGreen;
    
    if( [color isEqual:[UIColor yellowColor]] )
        return ShapeColorYellow;
    
    if( [color isEqual:[UIColor orangeColor]] )
        return ShapeColorOrange;
    
    if( [color isEqual:[UIColor redColor]] )
        return ShapeColorRed;
    
    return ShapeColorWhite;
}


#pragma - UITextViewDelegate Methods

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    self.text = textView.text;
    self.annotation.text = self.text;
    self.userInteractionEnabled = YES;
    [[DataController sharedController] saveContext];
    
    return YES;
}

- (void)setIsSelected:(BOOL)bIsSelected;
{
    _isSelected = bIsSelected;
    
    if( _textView )
        _textView.editable = bIsSelected;
}

- (void)setFontSize:(CGFloat)aFontSize
{
    _fontSize = aFontSize;
    
    if( _textView )
    {
        _textView.font = [UIFont fontWithName:@"ArialMT" size:_fontSize];
        self.annotation.fontSize = [NSNumber numberWithInt:(int)_fontSize];
        [[DataController sharedController] saveContext];
    }
}

- (void)setColor:(UIColor *)aColor
{
    _color = aColor;
    
    if( _textView )
        _textView.textColor = _color;
}

- (CGPoint)min
{
    return CGPointMake( MIN(_start.x , _end.x) , MIN(_start.y , _end.y ) );
}

- (CGPoint)max
{
    return CGPointMake( MAX(_start.x , _end.x) , MAX(_start.y , _end.y ) );
}

- (CGPoint)centerPoint
{
    CGPoint min = self.min;
    CGPoint max = self.max;
    
    return CGPointMake( min.x + (max.x - min.x)/2 , min.y + (max.y - min.y)/2 );
}

- (BOOL)containsPoint:(CGPoint)point
{
    CGPoint min = self.min;
    CGPoint max = self.max;
    
    CGFloat xDelta = max.x - min.x;
    CGFloat yDelta = max.y - min.y;
    
    if( xDelta < 20 )
    {
        min.x -= ( (20-xDelta) / 2 );
        max.x += ( (20-xDelta) / 2 );
    }
    
    if( yDelta < 20 )
    {
        min.y -= ( (20-yDelta) / 2 );
        max.y += ( (20-yDelta) / 2 );
    }
    
    
    if( point.x >= min.x && point.x <= max.x &&
        point.y >= min.y && point.y <= max.y )
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)containsPoint:(CGPoint)point withAllowableError:(CGFloat)length
{
    CGPoint min = self.min;
    CGPoint max = self.max;
    
    CGFloat xDelta = max.x - min.x;
    CGFloat yDelta = max.y - min.y;
    
    if( xDelta < 20 )
    {
        min.x -= ( (20-xDelta) / 2 );
        max.x += ( (20-xDelta) / 2 );
    }
    
    if( yDelta < 20 )
    {
        min.y -= ( (20-yDelta) / 2 );
        max.y += ( (20-yDelta) / 2 );
    }
    
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



- (void)setStart:(CGPoint)startPoint
{
    _start = CGPointMake( startPoint.x , startPoint.y );
    _hasEndPoint = FALSE;
}

- (void)setEnd:(CGPoint)endPoint
{
    _end = CGPointMake( endPoint.x , endPoint.y );
    _hasEndPoint = TRUE;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        self.color = [UIColor greenColor];
        self.strokeWidth = 3;
        _hasEndPoint = FALSE;
        self.isSelected = FALSE;
        self.text = nil;
        self.fontSize = 30;
    }
    return self;
}

- (void)assignAnnotation:(DrawingAnnotation *)oAnnotation initialize:(BOOL)setUpView
{
    self.annotation = oAnnotation;

    if( setUpView )
    {
        self.start = CGPointMake( [self.annotation.anchorPoint.x floatValue] , [self.annotation.anchorPoint.y floatValue] );
        self.end = CGPointMake( self.start.x + [self.annotation.size.width floatValue] , self.start.y + [self.annotation.size.height floatValue] );
        self.shapeType = (DrawShapeType)[self.annotation.drawingType intValue];
        
        if( self.shapeType == DrawShapeTypeText && self.annotation.text && [self.annotation.text length] > 0 )
        {
            self.text = [NSString stringWithString:self.annotation.text];
            self.fontSize = [self.annotation.fontSize integerValue];
        }
        
        self.color = [DrawingView shapeColorToUIColor:(ShapeColor)[self.annotation.color intValue]];
        [self setNeedsDisplay];
    }
}

- (void)updateAnnotation
{
    self.annotation.anchorPoint.x = [NSNumber numberWithFloat:self.start.x];
    self.annotation.anchorPoint.y = [NSNumber numberWithFloat:self.start.y];
    self.annotation.size.width = [NSNumber numberWithFloat:(self.end.x - self.start.x)];
    self.annotation.size.height = [NSNumber numberWithFloat:(self.end.y - self.start.y)];
    self.annotation.drawingType = [NSNumber numberWithInt:(int)self.shapeType];
    
    if( self.shapeType == DrawShapeTypeText && self.text && [self.text length] > 0 )
        self.annotation.text = self.text;
    
    self.annotation.color = [NSNumber numberWithInt:(int)[DrawingView uiColorToShapeColor:self.color]];
}

- (void)focusForTextEditing
{
    [_textView becomeFirstResponder];
}

- (void)removeTextView
{
    if( _textView )
    {
        [_textView removeFromSuperview];
        _textView = nil;
    }
}

- (void)createTextView
{
    CGFloat TEXT_ADJUST_HORIZ = 6;
    CGFloat TEXT_ADJUST_VERT = 8;
    
    CGRect frame = CGRectMake( _start.x - TEXT_ADJUST_HORIZ
                              , _start.y - TEXT_ADJUST_VERT
                              , TEXT_ADJUST_HORIZ + _end.x - _start.x
                              , TEXT_ADJUST_VERT  + _end.y - _start.y );
    
    if( !_textView )
        _textView = [[UITextView alloc] initWithFrame:frame];
    else
        _textView.frame = frame;

    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.keyboardAppearance = UIKeyboardAppearanceAlert;
    _textView.font = [UIFont fontWithName:@"ArialMT" size:self.fontSize];
    _textView.textColor = self.color;
    _textView.delegate = self;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.editable = NO;
    _textView.scrollEnabled = NO;

    if( self.text && [self.text length] > 0 )
        _textView.text = self.text;
    
    [self addSubview:_textView];
    [self bringSubviewToFront:_textView];
}

- (void)enableTextView:(BOOL)enable
{
    if( !_textView )
        return;
    
    if( enable )
    {
        _textView.editable = YES;
        self.userInteractionEnabled = NO;
        [self focusForTextEditing];
    }
    else
    {
        [self textViewShouldEndEditing:_textView];
        _textView.editable = NO;
    }
}

- (void)drawRect:(CGRect)rect
{
    if( self.shapeType != DrawShapeTypeCustomBrush &&
        self.shapeType != DrawShapeTypeCustomPen   &&
        _hasEndPoint )
    {
        [self removeTextView];

        if( self.shapeType == DrawShapeTypeText )
            self.strokeWidth = 2.0;
        
        CGRect myRect = { self.start.x , self.start.y , self.end.x - self.start.x , self.end.y - self.start.y };
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
        [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
        
        CGFloat alphaStroke = 0.9;
        alpha = 0.0;

        if( self.shapeType == DrawShapeTypeText )
        {
            if( self.isDrawing || self.isSelected )
            {
                alpha = 0.2; // Draw a little bit of a background when it's selected or in the middle of drawing
            }
            else
            {
                alphaStroke = 0.0;
            }
        }

        CGContextSetRGBFillColor( context , red , green , blue , alpha );
        CGContextSetRGBStrokeColor( context , red , green , blue , alphaStroke );
        
        if( self.isSelected && self.shapeType != DrawShapeTypeArrow && self.shapeType != DrawShapeTypeDimension && self.shapeType != DrawShapeTypeLine )
        {
            CGFloat dashArray[] = {3};
            CGContextSetLineDash( context , 1 , dashArray , 1 );
        }
        
        CGContextSetLineWidth( context , self.strokeWidth );

        if( self.shapeType == DrawShapeTypeRectangle || self.shapeType == DrawShapeTypeText )
        {
            CGContextStrokeRect( context , myRect );
            CGContextAddRect( context , myRect );
        }
        else if( self.shapeType == DrawShapeTypeCircle )
        {
            CGContextStrokeEllipseInRect( context , myRect );
            CGContextAddEllipseInRect( context , myRect );
        }
        else if( self.shapeType == DrawShapeTypeLine )
        {
            CGContextBeginPath( context );
            CGContextMoveToPoint( context , self.start.x , self.start.y );
            CGContextAddLineToPoint( context , self.end.x , self.end.y );
            CGContextStrokePath( context );

            if( self.isSelected )
                [self drawRectangleOutline];
            
            return;
        }
        else if( self.shapeType == DrawShapeTypeDimension )
        {
            CGContextBeginPath( context );
            CGContextMoveToPoint( context , self.start.x , self.start.y );
            CGContextAddLineToPoint( context , self.end.x , self.end.y );
            CGContextStrokePath( context );
            
            CGPoint p = CGPointMake(self.start.x, self.start.y);
            CGPoint p1 = CGPointMake(self.end.x, self.end.y);
            
            // Vector from p to p1;
            CGPoint diff = CGPointMake(p1.x - p.x, p1.y - p.y);
            
            // Distance from p to p1:
            CGFloat length = hypotf(diff.x, diff.y);
            
            // Normalize difference vector to length 1:
            diff.x /= length;
            diff.y /= length;
            
            // Compute perpendicular vector:
            CGPoint perp = CGPointMake(-diff.y, diff.x);

            CGFloat markLength = 7.0; // Whatever you need ...
            CGPoint a = CGPointMake(p.x + perp.x * markLength/2, p.y + perp.y * markLength/2);
            CGPoint b = CGPointMake(p.x - perp.x * markLength/2, p.y - perp.y * markLength/2);

            CGContextBeginPath( context );
            CGContextMoveToPoint(context, a.x, a.y);
            CGContextAddLineToPoint(context, b.x, b.y);
            CGContextStrokePath( context );

            a = CGPointMake(p1.x + perp.x * markLength/2, p1.y + perp.y * markLength/2);
            b = CGPointMake(p1.x - perp.x * markLength/2, p1.y - perp.y * markLength/2);

            CGContextBeginPath( context );
            CGContextMoveToPoint(context, a.x, a.y);
            CGContextAddLineToPoint(context, b.x, b.y);
            CGContextStrokePath(context);
            
            if( self.isSelected )
                [self drawRectangleOutline];
            
            return;
        }
        else if( self.shapeType == DrawShapeTypeArrow )
        {
            CGFloat tailWidth = 1;
            CGFloat headWidth = 8;
            CGFloat headLength = 8;
            UIBezierPath * path = [UIBezierPath dqd_bezierPathWithArrowFromPoint:self.end
                                                                         toPoint:self.start
                                                                       tailWidth:tailWidth
                                                                       headWidth:headWidth
                                                                      headLength:headLength];
            [path setLineWidth:self.strokeWidth];

            [self.color setStroke];
            [self.color setFill];
            [path stroke];
            [path fill];
            
            if( self.isSelected )
                [self drawRectangleOutline];
            
            return;
        }
        
        CGContextFillPath( context );

        if( self.shapeType == DrawShapeTypeText )
            [self createTextView];
    }
}

- (void)drawRectangleOutline
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint min = CGPointMake( MIN( _start.x , _end.x ) , MIN( _start.y , _end.y ) );
    CGPoint max = CGPointMake( MAX( _start.x , _end.x ) , MAX( _start.y , _end.y ) );
    CGRect myOval = { min.x - 5
                    , min.y - 5
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
