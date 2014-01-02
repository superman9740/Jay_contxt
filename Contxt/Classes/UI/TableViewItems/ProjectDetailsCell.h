//
//  ProjectDetailsCell.h
//  Contxt
//
//  Created by Chad Morris on 5/2/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"

@interface ProjectDetailsCell : MCSwipeTableViewCell

@property (nonatomic , strong) IBOutlet UIImageView * preview;
@property (nonatomic , strong) IBOutlet UILabel * title;
@property (nonatomic , strong) IBOutlet UILabel * updateDate;

@end
