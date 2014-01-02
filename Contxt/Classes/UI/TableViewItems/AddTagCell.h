//
//  TagCell.h
//  Contxt
//
//  Created by Chad Morris on 5/2/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWTagList.h"

@interface AddTagCell : UITableViewCell

@property (nonatomic , strong) IBOutlet UILabel * label;
@property (nonatomic , strong) IBOutlet UITextField * tagField;
@property (nonatomic , strong) IBOutlet UIButton * btnAddTag;

@end
