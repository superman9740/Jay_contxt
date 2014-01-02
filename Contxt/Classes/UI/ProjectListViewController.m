//
//  ProjectListViewController.m
//  Contxt
//
//  Created by Chad Morris on 5/2/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "ProjectListViewController.h"
#import "DataController.h"
#import "Project.h"
#import "ProjectDetailsCell.h"
#import "Utilities.h"
#import "SignUpViewController.h"
#import "ProjectViewController.h"
#import "AnnotationDocument.h"
#import "AnnotationDocListViewController.h"

@interface ProjectListViewController () <MCSwipeTableViewCellDelegate>
- (void)launchCameraControl:(BOOL)animated;
- (void)launchCameraControlWithAnimation;
- (void)launchNewProjectView;
- (void)launchProjectViewWithKey:(NSString *)key;
- (void)refresh;
- (void) deleteItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation ProjectListViewController

@synthesize shouldShowCameraControl , shouldShowSignup;
@synthesize tableDataSource , tableView;


#pragma mark - Custom Actions

- (void)refresh
{
    [[DataController sharedController].managedObjectContext reset];
    self.tableDataSource = [[NSMutableArray alloc] initWithArray:[[DataController sharedController] projectList]];
    [self.tableView reloadData];
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
    
//#ifndef NDEBUG
//    return;
//#endif
    
    // Create image picker controller
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Set source to the camera
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    
    // Delegate is self
    imagePicker.delegate = self;
    
    // Allow editing of image ?
    imagePicker.allowsEditing = NO;
    
    // Show image picker
    [self presentViewController:imagePicker animated:animated completion:nil];
}

#pragma mark - ImagePicker Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    ImageInfo * imageInfo = [Utilities createImageInfoFromImage:image
                                                      asPreview:YES
                                                    asThumbnail:YES];
    
    AnnotationDocument * annDoc = [[DataController sharedController] newAnnotationDocument];
    Project * untitledProject = [[DataController sharedController] untitledProject];

    [[DataController sharedController] associateImageInfo:imageInfo withAnnotationDocument:annDoc];
    [[DataController sharedController] associateAnnotationDocument:annDoc withProject:untitledProject];
    [[DataController sharedController] saveContext];
    
    [picker dismissViewControllerAnimated:NO completion:nil];

    AnnotationDocListViewController * vc = [[AnnotationDocListViewController alloc] init];
    vc.projectKey = UNTITLED_PROJECT_GUID;

    [self.navigationController pushViewController:vc animated:YES];
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
	if( [[alertView title] isEqualToString:@"Delete Project?"] && buttonIndex > 0 && _itemToDelete )
	{
        [self deleteItemAtIndexPath:_itemToDelete];
	}
    else
    {
        [self.tableView reloadData];
    }
	
    _itemToDelete = nil;
}


#pragma mark - MCSwipeTableViewCellDelegate

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell
           didTriggerState:(MCSwipeTableViewCellState)state
                  withMode:(MCSwipeTableViewCellMode)mode
{
    if (mode == MCSwipeTableViewCellModeExit)
    {
        _itemToDelete = [self.tableView indexPathForCell:cell];
//        [self deleteItemAtIndexPath:[self.tableView indexPathForCell:cell]];
        
        NSString* message = @"ALL project data will be deleted. This action can not be undone. Delete?";
        
        // Verify Delete
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Project?"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel" 
                                                  otherButtonTitles:@"Delete",nil];
        
        [alertView show];
    }
}

