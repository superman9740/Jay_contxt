//
//  ConvoViewController.h
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <UIKit/UIKit.h>
#import "AnnotationObserver.h"
#import "UIBubbleTableViewDataSource.h"
#import "RDActionSheet.h"

#import "DataChangeObserver.h"

#import "DWTagList.h"
#import "ShareView.h"

@class ConvoAnnotation;

@interface ConvoViewController : UIViewController < UIBubbleTableViewDataSource
                                                  //, RDActionSheetDelegate
                                                  , UIImagePickerControllerDelegate
                                                  , UINavigationControllerDelegate
                                                  , DWTagListDelegate
                                                  , ShareViewDelegate
                                                  , DataChangeObserver
                                                  , ABPeoplePickerNavigationControllerDelegate>
{
    NSMutableArray * _messages;
    NSMutableArray * _participants;
    NSString * _myUsername;
    ShareView * _shareView;
    
    NSString * _emailToRemove;
    
    BOOL _shouldScrollToBottom;
}

- (IBAction)showActionSheet:(id)sender;
- (IBAction)sayPressed:(id)sender;
- (IBAction)showAddContact:(id)sender;

@property (nonatomic , strong) id<AnnotationObserver> delegate;
@property (nonatomic , strong) ConvoAnnotation * annotation;
@property (nonatomic , strong) IBOutlet DWTagList * tagListView;

@end
