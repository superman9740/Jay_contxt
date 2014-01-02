//
//  AnnotationDrawingView.m
//  Contxt
//
//  Created by Chad Morris on 6/8/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "AnnotationDrawingView.h"
#import "AnnotationDocument.h"
#import "ImageInfo.h"

#import "UIBarButtonItem+Popover.h"
#import "FPPopoverController.h"

#import <QuartzCore/QuartzCore.h>

#import "DrawingFreehandView.h"
#import "AnnotationUtility.h"

#import "DataController.h"
#import "ServerComms.h"
#import "Utilities.h"


#define kTextBtnTag      100
#define kDimensionBtnTag 101
#define kLineBtnTag      102
#define kDrawBtnTag      103
#define kShapeBtnTag     104
#define kFontBtnTag      105
#define kColorBtnTag     106

#define DEFAULT_COLOR [UIColor greenColor]
#define DEFAULT_FONT_SIZE 30.0

#define EXTRA_TBOX_BUFFER  2
#define EXTRA_TBOX_WIDTH  120
#define EXTRA_TBOX_HEIGHT 80

@implementation UIGestureRecognizer (Cancel)

- (void)cancel {
    self.enabled = NO;
    self.enabled = YES;
}

@end

@interface AnnotationDrawingView() <FontSliderViewDelegate>

@end


@implementation AnnotationDrawingView

- (CGPoint)getAdjustedPointForPhotoView:(PZPhotoView *)photoView andDrawingView:(DrawingView *)drawView
{
    CGFloat scale = photoView.contentSize.height / photoView.frame.size.height;
    return [AnnotationUtility getAdjustedPointFor:drawView.originalFrame.origin scale:scale];
}

- (CGRect)getAdjustedFrameForPhotoView:(PZPhotoView *)photoView andDrawingView:(DrawingView *)drawView
{
    CGFloat scale = photoView.contentSize.height / photoView.frame.size.height;
    CGPoint adjustedPoint = [AnnotationUtility getAdjustedPointFor:drawView.frame.origin scale:scale];
    
    return CGRectMake( adjustedPoint.x , adjustedPoint.y , drawView.frame.size.width * scale , drawView.frame.size.height * scale );
}

- (void)lockForDrawing:(BOOL)lock
{
    if( lock )
        self.photoScrollView.longPressDuration = 0.01;
    else
        self.photoScrollView.longPressDuration = -1.0;
}

- (void)showDeleteMenu:(id)sender
{
    UIGestureRecognizer * recognizer = nil;
    
    if( [sender isKindOfClass:[UIGestureRecognizer class]] )
    {
        recognizer = (UIGestureRecognizer *)sender;
    }
    
    if( recognizer && recognizer.state == UIGestureRecognizerStateBegan )
    {
        [KxMenu setTintColor:[UIColor lightGrayColor]];
        KxMenuItem * item = [KxMenuItem menuItem:@"Delete?"
                                           image:nil
                                          target:self
                                          action:@selector(confirmDelete:)];

        NSLog( @"max = %f  ..  min = %f" , _selectedDrawView.max.x , _selectedDrawView.min.x );
        CGRect rect = CGRectMake( _selectedDrawView.min.x
                                , _selectedDrawView.min.y + iOS7_yOFFSET
                                , _selectedDrawView.max.x - _selectedDrawView.min.x
                                , _selectedDrawView.max.y - _selectedDrawView.min.y );
        
        item.foreColor = DEFAULT_KXMENU_ITEM_COLOR;

        [KxMenu showMenuInView:self fromRect:rect menuItems:[NSArray arrayWithObject:item]];
        [KxMenu menuView].delegate = self;
    }
}

- (BOOL)locked
{
    return !self.photoScrollView.userInteractionEnabled;
}


#pragma mark - Delete

- (IBAction)confirmDelete:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Annotation?"
                                                    message:@"Are you sure you want to delete the selected annotation?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete",nil];
    [alert show];
}


#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( [[alertView title] isEqualToString:@"Delete Annotation?"] && buttonIndex > 0 && _selectedDrawView )
	{
        [_selectedDrawView removeFromSuperview];
        [_drawViews removeObject:_selectedDrawView];
        
        [[DataController sharedController] deleteAnnotation:_selectedDrawView.annotation];

        [self selectDrawing:nil];
	}
}

#pragma mark - Save Annotation

- (void)saveAnnotationForView:(DrawingView *)dv
{
    if( [dv isKindOfClass:[DrawingFreehandView class]] )
        [((DrawingFreehandView *)dv) updateAnnotation];
    else
        [dv updateAnnotation];
    
    dv.annotation.dateUpdated = [NSDate date];
    dv.annotation.status = [NSNumber numberWithInt:OBJ_STATUS_PENDING];
    
    [[DataController sharedController] saveContext];
    [[ServerComms sharedComms] saveAnnotation:dv.annotation];
}


#pragma mark - PZPhotoViewDelegate

