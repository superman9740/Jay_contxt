//
//  AnnotationUtility.h
//  Contxt
//
//  Created by Chad Morris on 6/8/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PZPhotoView;
@class Annotation;

@interface AnnotationUtility : NSObject

// Points and Scale Helper Methods
+ (CGPoint)adjustPoint:(CGPoint)point forCenteringImage:(UIImage *)image;
+ (CGPoint)adjustPoint:(CGPoint)point forCenteringView:(UIView *)view;
+ (CGPoint)getAdjustedPointFor:(CGPoint)point scale:(CGFloat)scale;
+ (CGPoint)getAdjustedPointFor:(CGPoint)point frameSize:(CGSize)size scale:(CGFloat)scale;
+ (CGPoint)getAdjustedPointForAnnotation:(Annotation *)annotation frameSize:(CGSize)size scale:(CGFloat)scale;
+ (CGPoint)getPointAtNormalScaleForScaledPoint:(CGPoint)pt inView:(PZPhotoView *)view;

@end
