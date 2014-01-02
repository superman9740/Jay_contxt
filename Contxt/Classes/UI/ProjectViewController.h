//
//  ProjectViewController.h
//  Contxt
//
//  Created by Chad Morris on 5/2/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWTagList.h"
#import "AnnotationDocListViewController.h"

@class Project;

@interface ProjectViewController : UITableViewController < UITableViewDataSource
                                                         , UITableViewDelegate
                                                         , DWTagListDelegate
                                                         , UITextFieldDelegate
                                                         , AnnotationDocumentObserverOld >
//                                                         , UIGestureRecognizerDelegate >
{
    Project * _project;
    BOOL _discardChanges;
    BOOL _addMode;
}

@property (nonatomic , retain) UITableView * tableView;
@property (nonatomic , retain) NSMutableArray * tableDataSource;

@property (nonatomic , strong) NSString * projectKey;


- (void)addTag:(id)sender;
- (void)cancelChanges:(id)sender;

- (void)handleParallaxTouch:(UILongPressGestureRecognizer *)recognizer;


@end
