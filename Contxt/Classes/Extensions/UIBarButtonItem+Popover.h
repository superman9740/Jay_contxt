//
//  UIBarButtonItem+Popover.h
//  Contxt
//
//  Created by Chad Morris on 6/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Popover)

- (CGRect)frameInView:(UIView *)v;

@end

@interface UIButton (Popover)

- (CGRect)frameInView:(UIView *)v;

@end
