//
//  PZPhotoView.h
//  PhotoZoom
//
//  Created by Brennan Stehling on 10/27/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@protocol PZPhotoViewDelegate;

@interface PZPhotoView : TPKeyboardAvoidingScrollView
{
    CGPoint  _pointToCenterAfterResize;
    CGFloat  _scaleToRestoreAfterResize;
    
    UIImage * _image;
    UIImageView * _imageView;

    UILongPressGestureRecognizer * _scrollViewLongPress;
}

- (void)dispose;

@property (strong, nonatomic) UIView *mainView;
@property (assign, nonatomic) id<PZPhotoViewDelegate> photoViewDelegate;
@property (nonatomic) CGFloat longPressDuration;
@property (nonatomic) BOOL contentModeAspectFit;

- (void)prepareForReuse;
- (void)displayImage:(UIImage *)image;

- (void)startWaiting;
- (void)stopWaiting;

- (void)updateZoomScale:(CGFloat)newScale;
- (void)updateZoomScale:(CGFloat)newScale withCenter:(CGPoint)center;

- (UILongPressGestureRecognizer *)addLongPressGestureWithDuration:(CGFloat)duration;
- (void)removeLongPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer;

@end

@protocol PZPhotoViewDelegate <NSObject>

@optional

- (void)photoViewDidSingleTap:(UIGestureRecognizer *)gestureRecognizer withPhotoView:(PZPhotoView *)photoView;
- (void)photoViewDidDoubleTap:(PZPhotoView *)photoView;
- (void)photoViewDidTwoFingerTap:(PZPhotoView *)photoView;
- (void)photoViewDidDoubleTwoFingerTap:(PZPhotoView *)photoView;
- (void)photoViewDidLongPress:(UIGestureRecognizer *)gestureRecognizer withPhotoView:(PZPhotoView *)photoView;
- (void)photoViewDidZoom:(PZPhotoView *)photoView;
- (void)photoViewDidScroll:(PZPhotoView *)photoView;

@end