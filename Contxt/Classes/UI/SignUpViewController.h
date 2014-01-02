//
//  SignUpViewController.h
//  Contxt
//
//  Created by Chad Morris on 4/12/13.
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommsObserver.h"
#import "ServerComms.h"

#import "MBProgressHUD.h"

@class ACPButton;

@interface SignUpViewController : UIViewController < UITextFieldDelegate
                                                   , ServerCommsObserver
                                                   , MBProgressHUDDelegate
                                                   , UITableViewDelegate
                                                   , UITableViewDataSource>
{
    IBOutlet ACPButton * _btn_email;
    IBOutlet ACPButton * _btn_password;
    IBOutlet ACPButton * _btn_pwdConfirm;
    IBOutlet UIImageView * _img_emailStatus;
    IBOutlet UIActivityIndicatorView * _actview_emailStatus;
    IBOutlet ACPButton * _btn_submit;

    MBProgressHUD * _hud;
    
    ServerComms * _serverComms;
}

@property (nonatomic , strong) IBOutlet UILabel * lbl_info;

@property (nonatomic , strong) IBOutlet UITextField * txtf_email;
@property (nonatomic , strong) IBOutlet UITextField * txtf_password;
@property (nonatomic , strong) IBOutlet UITextField * txtf_pwdConfirm;

@property (nonatomic , strong) IBOutlet UIImageView * imgv_email;
@property (nonatomic , strong) IBOutlet UIImageView * imgv_password;
@property (nonatomic , strong) IBOutlet UIImageView * imgv_pwdConfirm;

@property (nonatomic , strong) IBOutlet UITextView * txtv_error;

@property (nonatomic , strong) IBOutlet UITableView * tableView;
@property (nonatomic , retain) IBOutlet NSMutableArray * tableDataSource;


- (IBAction)login:(id)sender;

@end
