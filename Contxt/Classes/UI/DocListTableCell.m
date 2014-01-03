//
//  DocListTableCell.m
//  Contxt
//
//  Created by Chad Morris on 10/19/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "DocListTableCell.h"
#import "ImageInfo.h"

@implementation DocListTableCell

@synthesize leftDoc = _leftDoc;
@synthesize rightDoc = _rightDoc;

- (void)setLeftDoc:(AnnotationDocument *)leftDoc
{
    if( leftDoc )
    {
        _leftDoc = leftDoc;
        UILongPressGestureRecognizer * lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftDocDeleteGesture:)];
        lpgr.minimumPressDuration = 0.5;
        
        UISwipeGestureRecognizer * swipelgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftDocDeleteGesture:)];
        swipelgr.direction = UISwipeGestureRecognizerDirectionLeft;
        
        UISwipeGestureRecognizer * swipergr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeLeftDeleteView)];
        swipergr.direction = UISwipeGestureRecognizerDirectionRight;
        
        UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectLeftDoc:)];
        tapgr.numberOfTapsRequired = 1;
        
        [_leftImage addGestureRecognizer:lpgr];
        [_leftImage addGestureRecognizer:swipelgr];
        [_leftImage addGestureRecognizer:swipergr];
        [_leftImage addGestureRecognizer:tapgr];
        [_leftImage setContentMode:UIViewContentModeScaleAspectFit];
        
        _leftImage.image = [UIImage imageWithContentsOfFile:_leftDoc.image.previewPath];
    }
}

- (void)setRightDoc:(AnnotationDocument *)rightDoc
{
    if( rightDoc )
    {
        _rightDoc = rightDoc;
        UILongPressGestureRecognizer * lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightDocDeleteGesture:)];
        lpgr.minimumPressDuration = 0.5;
        
        UISwipeGestureRecognizer * swipelgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightDocDeleteGesture:)];
        swipelgr.direction = UISwipeGestureRecognizerDirectionLeft;
        
        UISwipeGestureRecognizer * swipergr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeRightDeleteView)];
        swipergr.direction = UISwipeGestureRecognizerDirectionRight;
        
        UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectRightDoc:)];
        tapgr.numberOfTapsRequired = 1;
        
        [_rightImage addGestureRecognizer:lpgr];
        [_rightImage addGestureRecognizer:swipelgr];
        [_rightImage addGestureRecognizer:swipergr];
        [_rightImage addGestureRecognizer:tapgr];
        
        [_rightImage setContentMode:UIViewContentModeScaleAspectFit];
        
        _rightImage.image = [UIImage imageWithContentsOfFile:_rightDoc.image.previewPath];
    }
}

- (void)selectLeftDoc:(id)sender
{
    if( _leftDeleteView )
        [self removeLeftDeleteView];
    else if( self.delegate )
        [self.delegate selectedDoc:self.leftDoc.key];
}

- (void)selectRightDoc:(id)sender
{
    if( _rightDeleteView )
        [self removeRightDeleteView];
    else if( self.delegate )
        [self.delegate selectedDoc:self.rightDoc.key];
}

- (void)removeLeftDeleteView
{
    [UIView animateWithDuration:0.25 animations:^{
        _leftDeleteView.frame = _leftRectBeforeAnimate;
        _leftDeleteLabel.frame = CGRectMake( 0 , 0 , 0 , _leftDeleteLabel.frame.size.height );
    } completion:^(BOOL finished) {
        [_leftDeleteView removeFromSuperview];
        _leftDeleteView = nil;
    }];
}

- (void)removeRightDeleteView
{
    [UIView animateWithDuration:0.25 animations:^{
        _rightDeleteView.frame = _rightRectBeforeAnimate;
        _rightDeleteLabel.frame = CGRectMake( 0 , 0 , 0 , _rightDeleteLabel.frame.size.height );
    } completion:^(BOOL finished) {
        [_rightDeleteView removeFromSuperview];
        _rightDeleteView = nil;
    }];
}

