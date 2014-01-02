//
//  ConvoListCell.h
//  Contxt
//
//  Created by Chad Morris on 5/2/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConvoListCell : UITableViewCell

@property (nonatomic , strong) IBOutlet UIImageView * preview;
@property (nonatomic , strong) IBOutlet UILabel * title;
@property (nonatomic , strong) IBOutlet UILabel * details;
@property (nonatomic , strong) IBOutlet UILabel * time;
@property (nonatomic , strong) IBOutlet UIImageView * unreadImage;

@end