- (void)photoViewDidSingleTap:(UIGestureRecognizer *)gestureRecognizer withPhotoView:(PZPhotoView *)photoView
{
    [KxMenu setTintColor:[UIColor lightGrayColor]];
    if( self.locked )
        return;
    
    if( _selectedDrawView && [_selectedDrawView containsPoint:[gestureRecognizer locationInView:photoView.mainView]] )
    {
        // @NOTE: Comment out this if you want to use the Long Press method to get the delete menu
//        [self showDeleteMenu:photoView];
        [self selectDrawing:nil];
        return;
    }
    
    [self selectDrawing:nil];
    
    
    if( gestureRecognizer.state == UIGestureRecognizerStateEnded )
    {
        NSLog( @"photoView tap" );
        
        if( !_selectedDrawViewList )
            _selectedDrawViewList = [[NSMutableArray alloc] init];
        
        _selectedDrawViewList = [[NSMutableArray alloc] init];
        
        for( DrawingView * view in _drawViews )
        {
            if( [view containsPoint:[gestureRecognizer locationInView:photoView.mainView]] )
                [_selectedDrawViewList addObject:view];
        }

        if( [_selectedDrawViewList count] == 1 )
        {
            [self selectDrawing:[_selectedDrawViewList objectAtIndex:0]];
        }
        else if( [_selectedDrawViewList count] > 1 )
        {
            NSMutableArray *menuItems = [[NSMutableArray alloc] init];
            
            int count = 0; 
            for( DrawingView * view in _selectedDrawViewList )
            {
                NSString * title = @"Unknown";
                
                switch( view.shapeType )
                {
                    case DrawShapeTypeRectangle:
                        title = @"Rectangle";
                        break;
                    case DrawShapeTypeCircle:
                        title = @"Ellipse";
                        break;
                    case DrawShapeTypeCustomBrush:
                        title = @"Brush";
                        break;
                    case DrawShapeTypeCustomPen:
                        title = @"Pen";
                        break;
                    case DrawShapeTypeArrow:
                        title = @"Leader";
                        break;
                    case DrawShapeTypeLine:
                        title = @"Line";
                        break;
                    case DrawShapeTypeText:
                        title = @"Text";
                        break;
                    case DrawShapeTypeTextLeader:
                        title = @"Text Leader";
                        break;
                    case DrawShapeTypeDimension:
                        title = @"Dimension";
                        break;
                    default:
                        break;
                }

                KxMenuItem * item = [KxMenuItem menuItem:title
                                                   image:nil
                                                  target:self
                                                  action:@selector(drawViewSelectedFromMenu:)];
                item.tag = [NSString stringWithFormat:@"%i",count];
                item.foreColor = DEFAULT_KXMENU_ITEM_COLOR;
                [menuItems addObject:item];
                
                count++;
            }
            
            CGPoint pt = [gestureRecognizer locationInView:photoView.mainView];
            
            [KxMenu showMenuInView:self fromRect:CGRectMake(pt.x, pt.y + iOS7_yOFFSET, 1, 1) menuItems:menuItems];
            [KxMenu menuView].delegate = self;
        }
    }
}

- (void)photoViewDidDoubleTap:(PZPhotoView *)photoView {}
- (void)photoViewDidTwoFingerTap:(PZPhotoView *)photoView {}
- (void)photoViewDidDoubleTwoFingerTap:(PZPhotoView *)photoView {}
- (void)photoViewDidScroll:(PZPhotoView *)photoView {}
- (void)photoViewDidZoom:(PZPhotoView *)photoView {}

- (void)moveViewsForZoomOrScroll:(PZPhotoView *)photoView
{
    for( DrawingView * view in _drawViews )
    {
        view.frame = [self getAdjustedFrameForPhotoView:photoView andDrawingView:view];
        
        view.hidden = NO;
        [photoView addSubview:view];
    }
}

