//
//  AnnotationDocListViewController.h
//  ImageShowcase
//
//  Created by Chad Morris on 5/2/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLImageShowCase.h"
#import "NLImageViewDataSource.h"
#import "NLImageViewer.h"
#import "Project.h"
#import "NLImageShowCaseCell.h"
#import "DataChangeObserver.h"
#import "ServerCommsObserver.h"
#import "ServerComms.h"

@protocol AnnotationDocumentObserverOld <NSObject>

- (void)annotationDocumentSelected:(AnnotationDocument *)doc;

@end

@interface AnnotationDocListViewController : UIViewController < NLImageViewDataSource
                                                              , DataChangeObserver
                                                              , ServerCommsObserver
                                                              , UINavigationControllerDelegate
                                                              , UIImagePickerControllerDelegate>
{
    NLImageShowCase* _imageShowCase;
    NLImageViewer* _imageViewer;
    UIViewController * _imagViewController;
    
    NSMutableArray * _annotationDocs;
    
    NLImageShowCaseCell * _showCaseCellToDelete;
    
    BOOL _refreshOnAppear;
    
    ServerComms * _serverComms;
}

@property (nonatomic , copy) NSString * projectKey;
@property (nonatomic , strong) id<AnnotationDocumentObserverOld> delegate;

@property (nonatomic , assign) BOOL shouldShowCameraControl;
@property (nonatomic , assign) BOOL shouldShowSignup;
@property (nonatomic , assign) BOOL enforceRefreshOnAppear;

- (void)close;
- (void)refreshDocumentsList;

@end
