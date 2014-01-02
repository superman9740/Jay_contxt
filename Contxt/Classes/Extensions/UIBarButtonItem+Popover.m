//
//  UIBarButtonItem+Popover.m
//  Contxt
//
//  Created by Chad Morris on 6/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "UIBarButtonItem+Popover.h"

@implementation UIBarButtonItem (Popover)

- (CGRect)frameInView:(UIView *)v {
    
    UIView *theView = self.customView;
    if (!theView.superview && [self respondsToSelector:@selector(view)]) {
        theView = [self performSelector:@selector(view)];
    }
    
    UIView *parentView = theView.superview;
    NSArray *subviews = parentView.subviews;
    
    NSUInteger indexOfView = [subviews indexOfObject:theView];
    NSUInteger subviewCount = subviews.count;
    
    if (subviewCount > 0 && indexOfView != NSNotFound) {
        UIView *button = [parentView.subviews objectAtIndex:indexOfView];
        return [button convertRect:button.bounds toView:v];
    } else {
        return CGRectZero;
    }
}

@end

@implementation UIButton (Popover)

- (CGRect)frameInView:(UIView *)v {
    
    UIView *theView = self;
    if (!theView.superview && [self respondsToSelector:@selector(view)]) {
        theView = [self performSelector:@selector(view)];
    }
    
    UIView *parentView = theView.superview;
    NSArray *subviews = parentView.subviews;
    
    NSUInteger indexOfView = [subviews indexOfObject:theView];
    NSUInteger subviewCount = subviews.count;
    
    if (subviewCount > 0 && indexOfView != NSNotFound) {
        UIView *button = [parentView.subviews objectAtIndex:indexOfView];
        return [button convertRect:button.bounds toView:v];
    } else {
        return CGRectZero;
    }
}

@end
