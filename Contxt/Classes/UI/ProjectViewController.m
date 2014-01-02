//
//  ProjectViewController.m
//  Contxt
//
//  Created by Chad Morris on 5/2/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "ProjectViewController.h"
#import "DataController.h"
#import "Project.h"
#import "InputCell.h"
#import "TagCell.h"
#import "AddTagCell.h"
#import "ProjectTitleCell.h"
#import "Utilities.h"
#import "UIScrollView+APParallaxHeader.h"
#import "AnnotationDocListViewController.h"

#define PARALLAX_HEIGHT 120

@interface ProjectViewController ()
@end

@implementation ProjectViewController

@synthesize tableDataSource , tableView;
@synthesize projectKey;

- (void)handleParallaxTouch:(UILongPressGestureRecognizer *)recognizer
{
    if( recognizer.state == UIGestureRecognizerStateBegan )
    {
        AnnotationDocListViewController * vc = [[AnnotationDocListViewController alloc] init];

        NSLog( @"self.pKey = %@" , self.projectKey );
        vc.projectKey = self.projectKey;
        NSLog( @"vc.pKey = %@" , vc.projectKey );
        vc.delegate = self;
        vc.navigationItem.hidesBackButton = YES;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)annotationDocumentSelected:(AnnotationDocument *)doc
{
    if( doc.image )
    {
        _project.thumbnail = doc.image;
        
        [self.tableView changeParallaxWithImage:[UIImage imageWithContentsOfFile:doc.image.path]];
    }
}


- (BOOL) textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.navigationItem.hidesBackButton = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if( textField.tag == 0 )
    {
        if( textField.text && [textField.text length] > 0 )
        {
            self.navigationItem.hidesBackButton = NO;
            _project.title = textField.text;
        }
        else
        {
            self.navigationItem.hidesBackButton = YES;
        }
    }
    else
    {
        self.navigationItem.hidesBackButton = NO;
    }
}

- (void)selectedTag:(NSString*)tagName
{
    _project.tags = [_project.tags stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"#%@",tagName] withString:@""];
    [self.tableView reloadData];
}

- (void)addTag:(id)sender
{
//    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[[NSIndexPath alloc] initWithIndex:[self.tableDataSource count]-1] ];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    if( !cell )
        return;
    
    if( ![cell isKindOfClass:[AddTagCell class]] )
        return;
    
    NSString * text = ((AddTagCell *)cell).tagField.text;
    if( text && [text length] > 1 && [[text substringToIndex:1] isEqualToString:@"#"] )
    {
        if( !_project.tags )
            _project.tags = text;
        else
            _project.tags = [NSString stringWithFormat:@"%@%@",_project.tags,text];
        
        [self.tableView reloadData];
    }
    else
    {
//        ((AddTagCell *) cell).tagField.backgroundColor = [Utilities errorBgColor];
        ((AddTagCell *) cell).tagField.text = @"#";
    }
}

