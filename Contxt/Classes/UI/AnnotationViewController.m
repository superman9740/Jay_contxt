//
//  AnnotationViewController.m
//  Contxt
//
//  Created by Chad Morris on 5/8/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "AnnotationViewController.h"
#import "AnnotationDocument.h"
#import "ImageInfo.h"
#import "DataController.h"
#import "Utilities.h"

#import "AnnotationButton.h"
#import "ImageAnnotation.h"
#import "ConvoAnnotation.h"
#import "ConvoViewController.h"

#import "TSActionSheet.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "KGModal.h"
#import "KxMenu.h"

#import "AnnotationDrawingView.h"
#import "AnnotationPinView.h"
#import "AnnotationUtility.h"

#import "ConvoListViewController.h"
#import "AnnotationDocListViewController.h"

#import "AFNetworking.h"
#import "DejalActivityView.h"

#import "COPeoplePickerViewController.h"
#import "JSONUtility.h"

#import "Utilities.h"


@interface AnnotationViewController () < AnnotationViewDelegate
                                       , AnnotationPinViewDelegate
                                       , AnnotationDrawingViewDelegate
                                       , ABPeoplePickerNavigationControllerDelegate
                                       , COPeoplePickerViewControllerDelegate
                                       , UIAlertViewDelegate>

@end

@implementation AnnotationViewController

@synthesize doc;
@synthesize touchTimer;
@synthesize pinView , drawingView;
@synthesize annotationPageControl;
@synthesize annotationDelegate;


#pragma mark - COPeoplePickerViewControllerDelegate Methods

- (void)peoplePickerViewControllerDidFinishPicking:(COPeoplePickerViewController *)controller
{
    NSMutableArray * emailList = [[NSMutableArray alloc] init];
    
    for( CORecord * record in controller.selectedRecords )
    {
        NSLog( @"title: %@" , record.title );
        NSLog( @"name: %@" , record.person.fullName );
        
        [emailList addObject:record.title];
    }
    
    [controller dismissViewControllerAnimated:YES completion:^{
        
        if( emailList && [emailList count] > 0 )
        {
            [DejalWhiteActivityView activityViewForView:self.navigationController.navigationBar.superview withLabel:@"Sharing..."];
            [[ServerComms sharedComms] shareAnnotationDoc:self.doc withEmailList:emailList];
        }
    }];
}

#pragma mark -

- (void)setChatIconUnread:(BOOL)unread
{
    NSString * file = @"chat-toolbar.png";
    
    if( unread )
        file = @"chat-toolbar-new.png";
    
    _messagesButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:file]
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(showMessages)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_messagesButton, _shareButton, nil];
}

- (void)willDeleteAnnotationWithKey:(NSString *)key
{
    AnnotationButton * buttonToDelete = nil;
    for( AnnotationButton * button in self.pinView.annotationButtons )
    {
        if( [button.annotation.key isEqualToString:key] )
        {
            buttonToDelete = button;
            break;
        }
    }
    
    if( buttonToDelete )
    {
        [buttonToDelete removeFromSuperview];
        [self.pinView removeButton:buttonToDelete];
    }
}

#pragma mark - KxMenuDelegate

- (void)willDismissMenu
{
    if( _pinPointer )
        [_pinPointer removeFromSuperview];
}

- (void)didDismissMenu
{}


#pragma mark - AnnotationDrawingViewDelegate Methods

- (void)willShowPopoverMenu
{
    self.annotationPageControl.hidden = YES;
}

- (void)willHidePopoverMenu
{
    self.annotationPageControl.hidden = NO;
}

#pragma mark - ServerCommsObserver Methods

- (void)serverErrorOccurred:(NSString *)error
{}

- (void)newAnnotationDocs:(NSArray *)keys
{}

