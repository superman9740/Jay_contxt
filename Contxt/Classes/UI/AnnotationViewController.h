//
//  AnnotationViewController.h
//  Contxt
//
//  Created by Chad Morris on 5/8/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZPhotoView.h"
#import "ShareView.h"

#import "MBProgressHUD.h"
#import "MagnifierView.h"
#import "SMPageControl.h"

#import "AnnotationObserver.h"
#import "DataChangeObserver.h"
#import "ServerCommsObserver.h"

#import "KxMenu.h"

@class Annotation;
@class AnnotationDocument;
@class AnnotationPinView;
@class AnnotationDrawingView;
@class DejalActivityView;

@interface AnnotationViewController : UIViewController < UINavigationControllerDelegate
                                                       , UIImagePickerControllerDelegate
                                                       , KxMenuViewDelegate
                                                       , AnnotationObserver
                                                       , DataChangeObserver
                                                       , ServerCommsObserver
                                                       , MBProgressHUDDelegate>
{
    CGPoint _capturedLongPressPoint;
    UIGestureRecognizer * _capturedLongPressGesture;
    PZPhotoView * _capturedLongPressView;
    
    Annotation * _selectedPinAnnotation;

    MBProgressHUD * _hud;
    
    ShareView * _shareView;

	MagnifierView * _loupe;
    
    UIImageView * _pinPointer;
    
    UIBarButtonItem * _messagesButton;
    UIBarButtonItem * _shareButton;
    
    DejalActivityView * _activityView;
}

@property (nonatomic , strong) id<AnnotationObserver> annotationDelegate;
@property (nonatomic , strong) AnnotationDocument * doc;
@property (nonatomic , retain) NSTimer *touchTimer;

@property (nonatomic, weak) IBOutlet SMPageControl * annotationPageControl;

@property (nonatomic , strong) IBOutlet AnnotationDrawingView * drawingView;
@property (nonatomic , strong) IBOutlet AnnotationPinView * pinView;

@end