#pragma mark Draw Shapes
- (void)photoViewDidLongPress:(UIGestureRecognizer *)gestureRecognizer withPhotoView:(PZPhotoView *)photoView
{
    NSLog( @"photoView says to draw a shape" );
    
    if( _selectedDrawType == DrawShapeTypeUnknown )
        return;
    
    CGPoint point = [gestureRecognizer locationInView:photoView.mainView];

    if( gestureRecognizer.state == UIGestureRecognizerStateBegan )
    {
        NSLog( @"Creating Draw View with type: %i" , _selectedDrawType );
        _drawView = [self createDrawViewWithType:_selectedDrawType];

        [photoView.mainView addSubview:_drawView];
        [photoView.mainView bringSubviewToFront:_drawView];
        [_drawViews addObject:_drawView];
        
        if( _selectedDrawType == DrawShapeTypeCustomBrush || _selectedDrawType == DrawShapeTypeCustomPen )
        {
            [((DrawingFreehandView *)_drawView) updatePoint:point];
        }
        else
        {
            _drawView.start = point;
        }
    }
    else if( gestureRecognizer.state == UIGestureRecognizerStateChanged )
    {
        if( _selectedDrawType == DrawShapeTypeCustomBrush || _selectedDrawType == DrawShapeTypeCustomPen )
        {
            [((DrawingFreehandView *)_drawView) updatePoint:point];
        }
        else
        {
            _drawView.end = point;
        }
        
        _drawView.isDrawing = YES;
        [_drawView setNeedsDisplay];
    }
    else if( gestureRecognizer.state == UIGestureRecognizerStateEnded )
    {
        if( _selectedDrawType == DrawShapeTypeCustomBrush || _selectedDrawType == DrawShapeTypeCustomPen )
        {
            [((DrawingFreehandView *)_drawView) updatePoint:point];
        }
        else
        {
            _drawView.end = point;
        }
        
        _drawView.isDrawing = NO;
        [_drawView setNeedsDisplay];

        if( _selectedDrawType == DrawShapeTypeCustomBrush || _selectedDrawType == DrawShapeTypeCustomPen )
        {
            CGPoint min = [((DrawingFreehandView *)_drawView) topLeftPoint];
            CGPoint max = [((DrawingFreehandView *)_drawView) bottomRightPoint];
            
            if( ABS( max.x - min.x ) <= 10 && ABS( max.y - min.y ) <= 10 )
            {
                [self deleteDrawing:_drawView];
                return;
            }
        }
        else
        {
            NSLog( @"e.x = %f , s.x = %f" , _drawView.end.x , _drawView.start.x );
            if( ABS( _drawView.end.x - _drawView.start.x ) <= 10 && ABS( _drawView.end.y - _drawView.start.y ) <= 10 )
            {
                [self deleteDrawing:_drawView];
                return;
            }
        }
        
        if( _selectedDrawType == DrawShapeTypeCustomBrush || _selectedDrawType == DrawShapeTypeCustomPen )
        {
            [self saveAnnotationForView:_drawView];

            // We want to keep the view locked for drawing, so do don't anything else.
            return;
        }
        else
        {
            DrawShapeType tmp = _selectedDrawType;
            
            [self lockForDrawing:NO];
            [self selectDrawing:nil];
            
            _selectedDrawType = tmp;
            
            _currentSelectedButton.tintColor = nil;
            _currentSelectedButton = nil;
            
            if( _selectedDrawType == DrawShapeTypeText )
            {
                [_drawView createTextView];
                _drawView.fontSize = _fontSize;
                [self selectDrawing:_drawView];
                //[_drawView focusForTextEditing];
            }
            else if( _selectedDrawType == DrawShapeTypeTextLeader || _selectedDrawType == DrawShapeTypeDimension )
            {
                DrawingView * drawView = [self createDrawViewWithType:DrawShapeTypeText];
                
                CGPoint start = CGPointMake( _drawView.centerPoint.x , _drawView.centerPoint.y );

                if( _drawView.centerPoint.x >= self.photoScrollView.frame.size.width - (EXTRA_TBOX_BUFFER + EXTRA_TBOX_WIDTH) )
                    start.x -= (EXTRA_TBOX_BUFFER + EXTRA_TBOX_WIDTH); // Drawing is on the LHS, so draw to the right
                else
                    start.x += EXTRA_TBOX_BUFFER;
                
                if( _drawView.centerPoint.y >= self.photoScrollView.frame.size.height - (EXTRA_TBOX_BUFFER + EXTRA_TBOX_HEIGHT) )
                    start.y -= (EXTRA_TBOX_BUFFER + EXTRA_TBOX_HEIGHT);
                else
                    start.y += EXTRA_TBOX_BUFFER;

                CGPoint end = CGPointMake( start.x + EXTRA_TBOX_WIDTH , start.y + EXTRA_TBOX_HEIGHT );
                
                drawView.start = CGPointMake( start.x , start.y );
                drawView.end = CGPointMake( end.x , end.y );
                
                NSLog( @"TextView.start( %f , %f )" , drawView.start.x , drawView.start.y );
                NSLog( @"TextView.end  ( %f , %f )" , drawView.end.x , drawView.end.y );
                
                [drawView createTextView];
                drawView.fontSize = _fontSize;

                [photoView.mainView addSubview:drawView];
                [photoView.mainView bringSubviewToFront:drawView];
                [_drawViews addObject:drawView];
                [self selectDrawing:drawView];
                
                [self saveAnnotationForView:drawView];
            }
        }
        
        [self saveAnnotationForView:_drawView];
    }
    else if( gestureRecognizer.state == UIGestureRecognizerStateCancelled )
    {
        // @TODO: DELETE THE DRAWING??
    }
}

- (void)dragDrawingView:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog( @"Dragging" );
    CGPoint point = [gestureRecognizer locationInView:self.photoScrollView.mainView];
    
    if( gestureRecognizer.state == UIGestureRecognizerStateBegan )
    {
        _dragPrevPosition = point;
        
/*        if( _selectedDrawView && ![_selectedDrawView containsPoint:[gestureRecognizer locationInView:self.photoScrollView.mainView]
                                                withAllowableError:20])
        {
            NSLog( @"Cancelling gesture..." );
            [gestureRecognizer cancel];
        }*/
    }
    else if( gestureRecognizer.state == UIGestureRecognizerStateChanged )
    {
        CGSize distance = CGSizeMake( point.x - _dragPrevPosition.x , point.y - _dragPrevPosition.y );

        _selectedDrawView.start = CGPointMake( _selectedDrawView.start.x + distance.width
                                              , _selectedDrawView.start.y + distance.height);
        
        _selectedDrawView.end = CGPointMake( _selectedDrawView.end.x + distance.width
                                            , _selectedDrawView.end.y + distance.height);
        
        if( _selectedDrawView.shapeType == DrawShapeTypeCustomPen || _selectedDrawView.shapeType == DrawShapeTypeCustomBrush )
        {
            CGSize size = ((DrawingFreehandView *)_selectedDrawView).delta;
            ((DrawingFreehandView *)_selectedDrawView).delta = CGSizeMake( size.width + distance.width , size.height + distance.height );
        }

        _dragPrevPosition = point;
    }
    else if( gestureRecognizer.state == UIGestureRecognizerStateEnded )
    {
        CGSize distance = CGSizeMake( point.x - _dragPrevPosition.x , point.y - _dragPrevPosition.y );

        _selectedDrawView.start = CGPointMake( _selectedDrawView.start.x + distance.width
                                             , _selectedDrawView.start.y + distance.height);

        _selectedDrawView.end = CGPointMake( _selectedDrawView.end.x + distance.width
                                           , _selectedDrawView.end.y + distance.height);
        
        if( _selectedDrawView.shapeType == DrawShapeTypeCustomPen || _selectedDrawView.shapeType == DrawShapeTypeCustomBrush )
        {
            CGSize size = ((DrawingFreehandView *)_selectedDrawView).delta;
            ((DrawingFreehandView *)_selectedDrawView).delta = CGSizeMake( size.width + distance.width , size.height + distance.height );
        }
        
        [self saveAnnotationForView:_selectedDrawView];
    }
    else if( gestureRecognizer.state == UIGestureRecognizerStateCancelled )
    {
    }
    
    [_selectedDrawView setNeedsDisplay];    
}


