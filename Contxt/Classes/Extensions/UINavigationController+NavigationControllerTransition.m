//
//  UINavigationController+NavigationControllerTransition.m
//
//  Created by Chad Morris on 12/10/11.
//  Copyright (c) 2011 p2websolutions. All rights reserved.
//

#import "UINavigationController+NavigationControllerTransition.h"
#import <QuartzCore/QuartzCore.h>

@implementation UINavigationController (NavigationControllerTransition)

- (void)pushViewController:(UIViewController *)vc withTransition:(UIViewAnimationTransition)transition animatimationDuration:(NSTimeInterval)ti animated:(BOOL)animated
{
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:ti];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView setAnimationTransition:transition
                           forView:self.view cache:NO];
    
    
    [self pushViewController:vc animated:animated];
    [UIView commitAnimations];    
}

- (void)popWithTransition:(UIViewAnimationTransition)aTransition animationDuration:(NSTimeInterval)ti animated:(BOOL)animated
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ti];
    [UIView setAnimationBeginsFromCurrentState:YES];        
    [UIView setAnimationTransition:aTransition forView:self.view cache:YES];
    [UIView commitAnimations];
    [self popViewControllerAnimated:animated];
    
/*    CATransition* transition = [CATransition animation];
    transition.duration = 0.75;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
//    transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self popViewControllerAnimated:NO];*/
}

@end