- (void) deleteItemAtIndexPath:(NSIndexPath *)indexPath
{
    Project * p = [self.tableDataSource objectAtIndex:indexPath.row];
    
    if( [p.key isEqualToString:UNTITLED_PROJECT_GUID] )
    {
        NSString* message = [NSString stringWithFormat:@"The \"%@\" is a default project and cannot be deleted.",p.title];
        
        // Verify Delete
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Default Project"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
    }
    else
    {
        [[DataController sharedController].managedObjectContext deleteObject:[self.tableDataSource objectAtIndex:indexPath.row]];
        [[DataController sharedController] saveContext];
        
        [self.tableDataSource removeObjectAtIndex:indexPath.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Lifecycle Methods

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.shouldShowCameraControl = FALSE;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSLog( @"ProjectListVC viewDidAppear" );

//    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // @NOTE: This section is a hack to not show the ProjectListViewController
    //   Customer has de-scoped for now, but may want this later, so leaving in place
    if( !self.shouldShowSignup && !self.shouldShowCameraControl )
    {
        AnnotationDocListViewController * vc = [[AnnotationDocListViewController alloc] init];
        vc.projectKey = [[DataController sharedController] untitledProject].key;
        
        [self.navigationController pushViewController:vc animated:NO];
    }
    else
    {
        [self refresh];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    else
    {
        AnnotationDocListViewController * vc = [[AnnotationDocListViewController alloc] init];
        vc.projectKey = [[DataController sharedController] untitledProject].key;
        
        [self.navigationController pushViewController:vc animated:NO];
    }


    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(launchNewProjectView)];

    //    self.navigationItem.hidesBackButton = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                          target:self
                                                                                          action:@selector(launchCameraControlWithAnimation)];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view = self.tableView;
    
    self.navigationItem.title = @"Projects";

    [self refresh];
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
    return [self.tableDataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"ProjectDetailsCell" owner:nil options:nil];
    if( [nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[ProjectDetailsCell class]] )
    {
        ProjectDetailsCell * cell = (ProjectDetailsCell *)[nibObjects objectAtIndex:0];
        return cell.frame.size.height;
    }
    else
        return 66.0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"ProjectDetailsCell";
    
    ProjectDetailsCell *cell; // = (ProjectDetailsCell *)[tv dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if( !cell )
	{
        NSString * nib = CellIdentifier;
        
        if( !nib )
            return [[UITableViewCell alloc] init];
        
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nib owner:nil options:nil];
		
		for( id currentObject in nibObjects )
		{
			if( [currentObject isKindOfClass:[ProjectDetailsCell class]] )
			{
				cell = (ProjectDetailsCell *)currentObject;
			}
		}
	}
	
	if( !cell )
        return [[UITableViewCell alloc] init];
    
    // Configure the cell...
    Project * p = (Project *)[self.tableDataSource objectAtIndex:indexPath.row];
    
    if( !p )
        return cell;
    
    cell.title.text = p.title;
    cell.updateDate.text = [Utilities dateToString:p.dateUpdated];
    
    if( p.thumbnail )
    {
        NSLog( @"Image to use: %@" , p.thumbnail.thumbPath );
        
        UIImage * image = [UIImage imageWithContentsOfFile:p.thumbnail.thumbPath];
        
        if( image )
            [cell.preview setImage:image];
    }
    else
        NSLog( @"No thumbnail associated with project %@" , p.title );
    

    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    [cell setDelegate:self];
    [cell setFirstStateIconName:@"cross.png"
                     firstColor:[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
            secondStateIconName:nil
                    secondColor:nil
                  thirdIconName:nil
                     thirdColor:nil
                 fourthIconName:nil
                    fourthColor:nil];
    [cell setMode:MCSwipeTableViewCellModeExit];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
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

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self launchProjectViewWithKey:((Project *)[self.tableDataSource objectAtIndex:indexPath.row]).key];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AnnotationDocListViewController * vc = [[AnnotationDocListViewController alloc] init];
//    vc.project = [self.tableDataSource objectAtIndex:indexPath.row];
    vc.projectKey = ((Project *)[self.tableDataSource objectAtIndex:indexPath.row]).key;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)launchNewProjectView
{
    [self launchProjectViewWithKey:nil];
}

- (void)launchProjectViewWithKey:(NSString *)key
{
    ProjectViewController * pvc = [[ProjectViewController alloc] initWithNibName:@"ProjectViewController" bundle:nil];
    pvc.projectKey = key;
    
    [self.navigationController pushViewController:pvc animated:YES];
}

@end