#pragma mark - FontSliderViewDelegate

- (void)sliderValueDidChange:(FontSliderView *)slider
{
    _fontSize = slider.slider.value;
    self.fontBtn.title = [NSString stringWithFormat:@"%ipt",(int)_fontSize];
    
    if( _selectedDrawView && _selectedDrawView.shapeType == DrawShapeTypeText )
    {
        _selectedDrawView.fontSize = _fontSize;
        [self saveAnnotationForView:_selectedDrawView];
    }
    
    NSLog( @"FontSize changed: %f" , _fontSize );
}

#pragma mark - Color Picker

- (UIButton *)createPickerButtonWithColor:(UIColor *)color frame:(CGRect)frame
{
    UIButton * button = [[UIButton alloc] initWithFrame:frame];
    
    [button addTarget:self action:@selector(colorSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setSelected:NO];
    [button setNeedsDisplay];
    button.backgroundColor = color;
    
    button.layer.cornerRadius = 4;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.borderWidth = 1.0f;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = button.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[ [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.45] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1]  CGColor], nil];
    
    [button.layer insertSublayer:gradient atIndex:0];
    
    return button;
}

#pragma mark - KxMenuViewDelegate Methods

- (void)willDismissMenu
{
    if( self.delegate )
        [self.delegate willHidePopoverMenu];
}

- (void)didDismissMenu
{
    if( _clearButtonSelection )
    {
        [self lockForDrawing:NO];
        [self selectDrawing:nil];
        
        _clearButtonSelection = FALSE;
        _currentSelectedButton.tintColor = nil;
        _currentSelectedButton = nil;
    }
    
    if( self.delegate )
        [self.delegate willHidePopoverMenu];
}


#pragma mark - Tool Selection / Actions

- (CGFloat)buttonWidthForToolbar
{
    switch( [_toolbarButtons count] - 2 ) // account for spacers
    {
        case 5: return 50;
        case 6: return 40;
        case 7: return 34;
            
        default: return 34;
    }
}

- (void)removeFromToolbar:(UIBarButtonItem *)button
{
    [_toolbarButtons removeObject:button];
    
    CGFloat width = [self buttonWidthForToolbar];
    for( UIBarButtonItem * item in _toolbarButtons )
        item.width = width;
    
    [self.toolbar setItems:_toolbarButtons];
}

- (void)addToToolbar:(UIBarButtonItem *)button atIndex:(NSInteger)i
{
    [_toolbarButtons insertObject:button atIndex:i];
    
    CGFloat width = [self buttonWidthForToolbar];
    for( UIBarButtonItem * item in _toolbarButtons )
        item.width = width;
    
    [self.toolbar setItems:_toolbarButtons];
}

- (void)selectDrawing:(DrawingView *)view
{
    if( _selectedDrawView )
    {
        _selectedDrawView.isSelected = NO;
        _selectedDrawView.userInteractionEnabled = NO;
        
        [_selectedDrawView setNeedsDisplay];
    }
    
    _selectedDrawView = view;

    if( !_selectedDrawView )
    {
        _selectedDrawType = DrawShapeTypeUnknown;
        return;
    }
    else
    {
        _selectedDrawType = view.shapeType;
        
        if( view.shapeType == DrawShapeTypeText )
        {
            // Show Popup Menu
            [KxMenu setTintColor:[UIColor lightGrayColor]];
            NSMutableArray * menuItems = [[NSMutableArray alloc] initWithCapacity:3];
            
            [menuItems addObject:[KxMenuItem menuItem:@"Edit Text"
                                                image:[UIImage imageNamed:@"edit.png"]
                                               target:self
                                               action:@selector(editDrawViewText:)] ];
            
            [menuItems addObject:[KxMenuItem menuItem:@"Font Size"
                                                image:[UIImage imageNamed:@"resize_font.png"]
                                               target:self
                                               action:@selector(resizeFontDrawViewText:)] ];
            
            [menuItems addObject:[KxMenuItem menuItem:@"Move"
                                                image:[UIImage imageNamed:@"move.png"]
                                               target:self
                                               action:@selector(moveDrawView:)] ];
            
            [menuItems addObject:[KxMenuItem menuItem:@"Delete"
                                                image:[UIImage imageNamed:@"delete.png"]
                                               target:self
                                               action:@selector(confirmDelete:)] ];
            
            for( KxMenuItem * item in menuItems )
                item.foreColor = DEFAULT_KXMENU_ITEM_COLOR;
            
            [KxMenu showMenuInView:self fromRect:view.frame menuItems:menuItems];
            [KxMenu menuView].delegate = self;
            
            if( self.delegate )
                [self.delegate willShowPopoverMenu];
        }
//        [self showDeleteMenu:view];
    }
   
    [_selectedDrawView addGestureRecognizer:_panGR];
    [self.photoScrollView.panGestureRecognizer requireGestureRecognizerToFail:_panGR];

    // @NOTE: Use this if you want to long press for the delete menu, but previously, it was double-showing
    [_selectedDrawView addGestureRecognizer:_lpGR_delete];

    _selectedDrawView.userInteractionEnabled = TRUE;
    _selectedDrawView.isSelected = TRUE;
    [_selectedDrawView setNeedsDisplay];
}

