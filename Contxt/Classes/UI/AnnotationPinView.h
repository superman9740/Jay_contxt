//
//  AnnotationPinView.h
//  Contxt
//
//  Created by Chad Morris on 6/8/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnotationView.h"

@class Annotation;
@class ImageAnnotation;
@class ConvoAnnotation;

@protocol AnnotationPinViewDelegate <NSObject>
    @optional
    - (void)didTouchImageAnnotation:(ImageAnnotation *)annotation;
    - (void)didTouchConvoAnnotation:(ConvoAnnotation *)annotation;
@end


@interface AnnotationPinView : AnnotationView

- (id)init;
- (AnnotationButton *)addAnnotationPinButton:(Annotation *)annotation;
- (Annotation *)createAnnotation:(NSString *)annotationType forSource:(NSString *)source atTouchPoint:(CGPoint)touchPoint;
- (void)createAndTouchAnnotationButton:(Annotation *)annotation;
- (void)setDoc:(AnnotationDocument *)doc;
- (void)initializePins;
- (void)annotionPinButtonTouched:(id)button;

@end