- (void)newConvoMessages:(NSArray *)keys
{
    for( Annotation * annotation in [self.doc.annotations allObjects] )
    {
        if( ![annotation isKindOfClass:[ConvoAnnotation class]] )
            continue;
        
        for( ConversationMessage * message in [((ConvoAnnotation*)annotation).convoThread.convoMessages allObjects] )
            if( [keys containsObject:message.key] )
            {
                [self setChatIconUnread:YES];
                break;
            }
    }
}

- (void)newConvoThread:(NSString *)key
{
    ConvoAnnotation * annotation = [[DataController sharedController] convoAnnotationForKey:key];
    
    if( annotation )
        [self launchConvoThreadWithAnnotation:annotation];
}

- (void)newDocForImageAnnotation:(NSString *)key
{
    ImageAnnotation * annotation = [[DataController sharedController] imageAnnotationForKey:key];
    
    if( annotation )
        [self goToImageAnnotation:annotation];
}

- (void)shouldRefreshPinAnnotations
{
    if( self.pinView )
        [self.pinView initializePins];
}

- (void)shouldRefreshDrawingAnnotations
{
    if( self.drawingView )
        [self.drawingView initializeAnnotations];
}

- (void)shouldUpdateConvoMessageList
{
    [self setChatIconUnread:YES];
}

- (void)sharedAnnotationDoc:(NSString *)key success:(BOOL)success message:(NSString *)message
{
    [DejalActivityView removeView];
    
    if( success )
    {
        AnnotationDocument * updatedDocument = [[DataController sharedController] annotationDocumentForKey:key];
        
        if( updatedDocument )
            updatedDocument.status = [NSNumber numberWithInt:OBJ_STATUS_SAVED];
        
        if( !_hud )
        {
            _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:_hud];
            _hud.delegate = self;
            _hud.dimBackground = YES;
        }
        
        _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        _hud.mode = MBProgressHUDModeCustomView;
        _hud.labelText = @"Shared!";
        [_hud show:YES];
        [_hud hide:YES afterDelay:2];
    }
    else if( message && message.length > 0 )
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Sharing..."
                                                     message:[NSString stringWithFormat:@"%@",message]
                                                    delegate:nil
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}


#pragma mark - AnnotationPinViewDelegate Methods

- (void)didTouchConvoAnnotation:(ConvoAnnotation *)annotation
{
    if( !annotation.convoThread )
        [[ServerComms sharedComms] getConvoThreadForConvoAnnotation:annotation];
    else
        [self launchConvoThreadWithAnnotation:annotation];
}

- (void)didTouchImageAnnotation:(ImageAnnotation *)annotation
{
    if( [annotation.source isEqualToString:SOURCE_TYPE_CLOUD] && !annotation.annotationDoc )
    {
        [[ServerComms sharedComms] getAnnotationDocForImageAnnotation:annotation];
    }
    else if( annotation.annotationDoc )
    {
        [self goToImageAnnotation:annotation];
    }
    else
    {
        _selectedPinAnnotation = annotation;
        
        if( [annotation isKindOfClass:[ImageAnnotation class]] )
        {
            NSString * source = ((ImageAnnotation *)annotation).source;
            
            if( [source isEqualToString:SOURCE_TYPE_PHOTO_LIBRARY] )
                [self launchPhotoLibraryImport];
            else
                [self launchCameraControlWithAnimation];
        }
    }
}

- (void)goToImageAnnotation:(ImageAnnotation *)annotation
{
    AnnotationViewController * avc = [[AnnotationViewController alloc] init];
    avc.doc = annotation.annotationDoc;
    avc.annotationDelegate = self;
    
    _selectedPinAnnotation = nil;
    [self.navigationController pushViewController:avc animated:YES];
}


#pragma mark -
#pragma mark Actions

- (void)newImageAnnotationTouched
{
    if( !_capturedLongPressGesture )
        return;
    
    [self.pinView createAndTouchAnnotationButton:[self.pinView createAnnotation:@"Image" forSource:SOURCE_TYPE_CAMERA atTouchPoint:_capturedLongPressPoint]];
}

