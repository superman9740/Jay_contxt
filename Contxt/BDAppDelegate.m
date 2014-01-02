//
//  BDAppDelegate.m
//  Contxt
//
//  Created by Chad Morris on 4/12/13.
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import "BDAppDelegate.h"
#import "Appirater.h"

#import "AnnotationDocListViewController.h"
#import "AnnotationDocListVC.h"
//#import "ProjectListViewController.h"
#import "DataController.h"
#import "FirstRunChecker.h"
#import "Project.h"
#import "Utilities.h"

#import "DSFingerTipWindow.h"

#import "ServerComms.h"

#define SIMULATE_NEW_MESSAGES FALSE

@implementation BDAppDelegate

- (void)dataChanged:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
//    NSSet *insertedObjects = [info objectForKey:NSInsertedObjectsKey];
//    NSSet *deletedObjects = [info objectForKey:NSDeletedObjectsKey];
    NSSet *updatedObjects = [info objectForKey:NSUpdatedObjectsKey];
    
    for( NSManagedObject *obj in updatedObjects )
    {
        if( ![obj isKindOfClass:[Project class]] )
            continue;
        
        if( [((Project *)obj).dateUpdated timeIntervalSinceNow] > -60 )
            continue;
        
        ((Project *)obj).dateUpdated = [NSDate date];
        [[DataController sharedController] saveContext];
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"applicationDidFinishLaunchingWithOptions - BEGIN");
	[Appirater appLaunched:YES];
    
    NSMutableArray * navCtrlStack = [[NSMutableArray alloc] init];
    
    self.window = [[DSFingerTipWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; //[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
//        _vc = [[AnnotationDocListViewController alloc] init];
        _vc = [[AnnotationDocListVC alloc] initWithNibName:@"AnnotationDocListVC" bundle:nil];
        _vc.shouldShowCameraControl = TRUE;
        [navCtrlStack addObject:_vc];
    }
    else
    {
        // @TODO: Same as iphone, but use the "ProjectListViewController_iPad" XIB
//        _vc = [[AnnotationDocListViewController alloc] init];
        _vc = [[AnnotationDocListVC alloc] initWithNibName:@"AnnotationDocListVC" bundle:nil];
        _vc.shouldShowCameraControl = TRUE;
        [navCtrlStack addObject:_vc];
    }
    
    bool bIsFirstRun = [FirstRunChecker isFirstRunOfApp];
    if( bIsFirstRun )
    {
        _vc.shouldShowSignup = TRUE;
        
        // Create a new Project for new images and a new Project for new annotations
        [[DataController sharedController] untitledProject];
        [[DataController sharedController] saveContext];        
    }
    
    _vc.projectKey = [[DataController sharedController] untitledProject].key;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataChanged:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[DataController sharedController].managedObjectContext];

    self.navigationController = [[UINavigationController alloc] initWithRootViewController:_vc];

    [self.window setRootViewController:self.navigationController];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    NSLog(@"applicationDidFinishLaunchingWithOptions - END");
    return YES;
}

-(BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog( @"handleOpenURL" );

    if( url && [url isFileURL] )
    {
        BOOL refreshRequired = FALSE;
        
        if( [[[url pathExtension] lowercaseString] isEqualToString:@"png"] ||
            [[[url pathExtension] lowercaseString] isEqualToString:@"jpg"] ||
            [[[url pathExtension] lowercaseString] isEqualToString:@"jpeg"] )
        {
            NSLog( @"pop to root view controller" );
//            [self.navigationController popToRootViewControllerAnimated:NO];
            
            UIView *topView = self.navigationController.topViewController.view;
            
            _hud = nil;
            
            if( topView )
            {
                NSLog( @"topView exists, which is good" );
                
                // Add Loading indicator
                _hud = [[MBProgressHUD alloc] initWithView:topView];
                [self.navigationController.view addSubview:_hud];
                
                _hud.dimBackground = YES;
                _hud.mode = MBProgressHUDModeIndeterminate;
                _hud.labelText = @"Importing...";
                
                [_hud show:YES];
//                [_hud showWhileExecuting:@selector(importImage:) onTarget:self withObject:url animated:YES];
                
                [self importImage:url];
            }
            else
                NSLog( @"topView DOES NOT exists, which is BAD" );

            
            refreshRequired = TRUE;
        }
        else if( [[[url pathExtension] lowercaseString] isEqualToString:@"pdf"] )
        {
            // @TODO: IMPLEMENT ME
        }

        if( refreshRequired )
        {
            if( _vc && [_vc isViewLoaded] )
                [_vc refreshDocumentsList];
            else
                _vc.enforceRefreshOnAppear = TRUE;
        }
        
    }
    return YES;
}

- (void)importImage:(NSURL *)url
{
    NSLog( @"importImage" );
    
    if( [url isFileURL] )
        NSLog( @"Yes, I'm a file URL" );
    else if( [url isFileReferenceURL] )
        NSLog( @"No, I'm a file reference URL" );
    else
        NSLog( @"I don't know what the crap I am. :( " );
    
    NSLog( @"create imageInfo" );
    ImageInfo * imageInfo = [Utilities createImageInfoFromURL:url asPreview:YES asThumbnail:YES];
    
    NSLog( @"create AnnotationDocument" );
    AnnotationDocument * annDoc = [[DataController sharedController] newAnnotationDocument];
    
    NSLog( @"get project" );
    Project * thisProject = [[DataController sharedController] untitledProject];
    
    NSLog( @"associate imageInfo with Doc" );
    [[DataController sharedController] associateImageInfo:imageInfo withAnnotationDocument:annDoc];
    NSLog( @"associate Doc with Project" );
    [[DataController sharedController] associateAnnotationDocument:annDoc withProject:thisProject];
    NSLog( @"save context" );
    [[DataController sharedController] saveContext];
    
    NSLog( @"call Import Complete" );
    [self importCompleted];
}

- (void)importCompleted
{
    NSLog( @"importCompleted" );

    if( _vc && [_vc isViewLoaded] )
        [_vc refreshDocumentsList];
    else
        _vc.enforceRefreshOnAppear = TRUE;

	_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	_hud.mode = MBProgressHUDModeCustomView;
	_hud.labelText = @"Import Complete!";
    
    [_hud hide:YES afterDelay:1];
}

- (void)importCompletedWithError:(NSString *)message
{
	_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x.png"]];
	_hud.mode = MBProgressHUDModeCustomView;
	_hud.labelText = @"Import failed...";
    _hud.detailsLabelText = message;
    
    [_hud hide:YES afterDelay:3];
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[DataController sharedController] saveContext];
}

@end
