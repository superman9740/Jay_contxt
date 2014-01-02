//
//  AnnotationDocListViewController.m
//  ImageShowcase
//
//  Created by Chad Morris on 5/2/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "AnnotationDocListViewController.h"
#import "DataController.h"
#import "AnnotationViewController.h"
#import "ConvoListViewController.h"
#import "SignUpViewController.h"

#import "Utilities.h"


#import "JSONUtility.h"
#import "AFNetworking.h"
#import "AFImageRequestOperation.h"



#define IMAGE_SHOWCASE_CELL_SIZE_X (PREVIEW_WIDTH/2)
#define IMAGE_SHOWCASE_CELL_SIZE_Y (PREVIEW_HEIGHT/2)
#define IMAGE_SHOWCASE_SPACING ((320 - (IMAGE_SHOWCASE_CELL_SIZE_X * 2)) / 3)


@interface AnnotationDocListViewController ()
- (void)launchCameraControl:(BOOL)animated;
- (void)launchCameraControlWithAnimation;
- (void)addImagesForProject:(Project *)project;
@end

@implementation AnnotationDocListViewController

@synthesize projectKey , delegate;
@synthesize shouldShowCameraControl , shouldShowSignup;
@synthesize enforceRefreshOnAppear = _refreshOnAppear;


#pragma mark - DataChangeObserver Methods

- (void)serverErrorOccurred:(NSString *)error
{
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Server Error" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [av show];
}

- (void)newAnnotationDocs:(NSArray *)keys
{
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"New Images Downloaded"
                                                  message:[NSString stringWithFormat:@"%i new images downloaded!", keys.count]
                                                 delegate:self
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles: nil];
    [av show];
    
    [self refreshDocumentsList];
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

- (void)refreshDocumentsList
{
    [_imageShowCase deleteAllImages];
    [self addImagesForProject:((Project *)[[DataController sharedController] projectForKey:self.projectKey])];
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

- (void)launchPhotoAlbumControl
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - ImagePicker Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    ImageInfo * imageInfo = [Utilities createImageInfoFromImage:image
                                                      asPreview:YES
                                                    asThumbnail:YES];

    AnnotationDocument * annDoc = [[DataController sharedController] newAnnotationDocument];
    Project * thisProject = [[DataController sharedController] projectForKey:self.projectKey];

    [[DataController sharedController] associateImageInfo:imageInfo withAnnotationDocument:annDoc];
    [[DataController sharedController] associateAnnotationDocument:annDoc withProject:thisProject];
    [[DataController sharedController] saveContext];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    _refreshOnAppear = TRUE;

    NSLog( @"AnnotationViewController: REMOVE THIS SECTION >>>>>" );

/*    NSData *imageData = [NSData dataWithContentsOfFile:imageInfo.path];
    NSString * mimeType = [NSString stringWithFormat:@"image/%@", imageInfo.extension];
    NSString * filename = [NSString stringWithFormat:@"%@.%@", imageInfo.filename , imageInfo.extension];
    NSLog( @"%@" , filename );
    
    NSDictionary * params = [DataController sharedController].credParams;
    NSURLRequest *request = [[DataController sharedController].httpClient multipartFormRequestWithMethod:@"POST"
                                                                                                    path:@"/Contxt/tmp/uploadImage.php"
                                                                                              parameters:params
                                                                               constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:filename mimeType:mimeType];
    }];

    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             NSLog( @"\n\n JSON \n %@" , JSON );
         }

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             NSLog( @"JSON: \n%@" , JSON );
             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
         }
    ];

    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [operation start];*/
    
    NSLog( @"AnnotationViewController: <<<<< REMOVE THIS SECTION" );
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
	if( [[alertView title] isEqualToString:@"Delete Document?"] && buttonIndex > 0 && _showCaseCellToDelete )
	{
        AnnotationDocument * doc = [[DataController sharedController] annotationDocumentForKey:_showCaseCellToDelete.key];

        if( !self.delegate )
        {
            [[DataController sharedController].managedObjectContext deleteObject:doc];
            [[DataController sharedController] saveContext];
        }
        
        [_imageShowCase deleteImage:_showCaseCellToDelete];
	}
	
    _showCaseCellToDelete = nil;
}

