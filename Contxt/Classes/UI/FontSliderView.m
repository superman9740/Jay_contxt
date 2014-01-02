//
//  FontSliderView.m
//  Contxt
//
//  Created by Chad Morris on 6/12/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import "FontSliderView.h"

#define SLIDER_MIN_VALUE 11
#define SLIDER_MAX_VALUE 56

@implementation FontSliderView

@synthesize slider, fontSizeLabel, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.fontSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0 , 0 , 36, 20 )];
        self.fontSizeLabel.textAlignment = NSTextAlignmentCenter;
        self.fontSizeLabel.font = [UIFont systemFontOfSize:12.0];
        
        self.slider = [[UISlider alloc] initWithFrame:CGRectMake( (self.frame.size.width - 23)/2 , 24, 90, 23)];
        CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * -0.5);
        self.slider.transform = trans;
        self.slider.minimumValue = SLIDER_MIN_VALUE;
        self.slider.maximumValue = SLIDER_MAX_VALUE;
        self.slider.frame = CGRectMake( 5, 30, self.frame.size.width, self.frame.size.height );
        [self setSliderValue:15.0f];
        
        CGFloat minHeight = self.fontSizeLabel.frame.size.height + self.slider.frame.size.height;
        if( self.frame.size.height < minHeight )
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, minHeight);
        
        [self.slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:self.fontSizeLabel];
        [self addSubview:self.slider];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)sliderValueChanged
{
    [self setSliderValue:self.slider.value];
    
    if( self.delegate )
        [self.delegate sliderValueDidChange:self];
}

- (void)setSliderValue:(CGFloat)value
{
    if( value < self.slider.minimumValue || value > self.slider.maximumValue )
        return;
    
    self.slider.value = value;
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%i pt", (int)self.slider.value];
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