- (void)importFromCameraRollTouched
{
    if( !_capturedLongPressGesture )
        return;

    [self.pinView createAndTouchAnnotationButton:[self.pinView createAnnotation:@"Image" forSource:SOURCE_TYPE_PHOTO_LIBRARY atTouchPoint:_capturedLongPressPoint]];
}

- (void)newConvoAnnotationTouched
{
    if( !_capturedLongPressGesture )
        return;
    
    [self.pinView createAndTouchAnnotationButton:[self.pinView createAnnotation:@"Convo" forSource:@"Convo" atTouchPoint:_capturedLongPressPoint]];
}


#pragma mark - Loupe

- (void)addLoupe
{
    // add the loop to the superview.  if we add it to the view it magnifies, it'll magnify itself!
    [self.view addSubview:_loupe];
}

- (void)selectAnnotation:(KxMenuItem *)sender
{
    AnnotationButton * selectedButton = nil;
    
    for( AnnotationButton * button in self.pinView.annotationButtons )
    {
        if( [button.annotation.key isEqualToString:sender.tag] )
        {
            selectedButton = button;
            break;
        }
    }
    
    if( selectedButton )
    {
//        _selectedPinAnnotation = selectedButton.annotation;
        [self.pinView annotionPinButtonTouched:selectedButton];
    }
}

#pragma mark - AnnotationViewDelegate

- (void)didTap:(UIGestureRecognizer *)gestureRecognizer withPhotoView:(PZPhotoView *)photoView
{
    if( gestureRecognizer.state == UIGestureRecognizerStateEnded )
    {
        NSMutableArray *menuItems = [[NSMutableArray alloc] init];
        
        int numbering = 1;
        for( AnnotationButton * button in self.pinView.annotationButtons )
        {
            Annotation * annotation = button.annotation;
            
            CGPoint p = [gestureRecognizer locationInView:button];
            
            if( 0 <= p.x && p.x <= button.frame.size.width && 0 <= p.y && p.y <= button.frame.size.height )
            {
                NSString * date = [Utilities dateToShortDateString:annotation.dateCreated];
                NSString * time = [Utilities dateToTimeString:annotation.dateCreated];
                NSString * text = [NSString stringWithFormat:@"(%i) %@ @ %@", numbering , date , time];

                if( [annotation isKindOfClass:[ImageAnnotation class]] )
                {
                    UIImage * imageToDisplay;
                    
                    if( ((ImageAnnotation *)annotation).annotationDoc && ((ImageAnnotation *)annotation).annotationDoc.image )
                        imageToDisplay = [UIImage imageWithContentsOfFile:((ImageAnnotation *)annotation).annotationDoc.image.previewPath];
                    else
                        imageToDisplay = [UIImage imageNamed:@"cloud-download.png"];
                    
                    KxMenuItem * item = [KxMenuItem menuItem:text
                                                       image:imageToDisplay
                                                      target:self
                                                      action:@selector(selectAnnotation:)];
                    item.tag = annotation.key;
                    item.contentModeAspectFit = YES;
                    item.foreColor = DEFAULT_KXMENU_ITEM_COLOR;
                    [menuItems addObject:item];
                    
                }
                else if( [annotation isKindOfClass:[ConvoAnnotation class]] )
                {
                    UIImage * imageToDisplay;
                    
                    if( ((ConvoAnnotation *)annotation).convoThread )
                        imageToDisplay = [UIImage imageNamed:@"chat.png"];
                    else
                        imageToDisplay = [UIImage imageNamed:@"cloud-download.png"];
                    
                    KxMenuItem * item = [KxMenuItem menuItem:text
                                                        image:imageToDisplay
                                                       target:self
                                                       action:@selector(selectAnnotation:)];
                    item.tag = annotation.key;
                    item.foreColor = DEFAULT_KXMENU_ITEM_COLOR;
                    [menuItems addObject:item];
                }
                else
                    numbering--;
                
                numbering++;
            }
        }
        
        if( menuItems.count > 0 )
        {
            [KxMenu setTintColor:[UIColor lightGrayColor]];
            CGPoint p = [gestureRecognizer locationInView:self.view];
            [KxMenu showMenuInView:self.view fromRect:CGRectMake( p.x , p.y , 1 , 1 ) menuItems:menuItems];
            [KxMenu menuView].delegate = self;
        }
    }
}

