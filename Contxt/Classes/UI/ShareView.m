//
//  ShareView.m
//  Contxt
//
//  Created by Chad Morris on 5/22/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "ShareView.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Utilities.h"

@implementation ShareView

@synthesize delegate;
@synthesize email;
@synthesize type = _type;

- (void)specifyType:(NSString *)shareType
{
    _type = shareType;
    
    _title.text = [NSString stringWithFormat:@"Share '%@' with..." , _type];
}

- (IBAction)lookupContact:(id)sender
{
    if( delegate )
    {
        [delegate hideContainingView:self];
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = delegate;
        
        picker.displayedProperties = [NSArray arrayWithObjects: [NSNumber numberWithInt:kABPersonCompositeNameFormatFirstNameFirst]
                                      , [NSNumber numberWithInt:kABPersonEmailProperty]
                                      , nil];
        
        [delegate presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)share:(id)sender
{
    // @TODO: Prompt validation?
    
    if( self.email && self.email.text && [self.email.text length] > 4 && [Utilities validateEmail:self.email.text] )
    {
        [delegate shareWithText:self.email.text sender:self];
    }
    else
    {
        [self.email setBackgroundColor:[Utilities errorBgColor]];
        [self.email addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
}

#pragma - UITextFieldDelegate Methods

- (BOOL) textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField setBackgroundColor:[UIColor whiteColor]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (void)textFieldDidChange:(id)event
{
    [self.email setBackgroundColor:[UIColor whiteColor]];
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
