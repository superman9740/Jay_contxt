//
//  UINavigationController+NavigationControllerTransition.h
//
//  Created by Chad Morris on 12/10/11.
//  Copyright (c) 2011 p2websolutions. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TRANSITION_DURATION_DEFAULT 0.5

@interface UINavigationController (NavigationControllerTransition)

- (void)pushViewController:(UIViewController *)vc withTransition:(UIViewAnimationTransition)transition animatimationDuration:(NSTimeInterval)ti animated:(BOOL)animated;
- (void)popWithTransition:(UIViewAnimationTransition)transition animationDuration:(NSTimeInterval)ti animated:(BOOL)animated;

@end
