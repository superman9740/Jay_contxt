//
//  DrawingView.h
//  Contxt
//
//  Created by Chad Morris on 6/13/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingAnnotation.h"

typedef enum DrawShapeType : NSUInteger
{
    DrawShapeTypeUnknown = 0,
    DrawShapeTypeCircle = 1,
    DrawShapeTypeRectangle = 2,
    DrawShapeTypeLine = 3,
    DrawShapeTypeArrow = 4,
    DrawShapeTypeCustomBrush = 5,
    DrawShapeTypeCustomPen = 6,
    DrawShapeTypeText = 7,
    DrawShapeTypeTextLeader = 8,
    DrawShapeTypeDimension = 9
} DrawShapeType;

typedef enum ShapeColor : NSUInteger
{
      ShapeColorRed = 0
    , ShapeColorOrange = 1
    , ShapeColorYellow = 2
    , ShapeColorGreen = 3
    , ShapeColorBlue = 4
    , ShapeColorPurple = 5
    , ShapeColorBlack = 6
    , ShapeColorWhite = 7
} ShapeColor;


@interface DrawingView : UIView <UITextViewDelegate>
{
    BOOL _hasEndPoint;
    CGPoint _start;
    CGPoint _end;
    
    UITextView * _textView;
    BOOL _isSelected;
    CGFloat _fontSize;
    UIColor * _color;
}

@property (nonatomic , strong) NSString * text;
@property (nonatomic) CGFloat fontSize;

@property (nonatomic , strong) DrawingAnnotation * annotation;

@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) CGPoint start;
@property (nonatomic) CGPoint end;
@property (nonatomic , readonly) CGPoint min;
@property (nonatomic , readonly) CGPoint max;

@property (nonatomic , strong) UIColor * color;
@property (nonatomic) DrawShapeType shapeType;
@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isDrawing;

- (CGPoint)centerPoint;
- (BOOL)containsPoint:(CGPoint)point;
- (BOOL)containsPoint:(CGPoint)point withAllowableError:(CGFloat)length;
- (void)createTextView;
- (void)removeTextView;
- (void)enableTextView:(BOOL)enable;
- (void)focusForTextEditing;

- (void)assignAnnotation:(DrawingAnnotation *)oAnnotation initialize:(BOOL)setUpView;
- (void)updateAnnotation;

+ (UIColor *)shapeColorToUIColor:(ShapeColor)color;
+ (ShapeColor)uiColorToShapeColor:(UIColor *)color;

@end
