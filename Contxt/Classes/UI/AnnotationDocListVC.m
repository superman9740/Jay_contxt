//
//  AnnotationDocListVC.m
//  Contxt
//
//  Created by Chad Morris on 10/19/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "AnnotationDocListVC.h"
#import "DataController.h"
#import "Utilities.h"
#import "ConvoListViewController.h"
#import "ServerComms.h"
#import "SignUpViewController.h"
#import "DocListTableCell.h"
#import "AnnotationDocument.h"
#import "AnnotationViewController.h"
#import "NSDictionary+CMJSON.h"

#define ITEMS_PER_ROW 2

@interface AnnotationDocListVC () <DocListCellDelegate>

@end

@implementation AnnotationDocListVC

@synthesize projectKey , delegate;
@synthesize shouldShowCameraControl , shouldShowSignup;
@synthesize enforceRefreshOnAppear = _refreshOnAppear;
@synthesize tableView;


#pragma mark - ServerCommsObserver Methods

- (void)serverErrorOccurred:(NSString *)error
{
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Server Error" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [av show];
}

- (void)newAnnotationDocs:(NSArray *)keys
{
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"New Image(s) Downloaded"
                                                  message:@"One or more new images were downloaded!"
                                                 delegate:self
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles: nil];
    [av show];
    
    [[DataController sharedController] saveContext];
    
    [self refreshDocumentsList];
}

- (void)newConvoMessages:(NSArray *)keys
{
    [self setChatIconUnread:YES];
}


#pragma mark - DocListCellDelegate Methods

- (void)deleteDoc:(NSString *)key
{
    _docKeyToDelete = key;
    
    NSString* message = @"This image, as well as ALL annotations will be deleted. This action can not be undone. Delete?";
    
    // Verify Delete
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Image?"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Delete",nil];
    
    [alertView show];
}

- (void)selectedDoc:(NSString *)key
{
    if( self.delegate )
    {
        [self.delegate annotationDocumentSelected:[[DataController sharedController] annotationDocumentForKey:key]];
        [self close];
    }
    else
    {
        AnnotationViewController * avc = [[AnnotationViewController alloc] initWithNibName:@"AnnotationViewController" bundle:nil];
        avc.doc = [[DataController sharedController] annotationDocumentForKey:key];
        [self.navigationController pushViewController:avc animated:YES];
    }
}


#pragma mark -

- (void)setChatIconUnread:(BOOL)unread
{
    NSString * file = @"chat-toolbar.png";
    
    if( unread )
        file = @"chat-toolbar-new.png";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:file]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(showMessages)];
}

