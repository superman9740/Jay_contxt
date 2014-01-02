//
//  ProjectListViewController.h
//  Contxt
//
//  Created by Chad Morris on 5/2/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectListViewController : UITableViewController < UITableViewDataSource
                                                             , UITableViewDelegate
                                                             , UINavigationControllerDelegate
                                                             , UIImagePickerControllerDelegate>
{
    NSIndexPath * _itemToDelete;
    
}

@property (nonatomic , assign) BOOL shouldShowCameraControl;
@property (nonatomic , assign) BOOL shouldShowSignup;

@property (nonatomic , retain) UITableView * tableView;
@property (nonatomic , retain) NSMutableArray * tableDataSource;

@end
