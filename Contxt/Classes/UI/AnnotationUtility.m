//
//  AnnotationUtility.m
//  Contxt
//
//  Created by Chad Morris on 6/8/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "AnnotationUtility.h"
#import "Annotation.h"
#import "PZPhotoView.h"
#import "AnnotationPoint.h"

@implementation AnnotationUtility


#pragma mark - Points and Scale Helper Methods

+ (CGPoint)getPointAtNormalScaleForScaledPoint:(CGPoint)pt inView:(PZPhotoView *)view
{
    CGFloat calculatedScale = view.contentSize.height / view.frame.size.height;
    
    return CGPointMake( pt.x / calculatedScale , pt.y / calculatedScale );
}

+ (CGPoint)adjustPoint:(CGPoint)point forCenteringImage:(UIImage *)image
{
    point.x = point.x - image.size.width / 2;
    point.y = point.y - image.size.height;
    
    return CGPointMake( point.x , point.y );
}

+ (CGPoint)adjustPoint:(CGPoint)point forCenteringView:(UIView *)view
{
    if( (point.x - view.frame.size.width / 2) > 0 )
        point.x = point.x - view.frame.size.width / 2;
    
    if( (point.y - view.frame.size.height / 2) > 0 )
        point.y = point.y - view.frame.size.height / 2;
    
    return CGPointMake( point.x , point.y );
}

+ (CGPoint)getAdjustedPointFor:(CGPoint)point frameSize:(CGSize)size scale:(CGFloat)scale
{
    CGFloat factorX = (size.width/2) * (scale-1);
    CGFloat factorY = size.height * (scale-1);
    
    CGFloat x = (point.x * scale) + factorX;
    CGFloat y = (point.y * scale) + factorY;

    return CGPointMake( x , y );
}

+ (CGPoint)getAdjustedPointFor:(CGPoint)point scale:(CGFloat)scale
{
    CGFloat x = (point.x * scale);
    CGFloat y = (point.y * scale);
    
    return CGPointMake( x , y );
}

+ (CGPoint)getAdjustedPointForAnnotation:(Annotation *)annotation frameSize:(CGSize)size scale:(CGFloat)scale
{
    return [AnnotationUtility getAdjustedPointFor:CGPointMake([annotation.anchorPoint.x floatValue], [annotation.anchorPoint.y floatValue])
                                        frameSize:size
                                            scale:scale];
}


@end
