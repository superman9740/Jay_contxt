//
//  PZPhotoView.m
//  PhotoZoom
//
//  Created by Brennan Stehling on 10/27/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import "PZPhotoView.h"
#import "PbDoubleTapGestureRecognizer.h"

#define kZoomStep 2

@interface PZPhotoView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation PZPhotoView

@synthesize longPressDuration;
@synthesize imageView = _imageView;
@synthesize contentModeAspectFit;

- (void)dispose
{
    [self setZoomScale:self.minimumZoomScale animated:FALSE];
    [_imageView setImage:nil];
    _imageView = nil;
    _image = nil;
}

- (void)setLongPressDuration:(CGFloat)aLongPressDuration
{
    if( aLongPressDuration < 0.0f )
    {
        if( _scrollViewLongPress )
            [self removeGestureRecognizer:_scrollViewLongPress];

        _scrollViewLongPress = nil;
        return;
    }
    
    if( !_scrollViewLongPress )
        _scrollViewLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrollViewLongPress:)];
    
    [self removeGestureRecognizer:_scrollViewLongPress];
    
    _scrollViewLongPress.minimumPressDuration = aLongPressDuration;

    [self addGestureRecognizer:_scrollViewLongPress];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (void)setupView {
    self.delegate = self;
    
    self.contentModeAspectFit = NO;

    self.mainView = [[UIView alloc] initWithFrame:self.frame];
    self.mainView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.mainView];
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    
    UITapGestureRecognizer *scrollViewDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleScrollViewDoubleTap:)];
    [scrollViewDoubleTap setNumberOfTapsRequired:2];
    [self addGestureRecognizer:scrollViewDoubleTap];
    
    UITapGestureRecognizer *scrollViewTwoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(handleScrollViewTwoFingerTap:)];
    [scrollViewTwoFingerTap setNumberOfTouchesRequired:2];
    [self addGestureRecognizer:scrollViewTwoFingerTap];
    
    UITapGestureRecognizer *scrollViewSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleScrollViewSingleTap:)];
    [scrollViewSingleTap requireGestureRecognizerToFail:scrollViewDoubleTap];
    [self addGestureRecognizer:scrollViewSingleTap];
}

- (UILongPressGestureRecognizer *)addLongPressGestureWithDuration:(CGFloat)duration
{
    UILongPressGestureRecognizer *scrollViewLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                      action:@selector(handleScrollViewLongPress:)];
    scrollViewLongPress.minimumPressDuration = duration;
    [self addGestureRecognizer:scrollViewLongPress];
    
    return scrollViewLongPress;
}

- (void)removeLongPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer
{
    [self removeGestureRecognizer:recognizer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.mainView) {
        // center the zoom view as it becomes smaller than the size of the screen
        CGSize boundsSize = self.bounds.size;
        CGRect frameToCenter = self.mainView.frame;

        // center horizontally
        if (frameToCenter.size.width < boundsSize.width)
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
        else
            frameToCenter.origin.x = 0;

        // center vertically
        if (frameToCenter.size.height < boundsSize.height)
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
        else
            frameToCenter.origin.y = 0;

        self.mainView.frame = frameToCenter;
        
        CGPoint contentOffset = self.contentOffset;
        
        // ensure horizontal offset is reasonable
        if (frameToCenter.origin.x != 0.0)
            contentOffset.x = 0.0;
        
        // ensure vertical offset is reasonable
        if (frameToCenter.origin.y != 0.0)
            contentOffset.y = 0.0;
        
        self.contentOffset = contentOffset;
        
        // ensure content insert is zeroed out using translucent navigation bars
        self.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    }
}

- (void)setFrame:(CGRect)frame {
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}

#pragma mark - Public Implementation
#pragma mark -

- (void)prepareForReuse {
    // start by dropping any views and resetting the key properties
    if (self.mainView != nil) {
        for (UIGestureRecognizer *gestureRecognizer in self.mainView.gestureRecognizers) {
            [self.mainView removeGestureRecognizer:gestureRecognizer];
        }
    }
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    self.mainView = nil;
}

