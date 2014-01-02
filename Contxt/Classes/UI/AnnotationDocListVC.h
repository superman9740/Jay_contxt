//
//  AnnotationDocListVC.h
//  Contxt
//
//  Created by Chad Morris on 10/19/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnotationDocument.h"
#import "ServerCommsObserver.h"
#import "DataChangeObserver.h"
#import "ServerComms.h"
#import "CustomCameraViewController.h"

@protocol AnnotationDocumentObserver <NSObject>

- (void)annotationDocumentSelected:(AnnotationDocument *)doc;

@end


@interface AnnotationDocListVC : UIViewController   < UITableViewDataSource , UITableViewDelegate
                                                    , DataChangeObserver
                                                    , ServerCommsObserver
                                                    , UINavigationControllerDelegate
                                                    , CustomCameraDelegate>
{
    NSMutableArray * _docList;
    BOOL _refreshOnAppear;
    ServerComms * _serverComms;

    NSUInteger _itemsPerRow;
    
    NSString * _docKeyToDelete;
    
    CustomCameraViewController* cameraViewController;
    
}

@property (nonatomic , copy) NSString * projectKey;
@property (nonatomic , strong) id<AnnotationDocumentObserver> delegate;

@property (nonatomic , assign) BOOL shouldShowCameraControl;
@property (nonatomic , assign) BOOL shouldShowSignup;
@property (nonatomic , assign) BOOL enforceRefreshOnAppear;
@property (nonatomic , strong) IBOutlet UITableView * tableView;

- (void)close;
- (void)refreshDocumentsList;

@end
