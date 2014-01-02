//
//  SignUpViewController.m
//  Contxt
//
//  Created by Chad Morris on 4/12/13.
//  Copyright (c) 2013 Beacon Dynamic Systems LLC. All rights reserved.
//

#import "SignUpViewController.h"
#import "ServerComms.h"
#import "DataController.h"
#import "LoginCreds.h"
#import "Utilities.h"
#import "NSString+CMContains.h"
#import "InputCell.h"

#import "ACPButton.h"
#import "AFNetworking.h"
#import "DejalActivityView.h"

#define TF_EMAIL_TAG        101
#define TF_PASSWORD_TAG     102
#define TF_PWDCONFIRM_TAG   103

@interface SignUpViewController ()
- (BOOL)fieldIsBlank:(UITextField *)textField;
- (void)addErrorText:(NSString *)msg;
- (void)setImageView:(UIImageView *)img toStatus:(EStatusImage)imageStatus;
- (void)setTextField:(UITextField *)textField withError:(NSString *)msg;
@end

@implementation SignUpViewController

@synthesize txtf_email, txtf_password, txtf_pwdConfirm, txtv_error, imgv_email, imgv_password, imgv_pwdConfirm, lbl_info;
@synthesize tableDataSource , tableView;


#pragma mark - UITextField Delegate Methods

- (void)setButtonColorDefault:(ACPButton *)btn
{
    [btn setStyleType:ACPButtonGrey];
    [btn setNeedsDisplay];
}

- (void)setButtonColorError:(ACPButton *)btn
{
    [btn setStyleType:ACPButtonCancel];
    [btn setNeedsDisplay];
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    [self addErrorText:@""];
    
    ACPButton * btn;
    if( textField.tag == TF_EMAIL_TAG )
    {
        _img_emailStatus.image = nil;
        btn = _btn_email;
    }
    else if( textField.tag == TF_PASSWORD_TAG )
        btn = _btn_password;
    else if( textField.tag == TF_PWDCONFIRM_TAG )
        btn = _btn_pwdConfirm;
    else
        return;

    [self setButtonColorDefault:btn];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    ACPButton * btn;
    if( textField.tag == TF_EMAIL_TAG )
    {
        if( ![Utilities validateEmail:txtf_email.text] )
        {
            [self setTextField:txtf_email withError:@"Please enter a valid email address."];
        }
        else
        {
            _img_emailStatus.image = nil;
            btn = _btn_email;
        
            if( ![self fieldIsBlank:txtf_email] && [Utilities validateEmail:txtf_email.text] )
            {
                [_actview_emailStatus startAnimating];
                
                NSDictionary * params = @{ @"type":@"EMAIL_CHECK" , @"email":self.txtf_email.text };
                
                [[ServerComms sharedComms] processValidateEmail:params];
            }
        }
    }
    else if( textField.tag == TF_PASSWORD_TAG )
        btn = _btn_password;
    else if( textField.tag == TF_PWDCONFIRM_TAG )
    {
        btn = _btn_pwdConfirm;
        if( ![txtf_password.text isEqualToString:txtf_pwdConfirm.text] )
        {
            [self setTextField:txtf_pwdConfirm withError:@"Passwords must match."];
        }
    }
}

- (void)addErrorText:(NSString *)msg
{
    lbl_info.text = msg;
}

- (BOOL)fieldIsBlank:(UITextField *)textField
{
    return (!textField || !textField.text || [textField.text length] == 0);
}