- (void)displayImage:(UIImage *)image {
    NSAssert(self.photoViewDelegate != nil, @"Invalid State");
    
    if( _image )
        _image = nil;
    
    if( _imageView )
        _imageView = nil;
    
    _image = image;
    self.imageView = [[UIImageView alloc] initWithImage:_image];
    self.imageView.frame = CGRectMake(0, 0, self.mainView.frame.size.width, self.mainView.frame.size.height);

    if( self.contentModeAspectFit )
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.mainView.userInteractionEnabled = TRUE;
    [self.mainView addSubview:self.imageView];
//    self.imageView = imageView;
    
    // add gesture recognizers to the image view
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    PbDoubleTapGestureRecognizer *doubleTap = [[PbDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    UITapGestureRecognizer *doubleTwoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTwoFingerTap:)];
    
//    [doubleTap setNumberOfTapsRequired:2];
//    doubleTap.maximumDoubleTapDuration = 0.2f;
    [twoFingerTap setNumberOfTouchesRequired:2];
    [doubleTwoFingerTap setNumberOfTapsRequired:2];
    [doubleTwoFingerTap setNumberOfTouchesRequired:2];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [twoFingerTap requireGestureRecognizerToFail:doubleTwoFingerTap];
    
    [self.mainView addGestureRecognizer:singleTap];
//    [self.mainView addGestureRecognizer:doubleTap];
    [self.mainView addGestureRecognizer:twoFingerTap];
//    [self.mainView addGestureRecognizer:doubleTwoFingerTap];
    
    self.contentSize = self.mainView.frame.size;
    
    [self setMaxMinZoomScalesForCurrentBounds];
    [self setZoomScale:self.minimumZoomScale animated:FALSE];
}

- (void)startWaiting {
    if (!self.activityIndicator) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:activityIndicator];
        [self bringSubviewToFront:activityIndicator];
        [activityIndicator stopAnimating];
        self.activityIndicator = activityIndicator;
    }
    
    CGFloat xPos = (CGRectGetWidth(self.frame) / 2) - (CGRectGetWidth(self.activityIndicator.frame) / 2);
    CGFloat yPos = (CGRectGetHeight(self.frame) / 2) - (CGRectGetHeight(self.activityIndicator.frame) / 2);
    
    self.activityIndicator.center = CGPointMake(xPos, yPos);
    [self bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)stopWaiting {
    [self.activityIndicator stopAnimating];
}

#pragma mark - Gestures
#pragma mark -

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.photoViewDelegate != nil) {
        [self.photoViewDelegate photoViewDidSingleTap:gestureRecognizer withPhotoView:self];
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.zoomScale == self.maximumZoomScale) {
        // jump back to minimum scale
        [self updateZoomScaleWithGesture:gestureRecognizer newScale:self.minimumZoomScale];
    }
    else {
        // double tap zooms in
        CGFloat newScale = MIN(self.zoomScale * kZoomStep, self.maximumZoomScale);
        [self updateZoomScaleWithGesture:gestureRecognizer newScale:newScale];
    }
    
    if (self.photoViewDelegate != nil) {
        [self.photoViewDelegate photoViewDidDoubleTap:self];
    }
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    CGFloat newScale = MAX([self zoomScale] / kZoomStep, self.minimumZoomScale);
    [self updateZoomScaleWithGesture:gestureRecognizer newScale:newScale];
    
    if (self.photoViewDelegate != nil) {
        [self.photoViewDelegate photoViewDidTwoFingerTap:self];
    }
}

- (void)handleDoubleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.photoViewDelegate != nil) {
        [self.photoViewDelegate photoViewDidDoubleTwoFingerTap:self];
    }
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.photoViewDelegate != nil) {
        [self.photoViewDelegate photoViewDidLongPress:gestureRecognizer withPhotoView:self];
    }
}

- (void)handleScrollViewSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.photoViewDelegate != nil) {
        [self.photoViewDelegate photoViewDidSingleTap:gestureRecognizer withPhotoView:self];
    }
}

- (void)handleScrollViewDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.imageView.image == nil) return;
    CGPoint center =[self adjustPointIntoImageView:[gestureRecognizer locationInView:gestureRecognizer.view]];
    
    if (!CGPointEqualToPoint(center, CGPointZero)) {
        CGFloat newScale = MIN([self zoomScale] * kZoomStep, self.maximumZoomScale);
        [self updateZoomScale:newScale withCenter:center];
    }
}

