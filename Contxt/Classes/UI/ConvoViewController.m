//
//  ViewController.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

//
// Images used in this example by Petr Kratochvil released into public domain
// http://www.publicdomainpictures.net/view-image.php?image=9806
// http://www.publicdomainpictures.net/view-image.php?image=1358
//

#import "ConvoViewController.h"
#import "AnnotationViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"

#import "DataController.h"
#import "ConversationThread.h"
#import "ConversationMessage.h"
#import "ImageInfo.h"
#import "Utilities.h"

#import "DWTagList.h"
#import "ShareView.h"

#import "KGModal.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

#import "COPeoplePickerViewController.h"
#import "IBActionSheet.h"

#import "ServerComms.h"
#import "ServerCommsObserver.h"

#define kCameraControlIndex 0
#define kPhotoAlbumIndex 1

@interface ConvoViewController () <COPeoplePickerViewControllerDelegate , UIActionSheetDelegate , ServerCommsObserver>
{
    IBOutlet UIBubbleTableView *bubbleTable;
    IBOutlet UIView *textInputView;
    IBOutlet UITextField *textField;
    
    NSMutableArray *bubbleData;
}

@end

@implementation ConvoViewController

@synthesize annotation;
@synthesize delegate;


#pragma mark - ServerCommsObserver Methods

- (void)serverErrorOccurred:(NSString *)error
{}

- (void)newConvoMessages:(NSArray *)keys
{
    for( NSString * key in keys )
    {
        ConversationMessage * message = [[DataController sharedController] convoMessageForKey:key];
        
        if( !message )
            continue;
        
        if( [self.annotation.convoThread.key isEqualToString:message.parentConvoThread.key] )
        {
            [self refreshAll];
            break;
        }
    }
}

#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( [[alertView title] isEqualToString:@"Remove Participant?"] && buttonIndex > 0 )
	{
        if( _emailToRemove )
        {
            [[DataController sharedController] removeParticipantByEmail:_emailToRemove fromConversationThread:self.annotation.convoThread];
            [[DataController sharedController] saveContext];
            
            [[ServerComms sharedComms] removeParticipants:@[_emailToRemove] forConvoThreadKey:self.annotation.convoThread.key];
            
            [_participants removeObject:_emailToRemove];
            [self.tagListView setTags:_participants];
        }
        
        _emailToRemove = nil;
	}
    else if( [[alertView title] isEqualToString:@"Delete Thread?"] && buttonIndex > 0 )
    {
        if( self.delegate )
            [self.delegate willDeleteAnnotationWithKey:self.annotation.key];
        
        [[DataController sharedController] deleteAnnotation:self.annotation];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - DWTagListViewDelegate Methods

- (void)selectedTag:(NSString*)tagName
{
    _emailToRemove = tagName;
    
    if( [self.annotation.convoThread.owner isEqualToString:_myUsername] )
    {
        NSString* message = [NSString stringWithFormat:@"Remove '%@' participant from conversation?",tagName];
        
        // Verify Delete
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Remove Participant?"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Remove",nil];
        
        [alertView show];
    }
    else
    {
        NSString* message = [NSString stringWithFormat:@"You do not have permissions to remove participants from this thread."];
        
        // Verify Delete
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:nil];
        
        [alertView show];
    }
}

#pragma mark - UIViewController Methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[DataController sharedController] addObserver:self];
    [[ServerComms sharedComms] addObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if( _shouldScrollToBottom )
    {
        [bubbleTable scrollToBottom];
        _shouldScrollToBottom = NO;
    }
}

