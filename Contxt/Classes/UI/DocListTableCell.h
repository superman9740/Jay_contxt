//
//  DocListTableCell.h
//  Contxt
//
//  Created by Chad Morris on 10/19/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AnnotationDocument.h"

@protocol DocListCellDelegate <NSObject>

@required
- (void)deleteDoc:(NSString *)key;
- (void)selectedDoc:(NSString *)key;

@end

@interface DocListTableCell : UITableViewCell
{
    IBOutlet UIImageView * _leftImage;
    IBOutlet UIImageView * _rightImage;
    
    UIView * _leftDeleteView , * _rightDeleteView;
    UILabel * _leftDeleteLabel , * _rightDeleteLabel;
    
    CGRect _leftRectBeforeAnimate , _leftRectAfterAnimate , _rightRectBeforeAnimate , _rightRectAfterAnimate;
}

@property (nonatomic , strong) AnnotationDocument * leftDoc;
@property (nonatomic , strong) AnnotationDocument * rightDoc;

@property (nonatomic , strong) id<DocListCellDelegate>delegate;

@end