- (void)editDrawViewText:(id)sender
{
    if( _selectedDrawView && _selectedDrawView.shapeType == DrawShapeTypeText )
    {
        [_selectedDrawView enableTextView:YES];
    }
}

- (void)resizeFontDrawViewText:(id)sender
{
    if( _selectedDrawView && _selectedDrawView.shapeType == DrawShapeTypeText )
    {
        [self fontToolSelected:sender];
    }
}

- (void)drawViewSelectedFromMenu:(id)sender
{
    if( [sender isKindOfClass:[KxMenuItem class]] )
    {
        KxMenuItem * item = (KxMenuItem *)sender;
        
        if( item.tag && item.tag.length > 0 )
        {
            int i = [item.tag intValue];
            
            if( i < [_selectedDrawViewList count] )
            {
                [self selectDrawing:[_selectedDrawViewList objectAtIndex:i]];
            }
        }
    }
}

- (void)activateSelectedTool:(UIBarButtonItem *)newSelectedButton
{
    [KxMenu setTintColor:[UIColor lightGrayColor]];
    _clearButtonSelection = FALSE;
    
    // If a current button is selected, and it's the same one they are touching, then "Unlock"
    if( _currentSelectedButton && _currentSelectedButton.tag == newSelectedButton.tag )
    {
        [self lockForDrawing:NO];
        [self selectDrawing:nil];
        
        _currentSelectedButton.tintColor = nil;
        _currentSelectedButton = nil;

        return;
    }

    // Font Size Change
    if( newSelectedButton.tag == kFontBtnTag )
    {
        [self fontToolSelected:newSelectedButton];
        return;
    }
    
    // Color Selection
    if( newSelectedButton.tag == kColorBtnTag )
    {
        [self showColorPicker:newSelectedButton];
        return;
    }
    
    for( UIBarButtonItem * button in _toolbarButtons )
        if( button.tag != kColorBtnTag )
            button.tintColor = nil;
    
    // Text button selected
    if( newSelectedButton.tag == kTextBtnTag )
    {
        NSMutableArray *menuItems = [[NSMutableArray alloc] init];
        
        [menuItems addObject:[KxMenuItem menuItem:@"Text"
                                            image:[UIImage imageNamed:@"text.png"]
                                           target:self
                                           action:@selector(textToolSelected)] ];
        
        [menuItems addObject:[KxMenuItem menuItem:@"Text+Leader"
                                            image:[UIImage imageNamed:@"text+leader.png"]
                                           target:self
                                           action:@selector(textLeaderToolSelected)] ];
        
        for( KxMenuItem * item in menuItems )
            item.foreColor = DEFAULT_KXMENU_ITEM_COLOR;
        
        [KxMenu showMenuInView:self fromRect:[self.textBtn frameInView:self] menuItems:menuItems];
        [KxMenu menuView].delegate = self;
        
        if( self.delegate )
            [self.delegate willShowPopoverMenu];
    }
    else
    // Line button selected
    if( newSelectedButton.tag == kLineBtnTag )
    {
        NSMutableArray *menuItems = [[NSMutableArray alloc] init];
        
        [menuItems addObject:[KxMenuItem menuItem:@"Line"
                                            image:[UIImage imageNamed:@"line.png"]
                                           target:self
                                           action:@selector(lineToolSelected)] ];
        
        [menuItems addObject:[KxMenuItem menuItem:@"Leader"
                                            image:[UIImage imageNamed:@"arrow.png"]
                                           target:self
                                           action:@selector(leaderToolSelected)] ];
        
        for( KxMenuItem * item in menuItems )
            item.foreColor = DEFAULT_KXMENU_ITEM_COLOR;
        
        [KxMenu showMenuInView:self fromRect:[self.lineBtn frameInView:self] menuItems:menuItems];
        [KxMenu menuView].delegate = self;
        
        if( self.delegate )
            [self.delegate willShowPopoverMenu];
    }
    else
    // Draw (Brush/Pen) button selected
    if( newSelectedButton.tag == kDrawBtnTag )
    {
        NSMutableArray *menuItems = [[NSMutableArray alloc] init];
        
        [menuItems addObject:[KxMenuItem menuItem:@"Brush"
                                            image:[UIImage imageNamed:@"brush.png"]
                                           target:self
                                           action:@selector(brushToolSelected)] ];
        
        [menuItems addObject:[KxMenuItem menuItem:@"Pen"
                                            image:[UIImage imageNamed:@"pen.png"]
                                           target:self
                                           action:@selector(penToolSelected)] ];
        
        for( KxMenuItem * item in menuItems )
            item.foreColor = DEFAULT_KXMENU_ITEM_COLOR;

        [KxMenu showMenuInView:self fromRect:[self.drawBtn frameInView:self] menuItems:menuItems];
        [KxMenu menuView].delegate = self;
        
        if( self.delegate )
            [self.delegate willShowPopoverMenu];
    }
    else
    // Shape button selected
    if( newSelectedButton.tag == kShapeBtnTag )
    {
        NSMutableArray *menuItems = [[NSMutableArray alloc] init];
        
        [menuItems addObject:[KxMenuItem menuItem:@"Rectangle"
                                            image:[UIImage imageNamed:@"rectangle.png"]
                                           target:self
                                           action:@selector(squareToolSelected)] ];
        
        [menuItems addObject:[KxMenuItem menuItem:@"Ellipse"
                                            image:[UIImage imageNamed:@"ellipse.png"]
                                           target:self
                                           action:@selector(circleToolSelected)] ];

        for( KxMenuItem * item in menuItems )
            item.foreColor = DEFAULT_KXMENU_ITEM_COLOR;

        [KxMenu showMenuInView:self fromRect:[self.shapeBtn frameInView:self] menuItems:menuItems];
        [KxMenu menuView].delegate = self;

        if( self.delegate )
            [self.delegate willShowPopoverMenu];
    }
    else
    // Dimension button selected -- Do this last because we want to keep this button selected
    if( newSelectedButton.tag == kDimensionBtnTag )
    {
        [self dimensionToolSelected];
    }
    else
    {
        // Only color it if the user has selected something.
        _currentSelectedButton = newSelectedButton;
        
        if( _currentSelectedButton.tag != kColorBtnTag )
            _currentSelectedButton.tintColor = _tintColor;

        [self lockForDrawing:YES];
        [self selectDrawing:nil];
    }
    
}