- (void)close
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showMessages
{
    ConvoListViewController * vc = [[ConvoListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)launchCameraControlWithAnimation
{
    [self launchCameraControl:YES];
}

- (void)launchCameraControl:(BOOL)animated
{
#if( TARGET_IPHONE_SIMULATOR )
    return;
#endif
    
    // Create image picker controller
   
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Contxt" bundle:nil];
    cameraViewController = [sb instantiateViewControllerWithIdentifier:@"camera"];
    cameraViewController.delegate = self;
    [self presentViewController:cameraViewController animated:YES completion:nil];
}

- (void)launchPhotoAlbumControl
{
   // UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
   // imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
   // imagePicker.delegate = self;
   // imagePicker.allowsEditing = NO;
    
    //[self presentViewController:imagePicker animated:YES completion:nil];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Contxt" bundle:nil];
    cameraViewController = [sb instantiateViewControllerWithIdentifier:@"camera"];
    cameraViewController.delegate = self;
    [self presentViewController:cameraViewController animated:YES completion:nil];
    
}

#pragma mark - ImagePicker Delegate Methods

-(void)didFinishImageSelection:(NSArray*)images
{
    if(images.count == 0)
        return;
    
    UIImage *image = images[0];
    
    ImageInfo * imageInfo = [Utilities createImageInfoFromImage:image
                                                      asPreview:YES
                                                    asThumbnail:YES];
    
    AnnotationDocument * annDoc = [[DataController sharedController] newAnnotationDocument];
    Project * thisProject = [[DataController sharedController] projectForKey:self.projectKey];
    
    [[DataController sharedController] associateImageInfo:imageInfo withAnnotationDocument:annDoc];
    [[DataController sharedController] associateAnnotationDocument:annDoc withProject:thisProject];
    [[DataController sharedController] saveContext];
    
    [[ServerComms sharedComms] saveAnnotationDoc:annDoc];
    
    [cameraViewController dismissViewControllerAnimated:YES completion:nil];
    
    _refreshOnAppear = TRUE;
    
    
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    
    // Unable to save the image
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Unable to save image to Photo Album."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    else // All is well
        alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                           message:@"Image saved to Photo Album."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    [alert show];
}



#pragma mark -
#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( [[alertView title] isEqualToString:@"Delete Image?"] && buttonIndex > 0 && _docKeyToDelete && ![_docKeyToDelete isEqualToString:@""] )
	{
        AnnotationDocument * doc = [[DataController sharedController] annotationDocumentForKey:_docKeyToDelete];
        
        if( !self.delegate )
            [[DataController sharedController] deleteAnnotationDocument:doc];
        
        [self refreshDocumentsList];
	}
	
    _docKeyToDelete = nil;
}

#pragma mark -

- (void)refreshDocumentsList
{
    Project * project = ((Project *)[[DataController sharedController] projectForKey:self.projectKey]);
    
    if( !project )
        [self.navigationController popViewControllerAnimated:YES];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"image.dateCreated" ascending:NO];
    
    NSArray * sortedArray = [[project.annotationDocs allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
    _docList = [[NSMutableArray alloc] initWithArray:sortedArray];
    
    [self.tableView reloadData];
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _docList = [[NSMutableArray alloc] init];
    _itemsPerRow = ITEMS_PER_ROW;
    
    // Determine if other modal views should be shown
    if( self.shouldShowSignup || ![[DataController sharedController] isSignedUp] )
    {
        self.shouldShowSignup = FALSE;
        
        SignUpViewController *regVC = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
        [self.navigationController presentViewController:regVC animated:NO completion:nil];
    }
    else if( self.shouldShowCameraControl )
    {
        self.shouldShowCameraControl = FALSE;
        [self launchCameraControl:FALSE];
    }
    
    // Set up view/controller UI
    [self.view setBackgroundColor:[UIColor whiteColor]];
//    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = FALSE;
    self.navigationItem.title = @"contxt roll";
    
    UIBarButtonItem * album = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                            target:self
                                                                            action:@selector(launchPhotoAlbumControl)];
    
    UIBarButtonItem * camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                             target:self
                                                                             action:@selector(launchCameraControlWithAnimation)];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:album, camera, nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat-toolbar.png"]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(showMessages)];
    
    if( !self.projectKey )
        [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self refreshDocumentsList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( self.shouldShowCameraControl )
    {
        self.shouldShowCameraControl = FALSE;
        [self launchCameraControl:TRUE];
    }
    
    [[DataController sharedController] saveContext];
    

    [[ServerComms sharedComms] addObserver:self];
    
    [[ServerComms sharedComms] processPendingDeletes];
    [[ServerComms sharedComms] processPendingChanges];
    [[ServerComms sharedComms] checkForNewAnnotationDocuments];
    [[ServerComms sharedComms] checkForNewConversationMessages];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[ServerComms sharedComms] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[DataController sharedController] removeObserver:self];
    [[ServerComms sharedComms] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if( !_docList )
        return 0;
    
    // Integer Ceil: ceil(A/B) = (A+B-1)/B
    NSInteger rows = (_docList.count + _itemsPerRow) / _itemsPerRow;

    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DocListTableCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if( !cell )
	{
        if( !CellIdentifier )
            return [[UITableViewCell alloc] init];
        
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
		
		for( id currentObject in nibObjects )
		{
			if( [currentObject isKindOfClass:[DocListTableCell class]] )
			{
				cell = (DocListTableCell *)currentObject;
			}
		}
	}
	
	if( !cell )
        return [[UITableViewCell alloc] init];
    
    DocListTableCell * oCell = (DocListTableCell*)cell;

    oCell.delegate = self;
    
    // row 0 contains 0,1
    // row 1 contains 2,3
    // row 2 contains 4,5
    if( indexPath.row * _itemsPerRow < _docList.count )
    {
        // fill left hand side
        AnnotationDocument * doc = [_docList objectAtIndex:(indexPath.row * _itemsPerRow)];
        
        if( !doc )
            return oCell;
        
        oCell.leftDoc = doc;
    }
    if( indexPath.row * _itemsPerRow + 1 < _docList.count )
    {
        // fill left hand side
        AnnotationDocument * doc = [_docList objectAtIndex:(indexPath.row * _itemsPerRow + 1)];
        
        if( !doc )
            return oCell;
        
        oCell.rightDoc = doc;
    }
    
    return oCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DocListTableCell" owner:self options:nil];
    DocListTableCell *cell = (DocListTableCell *)[nib objectAtIndex:0];
    return cell.frame.size.height;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
