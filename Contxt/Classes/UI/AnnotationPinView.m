//
//  AnnotationPinView.m
//  Contxt
//
//  Created by Chad Morris on 6/8/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "AnnotationPinView.h"
#import "AnnotationButton.h"

#import "DataController.h"
#import "ServerComms.h"

// Domain Model
#import "Annotation.h"
#import "AnnotationDocument.h"
#import "ImageInfo.h"
#import "ConvoAnnotation.h"
#import "ImageAnnotation.h"

// Helpers
#import "AnnotationUtility.h"
#import "Utilities.h"


@implementation AnnotationPinView

- (void)setDoc:(AnnotationDocument *)doc
{
    NSLog( @"setDoc" );
    _doc = doc;
    
    [self.photoScrollView addLongPressGestureWithDuration:0.5f];

    if( !self.photoScrollView.photoViewDelegate )
    {
        self.photoScrollView.photoViewDelegate = self;
    }
    
    [self initializePins];
    
    if( self.doc.image )
        [self.photoScrollView displayImage:[[UIImage alloc] initWithContentsOfFile:self.doc.image.path]];
}

- (Annotation *)createAnnotation:(NSString *)annotationType forSource:(NSString *)source atTouchPoint:(CGPoint)touchPoint
{
    Annotation * annotation = nil;
    UIImage * image = nil;
    
    if( [annotationType isEqualToString:@"Image"] )
    {
        image = CAMERA_IMAGE;

        annotation = [[DataController sharedController] newImageAnnotation];
        ((ImageAnnotation *)annotation).source = source;
    }
    else if( [annotationType isEqualToString:@"Convo"] )
    {
        image = CAMERA_IMAGE;

        annotation = [[DataController sharedController] newConvoAnnotation];
        ConversationThread * thread = [[DataController sharedController] newConversationThread];
        ContxtContact * contact = [[DataController sharedController] contactWithEmail:[[DataController sharedController] signedUpUser]];
        
        thread.owner = [[DataController sharedController] signedUpUser];
        
        [contact addParentConvoThreadObject:thread];
        [thread addParticipantsObject:contact];
        
        thread.parentAnnotation = (ConvoAnnotation *)annotation;
        ((ConvoAnnotation *)annotation).convoThread = thread;
    }
    
    AnnotationPoint * point = [[DataController sharedController] newAnnotationPoint];
    
    
    CGPoint pointScaled = [AnnotationUtility adjustPoint:[AnnotationUtility getPointAtNormalScaleForScaledPoint:touchPoint
                                                                                                         inView:self.photoScrollView]
                                       forCenteringImage:image];
    
    point.x = [NSNumber numberWithFloat:pointScaled.x];
    point.y = [NSNumber numberWithFloat:pointScaled.y];
    
    annotation.anchorPoint = point;
    
    [[DataController sharedController] associateAnnotation:annotation withAnnotationDocument:self.doc];
    [[DataController sharedController] saveContext];
    
    if( [annotation isKindOfClass:[ConvoAnnotation class]] )
        [[ServerComms sharedComms] saveAnnotation:(ConvoAnnotation *)annotation];
    
    return annotation;
}

- (void)createAndTouchAnnotationButton:(Annotation *)annotation
{
    AnnotationButton * b = [self addAnnotationPinButton:annotation toView:self.photoScrollView];
    
    if( b && b.annotation )
        [self annotionPinButtonTouched:b];
}

- (AnnotationButton *)addAnnotationPinButton:(Annotation *)annotation
{
    return [self addAnnotationPinButton:annotation toView:self.photoScrollView];
}

- (AnnotationButton *)addAnnotationPinButton:(Annotation *)annotation toView:(PZPhotoView *)targetView
{
    AnnotationButton * b = [AnnotationButton buttonWithType:UIButtonTypeCustom];
    b.annotation = annotation;
    b.userInteractionEnabled = NO;

    CGFloat scale = targetView.contentSize.height / targetView.frame.size.height;
    CGPoint adjustedPoint = [AnnotationUtility getAdjustedPointForAnnotation:annotation
                                                                   frameSize:CGSizeMake(PIN_IMAGE_SIZE , PIN_IMAGE_SIZE)
                                                                       scale:scale];

    BOOL bInverse = (adjustedPoint.y + PIN_IMAGE_SIZE/2  < 0.0 );
    
    if( bInverse )
        adjustedPoint.y += PIN_IMAGE_SIZE;
    
    UIImage * image = nil;
    if( [annotation isKindOfClass:[ImageAnnotation class]] )
    {
        if( bInverse )
            image = CAMERA_PIN_IMAGE_vMIRROR;
        else
            image = CAMERA_PIN_IMAGE;
    }
    else if( [annotation isKindOfClass:[ConvoAnnotation class]] )
    {
        if( bInverse )
            image = CHAT_PIN_IMAGE_vMIRROR;
        else
            image = CHAT_PIN_IMAGE;
    }
    
    if( image )
    {
        b.frame = CGRectMake( adjustedPoint.x
                             , adjustedPoint.y
                             , image.size.width
                             , image.size.height);
        
        [b setImage:image forState:UIControlStateNormal];
        [b addTarget:self action:@selector(annotionPinButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        [targetView addSubview:b];
        
        if( !_annotationButtons )
            _annotationButtons = [[NSMutableArray alloc] init];
        
        [_annotationButtons addObject:b];
        
        return b;
    }
    
    return nil;
}

- (void)annotionPinButtonTouched:(id)button
{
    if( [button isKindOfClass:[AnnotationButton class]] )
    {
        AnnotationButton * b = (AnnotationButton *)button;
        
        if( b.annotation )
        {
            if( [b.annotation isKindOfClass:[ImageAnnotation class]] )
            {
                if( self.delegate )
                    [self.delegate didTouchImageAnnotation:(ImageAnnotation *)b.annotation];
            }
            else if( [b.annotation isKindOfClass:[ConvoAnnotation class]] )
            {
                if( self.delegate )
                    [self.delegate didTouchConvoAnnotation:(ConvoAnnotation *)b.annotation];
            }
        }
        
    }
}


#pragma mark - UIView Methods

- (id)init
{
    return [self initWithFrame:CGRectMake(0, 0, 320, 400)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"AnnotationPinView" owner:self options:nil] lastObject];
        [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, [self frame].size.width,[self frame].size.height)];
        [self initializePins];
        
        self.photoScrollView.photoViewDelegate = self;
    }
    return self;
}

- (void)initializePins
{
    [self removeAllPins];
    
    NSArray * annotations = [self.doc.annotations allObjects];
    
    for( Annotation * annotation in annotations )
    {
        [self addAnnotationPinButton:annotation toView:self.photoScrollView];
    }
}

- (void)removeAllPins
{
    for( AnnotationButton * button in _annotationButtons )
        [button removeFromSuperview];
    
    [_annotationButtons removeAllObjects];
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
