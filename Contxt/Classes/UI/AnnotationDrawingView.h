//
//  AnnotationDrawingView.h
//  Contxt
//
//  Created by Chad Morris on 6/8/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnotationView.h"

#import "KxMenu.h"
#import "FPPopoverController.h"
#import "FontSliderView.h"

#import "DrawingView.h"


@protocol AnnotationDrawingViewDelegate <NSObject>
    @optional
    - (void)willShowPopoverMenu;
    - (void)willHidePopoverMenu;
@end

@interface AnnotationDrawingView : AnnotationView <KxMenuViewDelegate>
{
    NSMutableArray * _toolbarButtons;
    UIBarButtonItem * _currentSelectedButton;
    UIColor * _tintColor;
    
    FPPopoverController * _colorPopover;
    FontSliderView * _sliderView;
    CGFloat _fontSize;
    
    DrawingView * _drawView;
    DrawingView * _selectedDrawView;
    NSMutableArray * _selectedDrawViewList;
    NSMutableArray * _drawViews;
    DrawShapeType _selectedDrawType;
    
    CGPoint _dragPrevPosition;
    
    BOOL _clearButtonSelection;
    
    UITapGestureRecognizer * _tapGR;
    UILongPressGestureRecognizer * _lpGR;
    UIPanGestureRecognizer * _panGR;
    
    UILongPressGestureRecognizer * _lpGR_delete;
}

@property (nonatomic , assign , readonly) BOOL locked;

@property (nonatomic , strong) IBOutlet UIBarButtonItem * textBtn;
@property (nonatomic , strong) IBOutlet UIBarButtonItem * dimensionBtn;
@property (nonatomic , strong) IBOutlet UIBarButtonItem * lineBtn;
@property (nonatomic , strong) IBOutlet UIBarButtonItem * drawBtn;
@property (nonatomic , strong) IBOutlet UIBarButtonItem * shapeBtn;
@property (nonatomic , strong) IBOutlet UIBarButtonItem * fontBtn;
@property (nonatomic , strong) IBOutlet UIBarButtonItem * colorBtn;

@property (nonatomic , strong) IBOutlet UIToolbar * toolbar;

- (IBAction)toolSelected:(id)sender;
- (IBAction)fontToolSelected:(id)sender;
- (void)initializeDrawings;
- (void)initializeAnnotations;


@end