- (void)refreshAll
{
    _messages = [NSMutableArray arrayWithArray:[[DataController sharedController] convoMessagesForConvoThread:annotation.convoThread.key]];
    
    bubbleData = [[NSMutableArray alloc] init];
    
    BOOL needToSave = FALSE;
    
    for( ConversationMessage * message in _messages )
    {
        if( [message.unread boolValue] )
        {
            needToSave = TRUE;
            message.unread = [NSNumber numberWithBool:FALSE];
        }
        
        [self addBubbleDataWithMessage:message];
    }

    if( needToSave )
        [[DataController sharedController] saveContext];

    [bubbleTable reloadData];
    [bubbleTable scrollToBottom];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _shouldScrollToBottom = YES;
    
    _myUsername = [[DataController sharedController] signedUpUser];
    
    [self refreshAll];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                           target:self
                                                                                           action:@selector(deleteThread)];
    
    
    bubbleTable.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    bubbleTable.snapInterval = 1;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    
    bubbleTable.showAvatars = NO;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    [bubbleTable reloadData];
    [bubbleTable scrollToBottom];
    self.navigationItem.title = @"conversation";
    
    // Keyboard events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    _participants = [[NSMutableArray alloc] init];
    
    for( ContxtContact * contact in self.annotation.convoThread.participants )
    {
        if( contact.email && [contact.email length] > 0 )
            [_participants addObject:contact.email];
    }
    
    if( ![_participants containsObject:self.annotation.convoThread.owner] )
        [_participants addObject:self.annotation.convoThread.owner];
    
    [_participants removeObject:@""];
    [self.tagListView setAutomaticResize:NO];
    [self.tagListView setTagDelegate:self];
    [self.tagListView setTags:_participants];
    [self.tagListView setTagBackgroundColor:[UIColor colorWithRed:0.40 green:0.80 blue:1.00 alpha:0.5]];
    
    UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(0, self.tagListView.frame.origin.y+self.tagListView.frame.size.height+1
                                                                  , 320 , 1)];
    separator.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:separator];

    [bubbleTable reloadData];
    [bubbleTable scrollToBottom];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[ServerComms sharedComms] removeObserver:self];
    [[DataController sharedController] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSBubbleType)bubbleTypeForMessage:(ConversationMessage *)message
{
    NSBubbleType type = BubbleTypeSomeoneElse;
    
    if( [message.owner isEqualToString:_myUsername] && [_myUsername length] > 0 )
        type = BubbleTypeMine;
    
    return type;
}

- (void)addBubbleDataWithMessage:(ConversationMessage *)message
{
    if( message.text && [message.text length] > 0 )
    {
        NSBubbleType type = [self bubbleTypeForMessage:message];
        NSBubbleData * bubble = [NSBubbleData dataWithText:message.text date:message.dateCreated type:type];
        bubble.source = message.owner;
        [bubbleData addObject:bubble];
    }
    else if( message.image || message.imageInfoKey )
    {
        if( message.imageInfoKey && !message.image )
        {
            NSString * imageURL = [ServerComms urlStringForImageKey:message.imageInfoKey extension:message.imageInfoExt];
            
            NSURLRequest *requestImageURL = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
            AFImageRequestOperation * imageOperation;
            imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:requestImageURL
                  imageProcessingBlock:^UIImage *(UIImage *image) {
                      return image;
                  } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                      ImageInfo * imageInfo = [Utilities createImageInfoFromImage:image asPreview:NO asThumbnail:NO preserveSize:YES];
                      
                      if( imageInfo )
                      {
                          [[DataController sharedController] associateImageInfo:imageInfo withMessage:message];
                          [[DataController sharedController] saveContext];
                          
                          [self addBubbleDataWithImageMessage:message];
                      }
                      
                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                      NSLog( @"Image DOWNLOAD error... \n%@" , [NSString stringWithFormat:@"%@" , error] );
                      
                      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Downloading Image"
                                                                   message:@"An error occurred downloading image. Please try again later."
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK" otherButtonTitles:nil];
                      [av show];
            }];

            [imageOperation start];
        }
        else
        {
            [self addBubbleDataWithImageMessage:message];
        }
    }
}

- (void)addBubbleDataWithImageMessage:(ConversationMessage *)message
{
    NSBubbleType type = [self bubbleTypeForMessage:message];
    UIImage * image = [UIImage imageWithContentsOfFile:message.image.path];

    NSBubbleData * bubble = [NSBubbleData dataWithImage:image date:message.dateCreated type:type];
    bubble.source = message.owner;
    [bubbleData addObject:bubble];
    
    [self addTouchGestureToBubble:bubble];
}

