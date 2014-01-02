//
//  AnnotationButton.m
//  Contxt
//
//  Created by Chad Morris on 5/16/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "AnnotationButton.h"
#import "Annotation.h"

@implementation AnnotationButton

@synthesize annotation;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.annotation = nil;
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