- (void)setTextField:(UITextField *)textField withError:(NSString *)msg
{
    [self addErrorText:msg];

    ACPButton * btn;
    if( textField.tag == TF_EMAIL_TAG )
        btn = _btn_email;
    else if( textField.tag == TF_PASSWORD_TAG )
        btn = _btn_password;
    else if( textField.tag == TF_PWDCONFIRM_TAG )
        btn = _btn_pwdConfirm;
    else
        return;
    
    [self setButtonColorError:btn];
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)login:(id)sender
{
    [self addErrorText:@""];
  
    bool error = false;
    txtv_error.text = @"";
    
    if( [self fieldIsBlank:txtf_email] )
    {
        error = true;
        [self setTextField:txtf_email withError:@"Email required."];
    }
    else
    if( ![Utilities validateEmail:txtf_email.text] )
    {
        error = true;
        [self setTextField:txtf_email withError:@"Please enter a valid email address."];
    }
    else
    if( [self fieldIsBlank:txtf_password] )
    {
        error = true;
        [self setTextField:txtf_password withError:@"Password required."];
    }
    else
    if( [self fieldIsBlank:txtf_pwdConfirm] )
    {
        error = true;
        [self setTextField:txtf_pwdConfirm withError:@"Please confirm password."];
    }
    else
    if( ![txtf_password.text isEqualToString:txtf_pwdConfirm.text] )
    {
        error = true;
        [self setTextField:txtf_pwdConfirm withError:@"Passwords must match."];
    }
    
    if( !error )
    {
        [DejalWhiteActivityView activityViewForView:self.view withLabel:@"Processing..."];

        [[DataController sharedController] resetCredParams];
        if( [[DataController sharedController] signupUser:self.txtf_email.text withPassword:self.txtf_password.text] )
        {
            NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObject:@"SIGN_UP" forKey:@"type"];
            
            [[ServerComms sharedComms] processSignUp:params];
        }
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[ServerComms sharedComms] addObserver:self];
    
    self.tableView.delegate = self;

    self.tableDataSource = [[NSMutableArray alloc] initWithObjects:@"email" , @"pwd" , @"cnfrm pwd", nil];

    [self setButtonColorDefault:_btn_email];
    self.txtf_email.tag = TF_EMAIL_TAG;

    [self setButtonColorDefault:_btn_password];
    self.txtf_password.tag = TF_PASSWORD_TAG;
    
    [self setButtonColorDefault:_btn_pwdConfirm];
    self.txtf_pwdConfirm.tag = TF_PWDCONFIRM_TAG;
    
    [_actview_emailStatus stopAnimating];
    
    [_btn_submit setStyleType:ACPButtonBlue];
    
//    lbl_info.textColor = [Utilities contxtIconColor];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[ServerComms sharedComms] removeObserver:self];
    
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    txtf_email.delegate = self;
    txtf_password.delegate = self;
    txtf_pwdConfirm.delegate = self;
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImageView:(UIImageView *)img toStatus:(EStatusImage)imageStatus
{
/*    if( imageStatus == EStatusImageNone )
        img.hidden = TRUE;
    else
        img.hidden = FALSE;
 
    [img setImage:[Utilities imageForStatus:imageStatus]]; */
}


#pragma mark -
#pragma mark ServerCommsObserver Methods

- (void)completedUserValidationRequest:(bool)status message:(NSString *)message
{
    [_actview_emailStatus stopAnimating];
    if( status )
    {
//        [_img_emailStatus setImage:[UIImage imageNamed:@"status_ok.png"]];
        [self setButtonColorDefault:_btn_email];
    }
    else
    {
//        [_img_emailStatus setImage:[UIImage imageNamed:@"status_error.png"]];
        [self addErrorText:message];
        [self setButtonColorError:_btn_email];
    }
}

- (void)completedSignUpRequest:(bool)status message:(NSString *)message
{
    [DejalActivityView removeView];
    
    if( status )
    {
        [[DataController sharedController] setUserValidated];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Signing Up..."
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    }
}

- (void)serverErrorOccurred:(NSString *)error
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Signing Up..."
                                                 message:error
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}


- (void)receivedData:(NSData *)data forURL:(NSURL *)url
{
    NSString * sData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    if( [[url absoluteString] containsString:@"usernameAvailable.php"] )
    {
        if( [sData containsString:@"TRUE"] )
            [self setImageView:imgv_email toStatus:EStatusImageOK];
        else
            [self setImageView:imgv_email toStatus:EStatusImageError];
    }
}

- (void)connectionFailedWithError:(NSError *)error url:(NSURL *)url
{
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    if( txtv_error )
        txtv_error.text = @"Error occurred. Please try again.";
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


#pragma mark - Table view delegate

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 return _cellHeight; //returns floating point which will be used for a cell row height at specified row index
 }*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"InputCell";
    
    InputCell *cell = (InputCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if( !cell )
	{
        NSString * nib = CellIdentifier;
        
        if( !nib )
            return [[UITableViewCell alloc] init];
        
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nib owner:nil options:nil];
		
		for( id currentObject in nibObjects )
		{
			if( [currentObject isKindOfClass:[InputCell class]] )
			{
				cell = (InputCell *)currentObject;
			}
		}
	}
	
	if( !cell )
        return [[UITableViewCell alloc] init];
	
    switch (indexPath.row) {
        case 0:
            cell.label.text = @"Email";
            break;
        case 1:
            cell.label.text = @"Password";
            cell.details.secureTextEntry = TRUE;
            break;
        case 2:
            cell.label.text = @"Confirm Password";
            cell.details.secureTextEntry = TRUE;
            break;
            
        default:
            break;
    }
    cell.details.tag = indexPath.row;
    
    cell.detailTextLabel.text = [self.tableDataSource objectAtIndex:indexPath.row];
    NSLog( @"enabled: %i" , cell.detailTextLabel.isEnabled );

        // Configure the cell...
    if( !cell )
        return [[UITableViewCell alloc] init];
    
    return (UITableViewCell *)cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row");
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"All Fields Required";
}


@end
