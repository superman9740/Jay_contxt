//
//  TagCell.m
//  Contxt
//
//  Created by Chad Morris on 5/2/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "TagCell.h"

@implementation TagCell

@synthesize tagList , label;

- (void)addTagListView:(DWTagList *)dwtList
{
    _dwtList = dwtList;
    _dwtList.view.backgroundColor = [UIColor yellowColor];
    [self addSubview:_dwtList];
    [self bringSubviewToFront:_dwtList];
    
    CGFloat height = (_dwtList.view.frame.size.height < 44.0 ? 44.0 : _dwtList.view.frame.size.height);

    self.label.frame = CGRectMake(self.label.frame.origin.x
                                  , self.label.frame.origin.y
                                  , self.label.frame.size.width
                                  , height);
    
    self.frame = CGRectMake(self.frame.origin.x
                            , self.frame.origin.y
                            , self.frame.size.width
                            , height);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