- (void)deleteThread
{
    if( ![self.annotation.convoThread.owner isEqualToString:_myUsername] )
    {
        NSString* message = @"You do not have permissions to delete this thread. Only the owner may delete the thread.";
        
        // Verify Delete
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission Denied"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        [alertView show];
    }
    else
    {
        NSString* message = @"All messages will be deleted. This CANNOT be undone. Delete?";
        
        // Verify Delete
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Thread?"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Delete",nil];
        
        [alertView show];
    }
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y -= kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height -= kbSize.height;
        bubbleTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y += kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height += kbSize.height;
        bubbleTable.frame = frame;
    }];
}


#pragma mark - ImagePicker Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    ImageInfo * imageInfo = [Utilities createImageInfoFromImage:image
                                                      asPreview:NO
                                                    asThumbnail:NO];
    
    imageInfo.owner = _myUsername;

    ConversationMessage * message = [[DataController sharedController] newConversationMessage];
    message.owner = _myUsername;
    
    [[DataController sharedController] associateImageInfo:imageInfo withMessage:message];
    [[DataController sharedController] associateMessage:message withThread:annotation.convoThread];
    [[DataController sharedController] saveContext];
    
    [[ServerComms sharedComms] saveConvoMessage:message];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSBubbleData *sayBubble = [NSBubbleData dataWithImage:image date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    sayBubble.source = _myUsername;
    [bubbleData addObject:sayBubble];
    [bubbleTable reloadData];
    [bubbleTable scrollToBottom];
    
    [self addTouchGestureToBubble:sayBubble];
}

- (void)addTouchGestureToBubble:(NSBubbleData *)oBubbleData
{
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchEventOnImage:)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    //Don't forget to set the userInteractionEnabled to YES, by default It's NO.
    oBubbleData.view.userInteractionEnabled = YES;
    [oBubbleData.view addGestureRecognizer:tapRecognizer];
}

- (void)touchEventOnImage:(id)sender
{
    if( [sender isKindOfClass:[UIGestureRecognizer class]] )
    {
        UIGestureRecognizer * recognizer = (UIGestureRecognizer *)sender;
        
        if( [recognizer.view isKindOfClass:[UIImageView class]] )
        {
            UIImageView * imageView = [[UIImageView alloc] initWithImage:((UIImageView *)recognizer.view).image];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
            imageView.backgroundColor = [UIColor blackColor];
            // Remove the corner radius applied in the NSBubbleData class.
            imageView.layer.cornerRadius = 0.0;
            
            UIViewController * vc = [[UIViewController alloc] init];
            vc.view = imageView;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    
    // Unable to save the image
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Unable to save image."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    else // All is well
        alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                           message:@"Image saved."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    [alert show];
}




#pragma mark - IBActionSheetDelegate Methods
-(void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog( @"button index: %i" , buttonIndex );
    if( buttonIndex == kPhotoAlbumIndex )
        [self launchPhotoAlbumControl];
    else if( buttonIndex == kCameraControlIndex )
        [self launchCameraControl];
}

/*- (void)actionSheet:(RDActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == kPhotoAlbumIndex )
        [self launchPhotoAlbumControl];
    else if( buttonIndex == kPhotoPickerIndex )
        [self launchCameraControl];
}*/


#pragma mark - ShareViewDelegate Methods

- (void)hideContainingView:(ShareView *)shareView
{
    [[KGModal sharedInstance] hide];
}

- (void)shareWithText:(NSString *)text sender:(ShareView *)shareView
{
    [[KGModal sharedInstance] hide];
    
    if( shareView && shareView.email )
    {
        // ADD ContxtContact TO THIS THREAD
        ContxtContact * contact = [[DataController sharedController] contactWithEmail:shareView.email.text];
        
        // @TODO: Add Server code here
        if( [[DataController sharedController] shareConversationThread:self.annotation.convoThread withContact:contact] )
        {
            [_participants addObject:shareView.email.text];
            [self.tagListView setTags:_participants];
        }
    }
}


#pragma mark - Actions

- (void)launchCameraControl
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)launchPhotoAlbumControl
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - COPeoplePickerViewControllerDelegate Methods

- (void)peoplePickerViewControllerDidFinishPicking:(COPeoplePickerViewController *)controller
{
    NSMutableArray * emailList = [[NSMutableArray alloc] init];
    
    for( CORecord * record in controller.selectedRecords )
    {
        NSLog( @"title: %@" , record.title );
        NSLog( @"name: %@" , record.person.fullName );
        
        [emailList addObject:record.title];
    }
    
    [controller dismissViewControllerAnimated:YES completion:^{
        
        for( NSString * email in emailList )
        {
            // ADD ContxtContact TO THIS THREAD
            ContxtContact * contact = [[DataController sharedController] contactWithEmail:email];
            
            if( [[DataController sharedController] shareConversationThread:self.annotation.convoThread withContact:contact] )
            {
                [_participants addObject:email];
                [self.tagListView setTags:_participants];
                [[DataController sharedController] saveContext];
            }
        }
        
        // Update server
        [[ServerComms sharedComms] addParticipants:emailList forConvoThreadKey:self.annotation.convoThread.key];
    }];
}

- (IBAction)showAddContact:(id)sender
{
    COPeoplePickerViewController * ppvc = [[COPeoplePickerViewController alloc] init];
    ppvc.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:ppvc];
    navigationController.navigationItem.title = @"Share with...";
    ppvc.navigationItem.title = @"Share with...";
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (IBAction)showActionSheet:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    [actionSheet showInView:self.navigationController.view];

    
/*    RDActionSheet *actionSheet = [[RDActionSheet alloc] initWithTitle:@"Select a source for media"
                                                    cancelButtonTitle:@"Cancel"
                                                   primaryButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo", @"Choose Existing", nil]; */
//    actionSheet.delegate = self;
//    [actionSheet showFrom:self.view];
}


