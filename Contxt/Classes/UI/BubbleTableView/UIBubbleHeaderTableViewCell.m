//
//  UIBubbleHeaderTableViewCell.m
//  UIBubbleTableViewExample
//
//  Created by Александр Баринов on 10/7/12.
//  Copyright (c) 2012 Stex Group. All rights reserved.
//

#import "UIBubbleHeaderTableViewCell.h"

@interface UIBubbleHeaderTableViewCell ()

@property (nonatomic, retain) UILabel *label;

@end

@implementation UIBubbleHeaderTableViewCell

@synthesize label = _label;
@synthesize date = _date;
@synthesize textAlignment = NSTextAlignmentCenter;

+ (CGFloat)height
{
    return 28.0*2;
}

- (void)setDate:(NSDate *)value
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *text = [dateFormatter stringFromDate:value];
#if !__has_feature(objc_arc)
    [dateFormatter release];
#endif
    
    if (self.label)
    {
        self.label.text = text;
        return;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [UIBubbleHeaderTableViewCell height]/2)];
    self.label.text = text;
    self.label.font = [UIFont boldSystemFontOfSize:12];
    self.label.textAlignment = self.textAlignment;
    self.label.shadowOffset = CGSizeMake(0, 1);
    self.label.shadowColor = [UIColor whiteColor];
    self.label.textColor = [UIColor darkGrayColor];
    self.label.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
}

- (void)setDate:(NSDate *)value andSource:(NSString *)source
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *text = [NSString stringWithFormat:@"%@\n%@",[dateFormatter stringFromDate:value], source];
#if !__has_feature(objc_arc)
    [dateFormatter release];
#endif
    
    if (self.label)
    {
        self.label.text = text;
        return;
    }

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat x = 0;
    if( self.textAlignment == NSTextAlignmentLeft )
        x += 10;
    else if( self.textAlignment == NSTextAlignmentRight )
        x -= 10;
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.frame.size.width, [UIBubbleHeaderTableViewCell height])];
    self.label.numberOfLines = 0;
    self.label.text = text;
    self.label.font = [UIFont boldSystemFontOfSize:12];
    self.label.textAlignment = self.textAlignment;
    self.label.shadowOffset = CGSizeMake(0, 1);
    self.label.shadowColor = [UIColor whiteColor];
    self.label.textColor = [UIColor darkGrayColor];
    self.label.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
}



@end
