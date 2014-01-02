//
//  BDAppDelegate.h
//  Contxt
//
//  Created by Chad Morris on 4/12/13.
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class AnnotationDocListViewController;
@class AnnotationDocListVC;

@interface BDAppDelegate : UIResponder <UIApplicationDelegate>
{
//    IBOutlet AnnotationDocListViewController * _vc;
    IBOutlet AnnotationDocListVC * _vc;
    MBProgressHUD * _hud;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

@end
