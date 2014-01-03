//
//  CustomCameraTapToFocusRectangle.m
//  Contxt
//
//  Created by sdickson on 1/3/14.
//  Copyright (c) 2014 Chad Morris. All rights reserved.
//

#import "CustomCameraTapToFocusRectangle.h"

@implementation CustomCameraTapToFocusRectangle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setBorderWidth:2.0];
        [self.layer setCornerRadius:4.0];
        [self.layer setBorderColor:[UIColor yellowColor].CGColor];
        
        CABasicAnimation* selectionAnimation = [CABasicAnimation
                                                animationWithKeyPath:@"borderColor"];
        selectionAnimation.toValue = (id)[UIColor clearColor].CGColor;
        selectionAnimation.repeatCount = 6;
        selectionAnimation.delegate = self;
        
        [self.layer addAnimation:selectionAnimation
                          forKey:@"selectionAnimation"];
        
    }
    return self;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [self.layer removeAllAnimations];
    [self.layer setBorderColor:[UIColor clearColor].CGColor];
    
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect
{
   
}
*/


@end