- (void)cancelChanges:(id)sender
{
    if( _addMode )
    {
        [[DataController sharedController].managedObjectContext deleteObject:_project];
        [[DataController sharedController] saveContext];
    }
    else
    {
        [[DataController sharedController].managedObjectContext rollback];
        _discardChanges = TRUE;
    }

    [self.navigationController popViewControllerAnimated:YES];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[DataController sharedController] saveContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _discardChanges = FALSE;
    _addMode = FALSE;

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(cancelChanges:)];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tile.png"]];
    self.tableView.allowsSelection = NO;

    self.view = self.tableView;
    
    if( !projectKey || [projectKey isEqualToString:@""] || [projectKey length] == 0 )
    {
        _addMode = TRUE;
        self.navigationItem.title = @"Add Project";
        
        _project = [[DataController sharedController] newProject];
        [[DataController sharedController] saveContext];
        self.projectKey = _project.key;
    }
    else
    {
        self.navigationItem.title = @"Edit Project";
        
        _project = [[DataController sharedController] projectForKey:projectKey];
    }
    
    self.tableDataSource = [[NSMutableArray alloc] initWithObjects:@"TITLE",@"TAGS",@"ADDTAG", nil];

    if( _project.thumbnail )
        [self.tableView addParallaxWithImage:[UIImage imageWithContentsOfFile:_project.thumbnail.path] andHeight:PARALLAX_HEIGHT];
    else
        [self.tableView addParallaxWithImage:[UIImage imageNamed:@"add.jpg"] andHeight:PARALLAX_HEIGHT];
    
    UILongPressGestureRecognizer *pgr = [[UILongPressGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(handleParallaxTouch:)];
    pgr.minimumPressDuration = 0.5;
    [self.tableView addParallaxGestureRecognizer:pgr];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( [[self.tableDataSource objectAtIndex:indexPath.row] isEqualToString:@"TITLE"] )
    {
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"ProjectTitleCell" owner:nil options:nil];
        if( [nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[ProjectTitleCell class]] )
        {
            ProjectTitleCell * cell = (ProjectTitleCell *)[nibObjects objectAtIndex:0];
            return cell.frame.size.height;
        }
    }
    else if( [[self.tableDataSource objectAtIndex:indexPath.row] isEqualToString:@"TAGS"] )
    {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"TagCell" owner:nil options:nil];
        if( [nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[TagCell class]] )
        {
            TagCell * cell = (TagCell *)[nibObjects objectAtIndex:0];
            DWTagList * oTagList = [[DWTagList alloc] initWithFrame:((TagCell*)cell).tagList.frame];
            
            NSMutableArray * tags = [NSMutableArray arrayWithArray:[_project.tags componentsSeparatedByString: @"#"]];
            [tags removeObject:@""];
            [oTagList setAutomaticResize:YES];
            [oTagList setTags:tags];

            NSLog( @"oTagList height: %f" , oTagList.frame.size.height);
            return (oTagList.frame.size.height < 44.0 ? 44.0 : oTagList.frame.size.height);
        }
    }
    else if( [[self.tableDataSource objectAtIndex:indexPath.row] isEqualToString:@"ADDTAG"] )
    {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"AddTagCell" owner:nil options:nil];
        if( [nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[AddTagCell class]] )
        {
            AddTagCell * cell = (AddTagCell *)[nibObjects objectAtIndex:0];
            return cell.frame.size.height;
        }
    }

    return 44.0;
}

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    if( [[self.tableDataSource objectAtIndex:indexPath.row] isEqualToString:@"TITLE"] )
    {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"ProjectTitleCell" owner:nil options:nil];
		
		for( id currentObject in nibObjects )
		{
			if( [currentObject isKindOfClass:[ProjectTitleCell class]] )
			{
				cell = (ProjectTitleCell *)currentObject;
			}
		}

        ((ProjectTitleCell*)cell).label.text = @"Title";
        ((ProjectTitleCell*)cell).details.delegate = self;
        ((ProjectTitleCell*)cell).details.tag = indexPath.row;
        ((ProjectTitleCell*)cell).details.placeholder = @"Untitled Project";
        ((ProjectTitleCell*)cell).details.text = _project.title;
    }
    else if( [[self.tableDataSource objectAtIndex:indexPath.row] isEqualToString:@"TAGS"] )
    {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"TagCell" owner:nil options:nil];
		
		for( id currentObject in nibObjects )
		{
			if( [currentObject isKindOfClass:[TagCell class]] )
			{
				cell = (TagCell *)currentObject;
			}
		}
        
        if( _project.tags && [_project.tags length] > 0 )
        {
            DWTagList * oTagList = [[DWTagList alloc] initWithFrame:((TagCell*)cell).tagList.frame];

            NSLog( @"tags: %@" , _project.tags );
            NSMutableArray * tags = [NSMutableArray arrayWithArray:[_project.tags componentsSeparatedByString: @"#"]];
            [tags removeObject:@""];
            [oTagList setAutomaticResize:YES];
            [oTagList setTagDelegate:self];
            [oTagList setTags:tags];
            [oTagList setTagBackgroundColor:[UIColor colorWithRed:0.40 green:0.80 blue:1.00 alpha:0.5]];

//            ((TagCell*)cell).tagList = oTagList;
            [((TagCell*)cell) addTagListView:oTagList];
        }
    }
    else if( [[self.tableDataSource objectAtIndex:indexPath.row] isEqualToString:@"ADDTAG"] )
    {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"AddTagCell" owner:nil options:nil];
		
		for( id currentObject in nibObjects )
		{
			if( [currentObject isKindOfClass:[AddTagCell class]] )
			{
				cell = (AddTagCell *)currentObject;
			}
		}
        
        ((AddTagCell*) cell).tagField.text = @"#";
        ((AddTagCell*)cell).tagField.delegate = self;
        ((AddTagCell*)cell).tagField.tag = indexPath.row;
        [((AddTagCell*) cell).btnAddTag addTarget:self action:@selector(addTag:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        cell = [[UITableViewCell alloc] init];
    }

    cell.tag = indexPath.row;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