- (void)handleLeftDocDeleteGesture:(UIGestureRecognizer *)sender
{
    if( !_leftDeleteView &&
           ( (sender.state == UIGestureRecognizerStateEnded && [sender isKindOfClass:[UISwipeGestureRecognizer class]]) ||
             (sender.state == UIGestureRecognizerStateBegan && [sender isKindOfClass:[UILongPressGestureRecognizer class]]) )
       )
    {
        _leftRectBeforeAnimate = CGRectMake( _leftImage.frame.origin.x + _leftImage.frame.size.width
                                             , _leftImage.frame.origin.y
                                             , 0
                                             , _leftImage.frame.size.height * 0.20 )
                                             ;
        
        _leftRectAfterAnimate = CGRectMake( _leftImage.frame.origin.x
                                            , _leftRectBeforeAnimate.origin.y
                                            , _leftImage.frame.size.width
                                            , _leftRectBeforeAnimate.size.height )
                                            ;
        
        _leftDeleteView = [[UIView alloc] initWithFrame:_leftRectBeforeAnimate];
        _leftDeleteView.backgroundColor = [UIColor redColor];
        _leftDeleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0 , 0 , _leftRectBeforeAnimate.size.width , _leftRectBeforeAnimate.size.height )];
        _leftDeleteLabel.textColor = [UIColor whiteColor];
        _leftDeleteLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17.f];
        _leftDeleteLabel.textAlignment = NSTextAlignmentCenter;
        _leftDeleteLabel.userInteractionEnabled = NO;
        _leftDeleteLabel.text = @"Delete";
        [_leftDeleteView addSubview:_leftDeleteLabel];
        [_leftDeleteView bringSubviewToFront:_leftDeleteLabel];
        
        UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteLeftDoc:)];
        tapgr.numberOfTapsRequired = 1;
        [_leftDeleteView addGestureRecognizer:tapgr];
        
        [self addSubview:_leftDeleteView];
        [self bringSubviewToFront:_leftDeleteView];
        
        [UIView animateWithDuration:0.25 animations:^{
            _leftDeleteView.frame = _leftRectAfterAnimate;
            _leftDeleteLabel.frame = CGRectMake( 0 , 0 , _leftRectAfterAnimate.size.width , _leftDeleteLabel.frame.size.height );
        }];
    }
}

- (void)handleRightDocDeleteGesture:(UIGestureRecognizer *)sender
{
    if( !_rightDeleteView &&
       ( (sender.state == UIGestureRecognizerStateEnded && [sender isKindOfClass:[UISwipeGestureRecognizer class]]) ||
        (sender.state == UIGestureRecognizerStateBegan && [sender isKindOfClass:[UILongPressGestureRecognizer class]]) )
       )
    {
        _rightRectBeforeAnimate = CGRectMake( _rightImage.frame.origin.x + _rightImage.frame.size.width
                                            , _rightImage.frame.origin.y
                                            , 0
                                            , _rightImage.frame.size.height * 0.20 )
        ;
        
        _rightRectAfterAnimate = CGRectMake( _rightImage.frame.origin.x
                                           , _rightRectBeforeAnimate.origin.y
                                           , _rightImage.frame.size.width
                                           , _rightRectBeforeAnimate.size.height )
        ;
        
        _rightDeleteView = [[UIView alloc] initWithFrame:_rightRectBeforeAnimate];
        _rightDeleteView.backgroundColor = [UIColor redColor];
        _rightDeleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0 , 0 , _rightRectBeforeAnimate.size.width , _rightRectBeforeAnimate.size.height )];
        _rightDeleteLabel.textColor = [UIColor whiteColor];
        _rightDeleteLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17.f];
        _rightDeleteLabel.textAlignment = NSTextAlignmentCenter;
        _rightDeleteLabel.userInteractionEnabled = NO;
        _rightDeleteLabel.text = @"Delete";
        [_rightDeleteView addSubview:_rightDeleteLabel];
        [_rightDeleteView bringSubviewToFront:_rightDeleteLabel];
        
        UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteRightDoc:)];
        tapgr.numberOfTapsRequired = 1;
        [_rightDeleteView addGestureRecognizer:tapgr];
        
        [self addSubview:_rightDeleteView];
        [self bringSubviewToFront:_rightDeleteView];
        
        [UIView animateWithDuration:0.25 animations:^{
            _rightDeleteView.frame = _rightRectAfterAnimate;
            _rightDeleteLabel.frame = CGRectMake( 0 , 0 , _rightRectAfterAnimate.size.width , _rightDeleteLabel.frame.size.height );
        }];
    }
}

- (void)deleteLeftDoc:(UILongPressGestureRecognizer *)sender
{
    if( self.delegate )
        [self.delegate deleteDoc:self.leftDoc.key];
}

- (void)deleteRightDoc:(id)sender
{
    if( self.delegate )
        [self.delegate deleteDoc:self.rightDoc.key];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _leftDoc = nil;
        _rightDoc = nil;
        _leftDeleteView = nil;
        _rightDeleteView = nil;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