- (void)didLongPress:(UIGestureRecognizer *)gestureRecognizer withPhotoView:(PZPhotoView *)photoView
{
    CGPoint tp = [gestureRecognizer locationInView:self.view];
    CGPoint mp = [gestureRecognizer locationInView:photoView];
    
    CGRect frame = CGRectMake( tp.x - PIN_IMAGE_SIZE / 2
                             , tp.y - PIN_IMAGE_SIZE - PIN_DRAG_TOUCH_yOFFSET
                             , PIN_IMAGE_SIZE
                             , PIN_IMAGE_SIZE
                             );

    if( gestureRecognizer.state == UIGestureRecognizerStateBegan )
    {
        _pinPointer = [[UIImageView alloc] initWithImage:POINTER_PIN_IMAGE];
        _pinPointer.frame = frame;
        
        [self.view addSubview:_pinPointer];
        [self.view bringSubviewToFront:_pinPointer];
    }
    else if( gestureRecognizer.state == UIGestureRecognizerStateChanged )
    {
        _pinPointer.frame = frame;
    }
    else
    {
        CGFloat touchY = tp.y - PIN_DRAG_TOUCH_yOFFSET;
        
        if( tp.x < photoView.frame.origin.x ||
            tp.x > photoView.frame.origin.x + photoView.frame.size.width ||
            touchY < photoView.frame.origin.y ||
            touchY > photoView.frame.origin.y + photoView.frame.size.height )
        {
            [_pinPointer removeFromSuperview];
            return;
        }
        
        _pinPointer.frame = frame;
        
        _capturedLongPressPoint = CGPointMake( mp.x + 1 , mp.y - PIN_DRAG_TOUCH_yOFFSET + 1 );
        
        _capturedLongPressGesture = gestureRecognizer;
        
        NSMutableArray *menuItems = [[NSMutableArray alloc] init];
        
        if( !self.doc.parentAnnotation )
        {
            // This parentAnnotation existed, then this AnnotationDocument originated from an ImageAnnotation,
            //   and we can't nest any more images. So disable the options for adding annotations and limit it
            //   just to converstaion pins.
            
            // However, since this doc as not parentAnnotation, we can allow adding images as well
            
            [menuItems addObject:[KxMenuItem menuItem:@"Camera"
                                                image:CAMERA_IMAGE
                                               target:self
                                               action:@selector(newImageAnnotationTouched)] ];
            
            [menuItems addObject:[KxMenuItem menuItem:@"Import"
                                                image:PLUS_IMAGE
                                               target:self
                                               action:@selector(importFromCameraRollTouched)] ];
        }
        
        [menuItems addObject:[KxMenuItem menuItem:@"Chat"
                                            image:[UIImage imageNamed:@"chat.png"]
                                           target:self
                                           action:@selector(newConvoAnnotationTouched)] ];
        
        for( KxMenuItem * item in menuItems )
            item.foreColor = DEFAULT_KXMENU_ITEM_COLOR;
        
//        CGPoint p = CGPointMake( tp.x - (xOffset/2) + 1 , tp.y - (yOffset/2) + 1 );
        CGPoint p = CGPointMake( _pinPointer.frame.origin.x + _pinPointer.frame.size.width / 2
                               , _pinPointer.frame.origin.y + _pinPointer.frame.size.height );
        
        [KxMenu setTintColor:[UIColor lightGrayColor]];
        
        [KxMenu showMenuInView:self.view
                      fromRect:CGRectMake( p.x , p.y , 0.0 , 0.0 )
                     menuItems:menuItems];
        
        [KxMenu menuView].delegate = self;
    }
}


