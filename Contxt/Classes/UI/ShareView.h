//
//  ShareView.h
//  Contxt
//
//  Created by Chad Morris on 5/22/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@class ShareView;

@protocol ShareViewDelegate <NSObject>

- (void)shareWithText:(NSString *)text sender:(ShareView *)shareView;
- (void)hideContainingView:(ShareView *)shareView;

@end

@interface ShareView : UIView <UITextFieldDelegate>
{
    NSString * _type;
    
    IBOutlet UILabel * _title;
}

@property (nonatomic , readonly) NSString * type;
@property (nonatomic , strong) IBOutlet UITextField * email;
@property (nonatomic , strong) UIViewController<ABPeoplePickerNavigationControllerDelegate , ShareViewDelegate> * delegate;

- (IBAction)lookupContact:(id)sender;
- (IBAction)share:(id)sender;

- (void)specifyType:(NSString *)shareType;

@end
