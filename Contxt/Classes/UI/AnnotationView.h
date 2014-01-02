//
//  AnnotationView.h
//  Contxt
//
//  Created by Chad Morris on 6/8/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZPhotoView.h"

@class AnnotationDocument;
@class AnnotationButton;
@protocol AnnotationPinViewDelegate;
@protocol AnnotationDrawingViewDelegate;

@protocol AnnotationViewDelegate <NSObject>

- (void)didLongPress:(UIGestureRecognizer *)gestureRecognizer withPhotoView:(PZPhotoView *)photoView;
- (void)didTap:(UIGestureRecognizer *)gestureRecognizer withPhotoView:(PZPhotoView *)photoView;

@end

@interface AnnotationView : UIView <PZPhotoViewDelegate>
{
    NSMutableArray * _annotationButtons;
    AnnotationDocument * _doc;
}

- (void)removeButton:(AnnotationButton *)button;

@property (nonatomic , readonly) NSMutableArray * annotationButtons;

@property (nonatomic , strong) IBOutlet PZPhotoView * photoScrollView;
@property (nonatomic , strong) AnnotationDocument * doc;
@property (nonatomic , strong) id<AnnotationViewDelegate , AnnotationPinViewDelegate , AnnotationDrawingViewDelegate> delegate;

@end