#pragma mark - Actions

- (void)pageChanged:(id)sender
{
    self.drawingView.hidden = NO;
    self.pinView.hidden = NO;
    
    int adjustment = 320;
    if( self.annotationPageControl.currentPage == 1 )
    {
        // Scroll Left to Right
        adjustment *= -1;
    }

    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.pinView setFrame:CGRectMake( self.pinView.frame.origin.x + adjustment
                                                           , self.pinView.frame.origin.y
                                                           , self.pinView.frame.size.width
                                                           , self.pinView.frame.size.height)];
                         
                         [self.drawingView setFrame:CGRectMake( self.drawingView.frame.origin.x + adjustment
                                                               , self.drawingView.frame.origin.y
                                                               , self.drawingView.frame.size.width
                                                               , self.drawingView.frame.size.height)];
                     }
                     completion:^(BOOL completed){
                         if( self.annotationPageControl.currentPage == 0 )
                         {
                             self.drawingView.hidden = YES;
                             self.navigationItem.title = @"pinup";
                         }
                         else
                         {
                             self.pinView.hidden = YES;
                             self.navigationItem.title = @"markup";
                         }
                     }
     ];
}

#pragma mark - UIView Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[ServerComms sharedComms] addObserver:self];

    if( _selectedPinAnnotation && self.pinView )
    {
        AnnotationButton * buttonToDelete = nil;
        for( AnnotationButton * button in self.pinView.annotationButtons )
        {
            if( [button.annotation.key isEqualToString:_selectedPinAnnotation.key] )
            {
                [button removeFromSuperview];
                [self.pinView removeButton:buttonToDelete];
                break;
            }
        }
        
        [[DataController sharedController] deleteAnnotation:_selectedPinAnnotation];
        _selectedPinAnnotation = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
    [self.pinView setDoc:self.doc];
    [self.drawingView setDoc:self.doc];
    
    [self setChatIconUnread:NO];
    for( Annotation * annotation in [self.doc.annotations allObjects] )
    {
        if( ![annotation isKindOfClass:[ConvoAnnotation class]] )
            continue;
        
        for( ConversationMessage * message in [((ConvoAnnotation*)annotation).convoThread.convoMessages allObjects] )
            if( [message.unread boolValue] )
            {
                [self setChatIconUnread:YES];
                break;
            }
    }
    
    [[DataController sharedController] addObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[ServerComms sharedComms] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[DataController sharedController] removeObserver:self];
    [[ServerComms sharedComms] removeObserver:self];
    
    if( self.pinView )
        [self.pinView.photoScrollView dispose];
    
    if( self.drawingView )
        [self.drawingView.photoScrollView dispose];
    
//    [super viewDidUnload];
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _capturedLongPressGesture = nil;
    _selectedPinAnnotation = nil;
    
    self.pinView = [[AnnotationPinView alloc] init];
    
    if( self.pinView )
    {
        self.pinView.delegate = self;
        [self.view addSubview:self.pinView];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    self.drawingView = (AnnotationDrawingView *)[[[NSBundle mainBundle] loadNibNamed:@"AnnotationDrawingView" owner:self options:nil] lastObject];
    
    if( self.drawingView )
    {
        [self.drawingView initializeDrawings];
        self.drawingView.delegate = self;
        self.drawingView.frame = CGRectMake( 320 , 0 , self.drawingView.frame.size.width , self.drawingView.frame.size.height );
        self.drawingView.hidden = YES;
        [self.view addSubview:self.drawingView];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    self.annotationPageControl.numberOfPages = 2;
    self.annotationPageControl.currentPage = 0;
	self.annotationPageControl.indicatorMargin = 15.0f;
	self.annotationPageControl.indicatorDiameter = 10.0f;
	[self.annotationPageControl setPageIndicatorImage:[UIImage imageNamed:@"pageDot"]];
	[self.annotationPageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"currentPageDot"]];

	[self.annotationPageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view bringSubviewToFront:self.annotationPageControl];
    
    self.navigationItem.title = @"pinup";

    if( self.doc.parentAnnotation )
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                              target:self
                                                                                              action:@selector(deleteTouched)];
        self.navigationItem.leftItemsSupplementBackButton = YES;
    }
    
    _shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                 target:self
                                                                 action:@selector(showActionSheet:forEvent:)];
    
    _messagesButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat-toolbar.png"]
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(showMessages)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_messagesButton, _shareButton, nil];


    // Check with server to see if there are any changes
    [[ServerComms sharedComms] getAnnotationsForDoc:self.doc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( [[alertView title] isEqualToString:@"Delete Document?"] && buttonIndex > 0 )
    {
        [self deleteDocument];
    }
}