- (void)addImagesForProject:(Project *)project
{
    if( !project )
        [self.navigationController popViewControllerAnimated:YES];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"image.dateCreated" ascending:NO];
    
    NSArray * sortedArray = [[project.annotationDocs allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
    _annotationDocs = [[NSMutableArray alloc] initWithArray:sortedArray];
    
    [_imageShowCase setDeleteMode:NO];
    
    for( AnnotationDocument * doc in _annotationDocs )
    {
        [_imageShowCase addImage:[UIImage imageWithContentsOfFile:doc.image.previewPath] withDocumentKey:doc.key];
    }
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_imageShowCase setDeleteMode:NO];

    if( [[DataController sharedController] doesNewMessageExist] )
        [self setChatIconUnread:YES];
    else
        [self setChatIconUnread:NO];
    
    // Set up Delegate
    [[DataController sharedController] addObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_imageShowCase setDeleteMode:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[DataController sharedController] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( self.shouldShowCameraControl )
    {
        self.shouldShowCameraControl = FALSE;
        [self launchCameraControl:TRUE];
    }

    [self refreshDocumentsList];
    
  
    // @TODO: Put this back in
//    [_serverComms checkForNewAnnotationDocuments];
    
    
    
    
    
    
/*
    NSDictionary * params = @{ @"type":@"ANNOTATION_DOC" , @"valid":@"YES" };
    NSURLRequest * requestImageInfoURL = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                                    path:@"/Contxt/tmp/getObject.php"
                                                                                              parameters:params];
    
    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestImageInfoURL
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             
             NSLog( @"\n\n IMAGE_INFO - JSON \n %@" , JSON );
             
             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             NSLog( @"%@: %@" , [JSONresponse objectForKey:@"status"] , [JSONresponse objectForKey:@"message"] );
             
             
             if( [[JSON objectForKey:@"type"] isEqualToString:@"IMAGE_INFO"] )
             {
                 ImageInfo * imageInfo = [JSONUtility imageInfoFromJSON:[JSON objectForKey:@"object"]];
                 if( !imageInfo )
                     NSLog( @"imageInfo was nil" );
                 else
                 {
                     NSString * imageURL = [[JSON objectForKey:@"object"] objectForKey:@"imageURL"];
                     
                     NSLog( @"\nIMAGE_INFO \nkey: %@ \nfilename: %@ \nextension: %@ \nowner: %@ \nimageURL: %@"
                           , imageInfo.key , imageInfo.filename , imageInfo.extension , imageInfo.owner , imageURL );
                     
                     NSURLRequest *requestImageURL = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
                     AFImageRequestOperation * imageOperation;
                     imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:requestImageURL
                       imageProcessingBlock:^UIImage *(UIImage *image) {
                           
                           NSLog( @"IMAGE SIZE BEFORE PROCESSING: w x h = %f , %f" , image.size.width , image.size.height);
                           
                                return image;
                     } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                         NSLog( @"IMAGE SIZE BEFORE SAVE: w x h = %f , %f" , image.size.width , image.size.height);
                         
                         [Utilities updateImageInfo:imageInfo withImage:image asPreview:YES asThumbnail:YES preserveSize:YES];
                         NSLog( @"Successfully downloaded image!" );

                         UIImage * image1 = [UIImage imageWithContentsOfFile:imageInfo.path];
                         NSLog( @"IMAGE SIZE AFTER SAVE: w x h = %f , %f" , image1.size.width , image1.size.height);

                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                         NSLog( @"Image DOWNLOAD error... \n%@" , [NSString stringWithFormat:@"%@" , error] );
                         
                         UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Posting JSON"
                                                                      message:[NSString stringWithFormat:@"%@",error]
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [av show];
                     }];
                     
                     [imageOperation start];
                 }
             }
             else if( [[JSON objectForKey:@"type"] isEqualToString:@"ANNOTATION_DOC"] )
             {
                 AnnotationDocument * doc = [JSONUtility annotationDocFromJSON:[JSON objectForKey:@"object"]];
                 
                 if( !doc )
                 {
                     NSLog( @"doc was nil" );
                 }
                 else
                 {
                     NSString * imageURL = [NSString stringWithFormat:@"%@/%@.%@"
                                                , @"http://www.1182angelina.com/Contxt/tmp/uploads"
                                                , doc.image.filename
                                                , doc.image.extension];
                     
                     NSURLRequest *requestImageURL = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
                     AFImageRequestOperation * imageOperation;
                     imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:requestImageURL
                       imageProcessingBlock:^UIImage *(UIImage *image) {
                           NSLog( @"IMAGE SIZE BEFORE PROCESSING: w x h = %f , %f" , image.size.width , image.size.height);
                           return image;
                       } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                           NSLog( @"IMAGE SIZE BEFORE SAVE: w x h = %f , %f" , image.size.width , image.size.height);
                           [Utilities updateImageInfo:doc.image withImage:image asPreview:YES asThumbnail:YES preserveSize:YES];
                           NSLog( @"Successfully downloaded image for ANNOTATION_DOC!" );
                           [[DataController sharedController] saveContext];
                           
                           UIImage * image1 = [UIImage imageWithContentsOfFile:doc.image.path];
                           NSLog( @"IMAGE SIZE AFTER SAVE: w x h = %f , %f" , image1.size.width , image1.size.height);
                           [self refreshDocumentsList];
                           
                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                           NSLog( @"Image DOWNLOAD error... \n%@" , [NSString stringWithFormat:@"%@" , error] );
                           
                           UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Posting JSON"
                                                                        message:[NSString stringWithFormat:@"%@",error]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
                           [av show];
                       }];
                     
                     [imageOperation start];
                 }
             }
         }

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             NSLog( @"IMAGE_INFO error... \n%@" , [NSString stringWithFormat:@"%@" , error] );
             
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Posting JSON"
                                                          message:[NSString stringWithFormat:@"%@",error]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [av show];
             
             NSLog( @"JSON: \n%@" , JSON );
         }
    ];
//    [operation start];
*/

/*    NSString * objType = @"CONVO_THREAD";
    NSString * valid = @"YES";

    NSDictionary * params = @{ @"type":objType , @"valid":valid };

    NSMutableURLRequest * request = [[DataController sharedController].httpClient requestWithMethod:@"POST"
                                                                                               path:@"/Contxt/tmp/getObject.php"
                                                                                         parameters:params];
 
    AFHTTPRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             
             NSLog( @"\n\n JSON \n %@" , JSON );
 
             NSDictionary * JSONresponse = (NSDictionary *)JSON;
             NSLog( @"%@: %@" , [JSONresponse objectForKey:@"status"] , [JSONresponse objectForKey:@"message"] );
             
             
             if( [objType isEqualToString:@"CONTXT_CONTACT"] )
             {
                 ContxtContact * contact = [JSONUtility contxtContactFromJSON:[JSON objectForKey:@"object"]];
                 if( !contact )
                     NSLog( @"contact was nil" );
                 else
                 {
                     NSLog( @"\nCONTXT_CONTACT \nkey: %@ \nemail: %@ \nfName: %@ \nlName: %@", contact.key , contact.email , contact.firstName , contact.lastName );
                     NSLog( @"parentThreadKeys: %@ \n" , [contact.parentConvoThread allObjects] );
                 }
             }
             else if( [objType isEqualToString:@"CONVO_MESSAGE"] )
             {
                 ConversationMessage * message = [JSONUtility convoMessageFromJSON:[JSON objectForKey:@"object"]];
                 
                 if( !message )
                     NSLog( @"ConvoMessage was nil" );
                 else
                 {
                     NSLog( @"\nCONVO_MESSAGE \nkey: %@ \nowner: %@ \ndateCreated: %@ \nparentConvoThreadKey: %@ \ntext: %@ \nimageInfoKey: %@ \n"
                           , message.key , message.owner , [Utilities dateToDbDateString:message.dateCreated]
                           , [[JSON objectForKey:@"object"] objectForKey:@"parentConvoThreadKey"]
                           , (message.text ? message.text : @"nil" )
                           , [[JSON objectForKey:@"object"] objectForKey:@"imageInfoKey"] );
                 }
             }
             else if( [objType isEqualToString:@"CONVO_THREAD"] )
             {
                 ConversationThread * thread = [JSONUtility convoThreadFromJSON:[JSON objectForKey:@"object"]];
                 
                 if( !thread )
                 {
                     NSLog( @"ConvoThread was nil." );
                 }
                 else
                 {
                     NSLog( @"\nCONVO_THREAD \nkey: %@ \nowner: %@ \ndateCreated: %@ \nparentAnnotationKey: %@ \nparticipantKeys: %@ \n"
                           , thread.key , thread.owner , [Utilities dateToDbDateString:thread.dateCreated]
                           , [[JSON objectForKey:@"object"] objectForKey:@"parentAnnotationKey"]
                           , [[JSON objectForKey:@"object"] objectForKey:@"participantKeys"] );
                     
                     for( ConversationMessage * message in thread.convoMessages )
                     {
                         if( !message )
                             NSLog( @"ConvoMessage was nil" );
                         else
                         {
                             NSLog( @"\nkey: %@ \nowner: %@ \ndateCreated: %@ \ntext: %@ \nimageInfoKey: %@ \n"
                                   , message.key , message.owner , [Utilities dateToDbDateString:message.dateCreated]
                                   , (message.text ? message.text : @"nil" )
                                   , [[JSON objectForKey:@"object"] objectForKey:@"imageInfoKey"] );
                         }
                     }
                 }
             }
         }

         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             NSLog( @"%@" , [NSString stringWithFormat:@"%@" , error] );
             
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Posting JSON"
                                                          message:[NSString stringWithFormat:@"%@",error]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [av show];
             
             NSLog( @"JSON: \n%@" , JSON );
         }
    ];
    [operation start]; */
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.navigationController.navigationBarHidden = FALSE;
    self.navigationItem.title = @"contxt roll";
    
/*    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                          target:self
                                                                                          action:@selector(launchCameraControlWithAnimation)];
*/
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

    // Create Image Showcase (Previews)
    _imageShowCase = [[NLImageShowCase alloc] initWithFrame:self.view.bounds];
    _imageViewer = [[NLImageViewer alloc] initWithFrame:self.view.bounds];

    _imageShowCase.dataSource = self;
    
    _imageShowCase.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tile.png"]];
    _imageViewer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tile.png"]];
    _imagViewController = [[UIViewController alloc] init];
    [_imagViewController.view addSubview:_imageViewer];
    
    [self.view addSubview:_imageShowCase];
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

    // Add the images
    if( !self.projectKey )
        [self.navigationController popViewControllerAnimated:YES];
    
    Project * project = [[DataController sharedController] projectForKey:self.projectKey];
    
    [self addImagesForProject:project];
    
    _showCaseCellToDelete = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

#pragma mark - Image Showcase Protocol
- (CGSize)imageViewSizeInShowcase:(NLImageShowCase *) imageShowCase
{
    return CGSizeMake(IMAGE_SHOWCASE_CELL_SIZE_X , IMAGE_SHOWCASE_CELL_SIZE_Y);
}
- (CGFloat)imageLeftOffsetInShowcase:(NLImageShowCase *) imageShowCase
{
    return IMAGE_SHOWCASE_SPACING;
}
- (CGFloat)imageTopOffsetInShowcase:(NLImageShowCase *) imageShowCase
{
    return IMAGE_SHOWCASE_SPACING;
//    return 15.0f;
}
- (CGFloat)rowSpacingInShowcase:(NLImageShowCase *) imageShowCase
{
    return IMAGE_SHOWCASE_SPACING;
}
- (CGFloat)columnSpacingInShowcase:(NLImageShowCase *) imageShowCase
{
    return IMAGE_SHOWCASE_SPACING;
}
- (void)imageClicked:(NLImageShowCase *) imageShowCase imageShowCaseCell:(NLImageShowCaseCell *)imageShowCaseCell;
{
    if( self.delegate )
    {
        [self.delegate annotationDocumentSelected:[[DataController sharedController] annotationDocumentForKey:imageShowCaseCell.key]];
        [self close];
    }
    else
    {
        AnnotationViewController * avc = [[AnnotationViewController alloc] initWithNibName:@"AnnotationViewController" bundle:nil];
        avc.doc = [[DataController sharedController] annotationDocumentForKey:imageShowCaseCell.key];
        
        [self.navigationController pushViewController:avc animated:YES];
    }
}

- (void)imageTouchLonger:(NLImageShowCase *)imageShowCase imageIndex:(NSInteger)index;
{
    if( !delegate )
        [_imageShowCase setDeleteMode:!(_imageShowCase.deleteMode)];
}

- (void)deleteImage:(NLImageShowCaseCell *)imageShowCaseCell
{
    _showCaseCellToDelete = imageShowCaseCell;
    
    NSString* message = @"This image, as well as ALL annotations will be deleted. This action can not be undone. Delete?";
    
    // Verify Delete
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Document?"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Delete",nil];
    
    [alertView show];
}

@end
