//
//  LoginViewController.m
//  Contxt
//
//  Created by Chad Morris on 4/12/13.
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import "LoginViewController.h"
#import "UINavigationController+NavigationControllerTransition.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction)close:(id)sender
{
    [self.navigationController popWithTransition:UIViewAnimationTransitionCurlUp animationDuration:TRANSITION_DURATION_DEFAULT animated:NO];
    return;
}

@end
