//
//  ConvoListViewController.m
//  Contxt
//
//  Created by Chad Morris on 6/6/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "ConvoListViewController.h"
#import "DataController.h"
#import "ConvoListCell.h"
#import "Utilities.h"
#import "ConvoViewController.h"
#import "AnnotationDocument.h"

@interface ConvoListViewController ()

@end

@implementation ConvoListViewController

@synthesize docKey;

@synthesize tableDataSource , tableView;


#pragma mark - ServerCommsObserver Methods

- (void)newConvoMessages:(NSArray *)keys
{
    AnnotationDocument * doc = [[DataController sharedController] annotationDocumentForKey:self.docKey];
    
    if( !doc )
        [self refresh];
    else
    {
        for( Annotation * annotation in [doc.annotations allObjects] )
        {
            if( ![annotation isKindOfClass:[ConvoAnnotation class]] )
                continue;
            
            for( ConversationMessage * message in [((ConvoAnnotation*)annotation).convoThread.convoMessages allObjects] )
                if( [keys containsObject:message.key] )
                {
                    [self refresh];
                    break;
                }
        }
    }
}


#pragma mark -

- (void)refresh
{
    AnnotationDocument * doc = [[DataController sharedController] annotationDocumentForKey:self.docKey];
    
    if( doc )
    {
        NSLog( @"doc key = %@" , doc.key );
        
        NSMutableArray * messages = [[NSMutableArray alloc] init];
        for( Annotation * annotation in doc.annotations )
        {
            if( ![annotation isKindOfClass:[ConvoAnnotation class]] )
                continue;
            
            NSArray * threadMessages = [[DataController sharedController] convoMessagesForConvoThread:((ConvoAnnotation*)annotation).convoThread.key];
            
            if( [threadMessages count] > 0 )
                [messages addObject:[threadMessages lastObject]];
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
        
        self.tableDataSource = [[NSMutableArray alloc] initWithArray:[messages sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]]];
    }
    else
    {
        [[DataController sharedController].managedObjectContext reset];
        
        self.tableDataSource = [[NSMutableArray alloc] initWithArray:[[DataController sharedController] newestMessageFromEachConvoThread]];
    }
    
    [self.tableView reloadData];
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[DataController sharedController] addObserver:self];

    [self refresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    /*    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
     target:self
     action:@selector(launchNewProjectView)];
     
     //    self.navigationItem.hidesBackButton = YES;
     
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
     target:self
     action:@selector(launchCameraControlWithAnimation)];
     */
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view = self.tableView;
    
    self.navigationItem.title = @"messages";
    
    [self refresh];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[DataController sharedController] removeObserver:self];
    [super viewDidDisappear:animated];
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

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConvoListCell";
    
    ConvoListCell *cell;
    
	if( !cell )
	{
        NSString * nib = CellIdentifier;
        
        if( !nib )
            return [[UITableViewCell alloc] init];
        
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nib owner:nil options:nil];
		
		for( id currentObject in nibObjects )
		{
			if( [currentObject isKindOfClass:[ConvoListCell class]] )
			{
				cell = (ConvoListCell *)currentObject;
			}
		}
	}
	
	if( !cell )
        return [[UITableViewCell alloc] init];
    
    ConversationMessage * m = (ConversationMessage *)[self.tableDataSource objectAtIndex:indexPath.row];
    
    if( !m )
        return cell;
    
    cell.title.text = m.owner;
    
    if( [Utilities dateIsToday:m.dateCreated] )
    {
        cell.time.text = [Utilities dateToTimeString:m.dateCreated];
    }
    else
    {
        cell.time.text = [Utilities dateToShortDateString:m.dateCreated];
    }
    
    if( m.parentConvoThread.parentAnnotation &&
       m.parentConvoThread.parentAnnotation.parentAnnotationDocument &&
       m.parentConvoThread.parentAnnotation.parentAnnotationDocument.image &&
       m.parentConvoThread.parentAnnotation.parentAnnotationDocument.image.thumbPath )
    {
        UIImage * image = [UIImage imageWithContentsOfFile:m.parentConvoThread.parentAnnotation.parentAnnotationDocument.image.thumbPath];
        
        if( image )
            [cell.preview setImage:image];
    }
    else
        NSLog( @"No thumbnail associated with convo thread" );
    
    if( [m.unread boolValue] )
        cell.unreadImage.hidden = NO;
    
    if( m.text && [m.text length] > 0 )
        cell.details.text = m.text;
    else if( m.image )
        cell.details.text = @"<New Image>";
    
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"ConvoListCell" owner:nil options:nil];
    if( [nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[ConvoListCell class]] )
    {
        ConvoListCell * cell = (ConvoListCell *)[nibObjects objectAtIndex:0];
        return cell.frame.size.height;
    }
    else
        return 66.0;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConvoViewController * cvc = [[ConvoViewController alloc] initWithNibName:@"ConvoViewController" bundle:nil];
    cvc.annotation = ((ConversationMessage *)[self.tableDataSource objectAtIndex:indexPath.row]).parentConvoThread.parentAnnotation;
    
    [self.navigationController pushViewController:cvc animated:YES];
}

@end