#pragma mark - Actions & Action Sheet/Sharing

- (void)deleteTouched
{
    NSString* message = @"ALL content for this document will be deleted. This CANNOT be undone. Delete?";
    
    // Verify Delete
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Document?"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Delete",nil];
    
    [alertView show];
}

- (void)deleteDocument
{
    if( !self.doc || !self.doc.parentAnnotation )
        return;
    
    if( self.annotationDelegate )
        [self.annotationDelegate willDeleteAnnotationWithKey:self.doc.parentAnnotation.key];
    
    [[DataController sharedController] deleteAnnotation:self.doc.parentAnnotation];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showMessages
{
    ConvoListViewController * vc = [[ConvoListViewController alloc] init];

    vc.docKey = [NSString stringWithFormat:@"%@",self.doc.key];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) showActionSheet:(id)sender forEvent:(UIEvent*)event
{
    /*
    TSActionSheet *actionSheet = [[TSActionSheet alloc] initWithTitle:@"Share"];
    [actionSheet addButtonWithTitle:@"Project" block:^{
        
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShareView" owner:self options:nil];
		_shareView = (ShareView *)[nib objectAtIndex:0];
        
        if( _shareView )
        {
            [_shareView specifyType:@"Project"];
            _shareView.delegate = self;
            
            [[KGModal sharedInstance] showWithContentView:_shareView];
        }
    }];
    [actionSheet addButtonWithTitle:@"Image" block:^{
        
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShareView" owner:self options:nil];
		_shareView = (ShareView *)[nib objectAtIndex:0];
        
        if( _shareView )
        {
            [_shareView specifyType:@"Image"];
            _shareView.delegate = self;
            
            [[KGModal sharedInstance] showWithContentView:_shareView];
        }
    }];
    [actionSheet addButtonWithTitle:@"Annotation" block:^{
        
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShareView" owner:self options:nil];
		_shareView = (ShareView *)[nib objectAtIndex:0];
        
        if( _shareView )
        {
            [_shareView specifyType:@"Annotation"];
            _shareView.delegate = self;
            
            [[KGModal sharedInstance] showWithContentView:_shareView];
        }
    }];
    [actionSheet cancelButtonWithTitle:@"Cancel" block:nil];
    actionSheet.cornerRadius = 5;
    
    [actionSheet showWithTouch:event];
    */
    
    COPeoplePickerViewController * ppvc = [[COPeoplePickerViewController alloc] init];
    ppvc.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:ppvc];
    navigationController.navigationItem.title = @"Share with...";
    ppvc.navigationItem.title = @"Share with...";
    [self presentViewController:navigationController animated:YES completion:nil];
    
/*    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShareView" owner:self options:nil];
    _shareView = (ShareView *)[nib objectAtIndex:0];
    
    if( _shareView )
    {
        [_shareView specifyType:@"Image"];
        _shareView.delegate = self;
        
        [[KGModal sharedInstance] showWithContentView:_shareView];
    } */
}

- (void)sharingCompleted
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	_hud.mode = MBProgressHUDModeCustomView;
	_hud.labelText = @"Shared!";
    sleep(1);
}