- (void)handleScrollViewTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.imageView.image == nil) return;
    CGPoint center =[self adjustPointIntoImageView:[gestureRecognizer locationInView:gestureRecognizer.view]];
    
    if (!CGPointEqualToPoint(center, CGPointZero)) {
        CGFloat newScale = MAX([self zoomScale] / kZoomStep, self.minimumZoomScale);
        [self updateZoomScale:newScale withCenter:center];
    }
}

- (void)handleScrollViewLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if( self.photoViewDelegate != nil )
    {
        [self.photoViewDelegate photoViewDidLongPress:gestureRecognizer withPhotoView:self];
    }
}


- (CGPoint)adjustPointIntoImageView:(CGPoint)center {
    BOOL contains = CGRectContainsPoint(self.mainView.frame, center);
    
    if (!contains) {
        center.x = center.x / self.zoomScale;
        center.y = center.y / self.zoomScale;
        
        // adjust center with bounds and scale to be a point within the image view bounds
        CGRect imageViewBounds = self.mainView.bounds;
        
        center.x = MAX(center.x, imageViewBounds.origin.x);
        center.x = MIN(center.x, imageViewBounds.origin.x + imageViewBounds.size.height);
        
        center.y = MAX(center.y, imageViewBounds.origin.y);
        center.y = MIN(center.y, imageViewBounds.origin.y + imageViewBounds.size.width);
        
        return center;
    }
    
    return CGPointZero;
}


#pragma mark - Support Methods
#pragma mark -

- (void)updateZoomScale:(CGFloat)newScale {
    CGPoint center = CGPointMake(self.mainView.bounds.size.width/ 2.0, self.mainView.bounds.size.height / 2.0);
    [self updateZoomScale:newScale withCenter:center];
}

- (void)updateZoomScaleWithGesture:(UIGestureRecognizer *)gestureRecognizer newScale:(CGFloat)newScale {
    CGPoint center = [gestureRecognizer locationInView:gestureRecognizer.view];
    [self updateZoomScale:newScale withCenter:center];
}

- (void)updateZoomScale:(CGFloat)newScale withCenter:(CGPoint)center {
    NSAssert(newScale >= self.minimumZoomScale, @"Invalid State");
    NSAssert(newScale <= self.maximumZoomScale, @"Invalid State");

    if (self.zoomScale != newScale) {
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:center];
        [self zoomToRect:zoomRect animated:YES];
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    NSAssert(scale >= self.minimumZoomScale, @"Invalid State");
    NSAssert(scale <= self.maximumZoomScale, @"Invalid State");
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    zoomRect.size.width = self.frame.size.width / scale;
    zoomRect.size.height = self.frame.size.height / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    CGSize boundsSize = self.bounds.size;
    
    CGFloat minScale = 0.25;
    
    if (self.mainView.bounds.size.width > 0.0 && self.mainView.bounds.size.height > 0.0) {
        // calculate min/max zoomscale
        CGFloat xScale = boundsSize.width  / self.mainView.bounds.size.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / self.mainView.bounds.size.height;   // the scale needed to perfectly fit the image height-wise
        
        minScale = MIN(xScale, yScale);
    }
    
    CGFloat maxScale = minScale * (kZoomStep * 2);
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

- (void)prepareToResize {
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:self.mainView];
    
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing {
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:self.mainView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset {
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
    return CGPointZero;
}

#pragma mark - UIScrollViewDelegate Methods
#pragma mark -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mainView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if( self.photoViewDelegate )
        [self.photoViewDelegate photoViewDidZoom:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( self.photoViewDelegate )
        [self.photoViewDelegate photoViewDidScroll:self];
}

#pragma mark - Layout Debugging Support
#pragma mark -

- (void)logRect:(CGRect)rect withName:(NSString *)name {
    DebugLog(@"%@: %f, %f / %f, %f", name, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void)logLayout {
    DebugLog(@"#### PZPhotoView ###");
    
    [self logRect:self.bounds withName:@"self.bounds"];
    [self logRect:self.frame withName:@"self.frame"];
    
    DebugLog(@"contentSize: %f, %f", self.contentSize.width, self.contentSize.height);
    DebugLog(@"contentOffset: %f, %f", self.contentOffset.x, self.contentOffset.y);
    DebugLog(@"contentInset: %f, %f, %f, %f", self.contentInset.top, self.contentInset.right, self.contentInset.bottom, self.contentInset.left);
}

@end
