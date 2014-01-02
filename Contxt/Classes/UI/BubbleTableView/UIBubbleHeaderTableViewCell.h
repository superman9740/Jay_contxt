//
//  UIBubbleHeaderTableViewCell.h
//  UIBubbleTableViewExample
//
//  Created by Александр Баринов on 10/7/12.
//  Copyright (c) 2012 Stex Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBubbleHeaderTableViewCell : UITableViewCell

+ (CGFloat)height;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic) NSTextAlignment textAlignment;

- (void)setDate:(NSDate *)value andSource:(NSString *)source;

@end