- (void)prepForDrawing
{
    [self lockForDrawing:YES];
    [self selectDrawing:nil];

    if( _currentSelectedButton.tag != kColorBtnTag )
        _currentSelectedButton.tintColor = _tintColor;
}

- (DrawingView *)createDrawViewWithType:(DrawShapeType)type
{
    DrawingView * drawView;
    
    CGRect newFrame = CGRectMake( 0
                                , 0
                                , self.photoScrollView.contentSize.width
                                , self.photoScrollView.contentSize.height
                                );
    if( type != DrawShapeTypeCustomBrush && type != DrawShapeTypeCustomPen )
        drawView = [[DrawingView alloc] initWithFrame:newFrame];
    else
        drawView = [[DrawingFreehandView alloc] initWithFrame:newFrame];
    
    if( type == DrawShapeTypeCustomBrush )
    {
        drawView.strokeWidth = 5.0;
    }
    
    drawView.shapeType = (type == DrawShapeTypeTextLeader ? DrawShapeTypeArrow : type);
    drawView.userInteractionEnabled = FALSE;
    drawView.color = _tintColor;
    
    drawView.annotation = [[DataController sharedController] newDrawingAnnotation];
    [[DataController sharedController] associateAnnotation:drawView.annotation withAnnotationDocument:self.doc];

    return drawView;
}

- (void)deleteDrawing:(DrawingView *)dview
{
    [dview removeFromSuperview];
    
    [self.doc removeAnnotationsObject:dview.annotation];
    [[DataController sharedController] deleteAnnotation:dview.annotation];
    [[DataController sharedController] saveContext];
}


- (void)textToolSelected
{
    _currentSelectedButton = self.textBtn;
    [self prepForDrawing];

    self.textBtn.image = [UIImage imageNamed:@"text.png"];
    _selectedDrawType = DrawShapeTypeText;
}

- (void)textLeaderToolSelected
{
    _currentSelectedButton = self.textBtn;
    [self prepForDrawing];

    self.textBtn.image = [UIImage imageNamed:@"text+leader.png"];
    _selectedDrawType = DrawShapeTypeTextLeader;
}

- (void)dimensionToolSelected
{
    _currentSelectedButton = self.dimensionBtn;
    [self prepForDrawing];

    _selectedDrawType = DrawShapeTypeDimension;
}

- (void)brushToolSelected
{
    _currentSelectedButton = self.drawBtn;
    [self prepForDrawing];

    self.drawBtn.image = [UIImage imageNamed:@"brush.png"];
    _selectedDrawType = DrawShapeTypeCustomBrush;
}

- (void)penToolSelected
{
    _currentSelectedButton = self.drawBtn;
    [self prepForDrawing];

    self.drawBtn.image = [UIImage imageNamed:@"pen.png"];
    _selectedDrawType = DrawShapeTypeCustomPen;
}

- (void)squareToolSelected
{
    _currentSelectedButton = self.shapeBtn;
    [self prepForDrawing];

    self.shapeBtn.image = [UIImage imageNamed:@"square.png"];
    _selectedDrawType = DrawShapeTypeRectangle;
}