- (void)sharingCompletedWithError:(NSString *)message
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x.png"]];
	_hud.mode = MBProgressHUDModeCustomView;
	_hud.labelText = @"Error...";
    _hud.detailsLabelText = message;
    sleep(3);
}


#pragma mark - View Controller Actions

- (void)launchConvoThreadWithAnnotation:(ConvoAnnotation *)annotation
{
    ConvoViewController * cvc = [[ConvoViewController alloc] initWithNibName:@"ConvoViewController" bundle:nil];
    cvc.annotation = annotation;
    cvc.delegate = self;
    
    [self.navigationController pushViewController:cvc animated:YES];
}


- (void)launchCameraControlWithAnimation
{
    [self launchCameraControl:YES];
}

- (void)launchCameraControl:(BOOL)animated
{
#if( TARGET_IPHONE_SIMULATOR )
    return;
#endif
    
    // Create image picker controller
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Set source to the camera
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    
    // Delegate is self
    imagePicker.delegate = self;
    
    // Allow editing of image ?
    imagePicker.allowsEditing = NO;
    
    // Show image picker
    [self presentViewController:imagePicker animated:animated completion:nil];
}

- (void)launchPhotoLibraryImport
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - ImagePicker Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    ImageInfo * imageInfo = [Utilities createImageInfoFromImage:image
                                                      asPreview:YES
                                                    asThumbnail:YES];
    
    AnnotationDocument * annDoc = [[DataController sharedController] newAnnotationDocument];

    [[DataController sharedController] associateImageInfo:imageInfo withAnnotationDocument:annDoc];
    
    if( _selectedPinAnnotation )
    {
        [[DataController sharedController] associateAnnotationDocument:annDoc
                                                   withImageAnnotation:(ImageAnnotation *)_selectedPinAnnotation];
        [[DataController sharedController] saveContext];
        [[ServerComms sharedComms] saveAnnotation:(ImageAnnotation *)_selectedPinAnnotation];
    }

    _selectedPinAnnotation = nil;

    AnnotationViewController * avc = [[AnnotationViewController alloc] init];
    avc.doc = annDoc;
    avc.annotationDelegate = self;

    [picker dismissViewControllerAnimated:NO completion:nil];

    [self.navigationController pushViewController:avc animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if( _selectedPinAnnotation )
    {
        [[DataController sharedController] deleteAnnotation:_selectedPinAnnotation];
        _selectedPinAnnotation = nil;
    }
    
    [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    
    // Unable to save the image
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Unable to save image to Photo Album."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    else // All is well
        alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                           message:@"Image saved to Photo Album."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    [alert show];
}

#pragma mark -
#pragma mark ABPeoplePickerNavigationController Delegate Methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person
								property:(ABPropertyID)property
							  identifier:(ABMultiValueIdentifier)identifier
{
	if( nil == person || kABPersonEmailProperty != property )
		return NO;
	
//    NSString* name = CFBridgingRelease(ABRecordCopyCompositeName( person ));

    if( property == kABPersonEmailProperty )
	{
        [[KGModal sharedInstance] showWithContentView:_shareView];
        
        /*
         * Set up an ABMultiValue to hold the address values; copy from address
         * book record.
         */
        ABMultiValueRef multi = ABRecordCopyValue(person, property);
		
        // Set up an NSArray and copy the values in.
        NSArray *emailAddresses = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(multi));
        CFRelease(multi);
        
		// Figure out which values we want and store the index.
        const NSUInteger theIndex = ABMultiValueGetIndexForIdentifier(multi, identifier);
        
		// Set up an NSDictionary to hold the contents of the array.
        NSString * emailAddress = [emailAddresses objectAtIndex:theIndex];
      
        NSLog( @"email addres: %@" , emailAddress );
        
        if( _shareView )
            _shareView.email.text = emailAddress;
		
        // Return to the main view controller.
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
	
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	return YES;
}


@end
