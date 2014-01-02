//
//  ConvoListViewController.h
//  Contxt
//
//  Created by Chad Morris on 6/6/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataChangeObserver.h"

@interface ConvoListViewController : UITableViewController <UITableViewDataSource , UITableViewDelegate , DataChangeObserver>

@property (nonatomic , retain) UITableView * tableView;
@property (nonatomic , retain) NSMutableArray * tableDataSource;
@property (nonatomic , strong) NSString * docKey;

@end