- (void)circleToolSelected
{
    _currentSelectedButton = self.shapeBtn;
    [self prepForDrawing];

    self.shapeBtn.image = [UIImage imageNamed:@"circle.png"];
    _selectedDrawType = DrawShapeTypeCircle;
}

- (void)lineToolSelected
{
    _currentSelectedButton = self.lineBtn;
    [self prepForDrawing];

    self.lineBtn.image = [UIImage imageNamed:@"line.png"];
    _selectedDrawType = DrawShapeTypeLine;
}

- (void)leaderToolSelected
{
    _currentSelectedButton = self.lineBtn;
    [self prepForDrawing];

    self.lineBtn.image = [UIImage imageNamed:@"arrow.png"];
    _selectedDrawType = DrawShapeTypeArrow;
}

- (IBAction)fontToolSelected:(id)sender
{
    CGRect btnRect = [self.fontBtn frameInView:self];
    _sliderView = [[FontSliderView alloc] initWithFrame:CGRectMake(0 , 0 , 30 , 90)];
    _sliderView.delegate = self;
    [_sliderView setSliderValue:_fontSize];
    
    UIViewController * vc = [[UIViewController alloc] init];
    vc.view = _sliderView;
    _colorPopover = [[FPPopoverController alloc] initWithViewController:vc];
    _colorPopover.contentSize = CGSizeMake( 60 , 160 );
    _colorPopover.arrowDirection = FPPopoverArrowDirectionDown;
    _colorPopover.title = @"Size";
    _colorPopover.tint = FPPopoverWhiteTint;
    
    CGPoint pt = CGPointMake( btnRect.origin.x + btnRect.size.width / 2 , btnRect.origin.y + 60 - iOS7_yOFFSET );
    [_colorPopover presentPopoverFromPoint:pt];
}

- (void)togglePanZoomMode
{
    _selectedDrawType = DrawShapeTypeUnknown;

    self.photoScrollView.userInteractionEnabled = !self.photoScrollView.userInteractionEnabled;
}

- (IBAction)toolSelected:(id)sender
{
//    self.colorBtn.tintColor = _tintColor;
    
    if( [sender isKindOfClass:[UIBarButtonItem class]] )
    {
        UIBarButtonItem * button = (UIBarButtonItem *)sender;
        if( button.tag != kColorBtnTag )
            button.tintColor = _tintColor;
        [self activateSelectedTool:button];
    }
}


#pragma mark - Color Picker

- (IBAction)showColorPicker:(id)sender
{
    UIView * colorPalette = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 66, 100)];
    [colorPalette addSubview:[self createPickerButtonWithColor:[UIColor redColor]       frame:CGRectMake(  2 ,  2 , 30 , 30 )]];
    [colorPalette addSubview:[self createPickerButtonWithColor:[UIColor purpleColor]    frame:CGRectMake( 34 ,  2 , 30 , 30 )]];
    [colorPalette addSubview:[self createPickerButtonWithColor:[UIColor orangeColor]    frame:CGRectMake(  2 , 34 , 30 , 30 )]];
    [colorPalette addSubview:[self createPickerButtonWithColor:[UIColor blueColor]      frame:CGRectMake( 34 , 34 , 30 , 30 )]];
    [colorPalette addSubview:[self createPickerButtonWithColor:[UIColor yellowColor]    frame:CGRectMake(  2 , 66 , 30 , 30 )]];
    [colorPalette addSubview:[self createPickerButtonWithColor:[UIColor greenColor]     frame:CGRectMake( 34 , 66 , 30 , 30 )]];
    [colorPalette addSubview:[self createPickerButtonWithColor:[Utilities lightGrayColor] frame:CGRectMake(  2 , 98 , 30 , 30 )]];
    [colorPalette addSubview:[self createPickerButtonWithColor:[UIColor darkGrayColor]  frame:CGRectMake( 34 , 98 , 30 , 30 )]];
    colorPalette.backgroundColor = [UIColor whiteColor];
    
    UIViewController * vc = [[UIViewController alloc] init];
    vc.view = colorPalette;
    
    _colorPopover = [[FPPopoverController alloc] initWithViewController:vc];
    _colorPopover.contentSize = CGSizeMake( 86 , 170 ); // <- Removed this because the last two button colors (bottom row) were removed.
    _colorPopover.arrowDirection = FPPopoverArrowDirectionDown;
    _colorPopover.title = nil;
    _colorPopover.tint = FPPopoverWhiteTint;
    
    CGRect btnRect = [((UIButton *)sender) frameInView:self];
    CGPoint pt = CGPointMake( btnRect.origin.x + btnRect.size.width / 2 , btnRect.origin.y + 60 - iOS7_yOFFSET);
    [_colorPopover presentPopoverFromPoint:pt];
}

- (void)colorSelected:(UIButton *)button
{
    [_colorPopover dismissPopoverAnimated:YES];
    _tintColor = button.backgroundColor;

    if( _currentSelectedButton.tag != kColorBtnTag )
        _currentSelectedButton.tintColor = _tintColor;
//    self.colorBtn.tintColor = _tintColor;

    if( _selectedDrawView )
    {
        _selectedDrawView.color = _tintColor;
        [self saveAnnotationForView:_selectedDrawView];
        
        [_selectedDrawView setNeedsDisplay];
    }
}


