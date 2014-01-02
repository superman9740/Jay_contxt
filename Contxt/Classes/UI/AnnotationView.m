//
//  AnnotationView.m
//  Contxt
//
//  Created by Chad Morris on 6/8/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "AnnotationView.h"
#import "AnnotationButton.h"
#import "AnnotationUtility.h"

// Domain Model
#import "AnnotationDocument.h"
#import "Annotation.h"
#import "AnnotationPoint.h"
#import "ImageInfo.h"


@implementation AnnotationView

@synthesize photoScrollView , delegate;
@synthesize annotationButtons = _annotationButtons;
@synthesize doc = _doc;


#pragma mark - Buttons

- (void)removeButton:(AnnotationButton *)button
{
    [_annotationButtons removeObject:button];
}

#pragma mark - PZPhotoViewDelegate

- (void)photoViewDidSingleTap:(UIGestureRecognizer *)gestureRecognizer withPhotoView:(PZPhotoView *)photoView
{
    if( self.delegate )
        [self.delegate didTap:gestureRecognizer withPhotoView:photoView];
}

- (void)photoViewDidDoubleTap:(PZPhotoView *)photoView {
    // do nothing
}

- (void)photoViewDidTwoFingerTap:(PZPhotoView *)photoView {
    // do nothing
}

- (void)photoViewDidDoubleTwoFingerTap:(PZPhotoView *)photoView {
    //[self logLayout];
}

- (void)photoViewDidLongPress:(UIGestureRecognizer *)gestureRecognizer withPhotoView:(PZPhotoView *)photoView
{
    if( self.delegate )
        [self.delegate didLongPress:gestureRecognizer withPhotoView:photoView];
}

- (void)photoViewDidScroll:(PZPhotoView *)photoView
{
    [self moveButtonsForZoomOrScroll:photoView];
}

- (void)photoViewDidZoom:(PZPhotoView *)photoView
{
    [self moveButtonsForZoomOrScroll:photoView];
}

#pragma mark - Helper Methods

- (void)moveButtonsForZoomOrScroll:(PZPhotoView *)photoView
{
    for( AnnotationButton * button in _annotationButtons )
    {
        CGFloat scale = photoView.contentSize.height / photoView.frame.size.height;
        CGPoint adjustedPoint = [AnnotationUtility getAdjustedPointForAnnotation:button.annotation
                                                                       frameSize:button.frame.size
                                                                           scale:scale];
        
        CGFloat inverseFactor = 0.f;
        if( [button.annotation.anchorPoint.y floatValue] + button.frame.size.height/2 < 0.0 )
            inverseFactor = button.frame.size.height;

        button.frame = CGRectMake( adjustedPoint.x , adjustedPoint.y + inverseFactor , button.frame.size.width , button.frame.size.height );
        
        button.hidden = NO;
        [photoView addSubview:button];
    }
}


#pragma mark - UIView Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.photoScrollView.bouncesZoom = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