- (IBAction)sayPressed:(id)sender
{
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    if( [textField.text isEqualToString:@""] )
    {
        [textField resignFirstResponder];
        return;
    }
    
    ConversationMessage * message = [[DataController sharedController] newConversationMessage];
    message.text = textField.text;
    message.owner = _myUsername;
    
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:textField.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    sayBubble.source = _myUsername;

    textField.text = @"";
    [textField resignFirstResponder];

    [bubbleData addObject:sayBubble];
    [bubbleTable reloadData];
    [bubbleTable scrollToBottom];
    
    [[DataController sharedController] associateMessage:message withThread:annotation.convoThread];
    [[DataController sharedController] saveContext];

    [[ServerComms sharedComms] saveConvoMessage:message];
}


#pragma mark -
#pragma mark ABPeoplePickerNavigationController Delegate Methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person
								property:(ABPropertyID)property
							  identifier:(ABMultiValueIdentifier)identifier
{
	if( nil == person || kABPersonEmailProperty != property )
		return NO;
	
    //    NSString* name = CFBridgingRelease(ABRecordCopyCompositeName( person ));
    
    if( property == kABPersonEmailProperty )
	{
        [[KGModal sharedInstance] showWithContentView:_shareView];
        
        /*
         * Set up an ABMultiValue to hold the address values; copy from address
         * book record.
         */
        ABMultiValueRef multi = ABRecordCopyValue(person, property);
		
        // Set up an NSArray and copy the values in.
        NSArray *emailAddresses = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(multi));
        CFRelease(multi);
        
		// Figure out which values we want and store the index.
        const NSUInteger theIndex = ABMultiValueGetIndexForIdentifier(multi, identifier);
        
		// Set up an NSDictionary to hold the contents of the array.
        NSString * emailAddress = [emailAddresses objectAtIndex:theIndex];
        
        NSLog( @"email addres: %@" , emailAddress );
        
        if( _shareView )
            _shareView.email.text = emailAddress;
		
        // Return to the main view controller.
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
	
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	return YES;
}


@end