#pragma mark - Initialization / Setup

- (void)setDoc:(AnnotationDocument *)doc
{
    _doc = doc;
    
    if( !self.photoScrollView.photoViewDelegate )
    {
        self.photoScrollView.photoViewDelegate = self;
    }
    
    [self initializeDrawings];
    
    if( self.doc.image )
    {
        [self.photoScrollView displayImage:[[UIImage alloc] initWithContentsOfFile:self.doc.image.path]];
    }
    
    [self initializeAnnotations];
}

- (void)initializeAnnotations
{
    if( !_doc )
        return;
    
    for( DrawingView * dview in _drawViews )
        [dview removeFromSuperview];
    
    [_drawViews removeAllObjects];
    
    NSMutableArray * annotations = [[NSMutableArray alloc] init];
    
    for( Annotation * annotation in [self.doc.annotations allObjects] )
        if( [annotation isKindOfClass:[DrawingAnnotation class]] )
            [annotations addObject:annotation];
    
    for( DrawingAnnotation * annotation in annotations )
    {
        DrawShapeType type = (DrawShapeType)[annotation.drawingType intValue];
        
        DrawingView * dv = nil;
        
        if( DrawShapeTypeCustomBrush == type || DrawShapeTypeCustomPen == type )
        {
            dv = [[DrawingFreehandView alloc] initWithFrame:CGRectMake( 0
                                                                      , 0
                                                                      , self.photoScrollView.contentSize.width
                                                                      , self.photoScrollView.contentSize.height )];
            [((DrawingFreehandView *)dv) assignAnnotation:annotation initialize:YES];
        }
        else
        {
            dv = [[DrawingView alloc] initWithFrame:CGRectMake( 0
                                                              , 0
                                                              , self.photoScrollView.contentSize.width
                                                              , self.photoScrollView.contentSize.height )];
            [dv assignAnnotation:annotation initialize:YES];
        }
        
        dv.userInteractionEnabled = FALSE;
        
        [self.photoScrollView.mainView addSubview:dv];
        [self.photoScrollView.mainView bringSubviewToFront:dv];
        
        [_drawViews addObject:dv];
        [dv setNeedsDisplay];
    }
}

- (void)initializeDrawings
{
    _lpGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(dragDrawingView:)];
    _lpGR.minimumPressDuration = 0.08;
    
    _lpGR_delete = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showDeleteMenu:)];
    _lpGR_delete.minimumPressDuration = 0.5;
    
    // @NOTE: Use this if you want to long press for the delete menu, but previously, it was double-showing
    [_lpGR requireGestureRecognizerToFail:_lpGR_delete];
    
    _panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragDrawingView:)];
    _panGR.minimumNumberOfTouches = 1;
    _panGR.maximumNumberOfTouches = 1;

    _tintColor = DEFAULT_COLOR;
//    self.colorBtn.tintColor = _tintColor;
    
    _fontSize = DEFAULT_FONT_SIZE;
    _selectedDrawType = DrawShapeTypeUnknown;
    _drawViews = [[NSMutableArray alloc] init];
    
    self.photoScrollView.userInteractionEnabled = YES;
    self.photoScrollView.longPressDuration = -1.0;
    
    self.textBtn.tag      = kTextBtnTag;
    self.dimensionBtn.tag = kDimensionBtnTag;
    self.lineBtn.tag      = kLineBtnTag;
    self.drawBtn.tag      = kDrawBtnTag;
    self.shapeBtn.tag     = kShapeBtnTag;
    self.fontBtn.tag      = kFontBtnTag;
    self.colorBtn.tag     = kColorBtnTag;
    
    self.shapeBtn.title = nil;
    self.shapeBtn.image = [UIImage imageNamed:@"shapes.png"];

    UIBarButtonItem * spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _toolbarButtons = [NSMutableArray arrayWithObjects: spacer
                       , self.textBtn
                       , self.dimensionBtn
                       , self.lineBtn
                       , self.drawBtn
                       , self.shapeBtn
                       , self.fontBtn
                       , self.colorBtn
                       , spacer
                       , nil];
    
    CGFloat toolbarButtonWidth = [self buttonWidthForToolbar];
    for( UIBarButtonItem * item in _toolbarButtons )
        item.width = toolbarButtonWidth;
    
    UIImage * image = [UIImage imageNamed:@"eyedropper.png"];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect rect = [self.colorBtn frameInView:self];
    button.bounds = CGRectMake( 0 , 0, (rect.size.width == 0 ? [self buttonWidthForToolbar] : rect.size.width) , (rect.size.height == 0 ? 44 : rect.size.height) );
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showColorPicker:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    barButtonItem.tag = kColorBtnTag;
    self.colorBtn = barButtonItem;
    
    [self.toolbar setItems:_toolbarButtons];
    
    // Set up the font button
    self.fontBtn.image = nil;
    self.fontBtn.title = [NSString stringWithFormat:@"%ipt",(int)_fontSize];
    [self.fontBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica"
                                                                                                    size:15.0], NSFontAttributeName,nil]
                                forState:UIControlStateNormal];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog( @"touchesBegan" );
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog( @"touchesMoved" );
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog( @"touchesEnded" );
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog( @"touchesCancelled" );
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
