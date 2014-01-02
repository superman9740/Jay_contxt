//
//  FontSliderView.h
//  Contxt
//
//  Created by Chad Morris on 6/12/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FontSliderView;

@protocol FontSliderViewDelegate

- (void)sliderValueDidChange:(FontSliderView *)slider;

@end

@interface FontSliderView : UIView

@property (nonatomic , strong) IBOutlet UILabel * fontSizeLabel;
@property (nonatomic , strong) IBOutlet UISlider * slider;

@property (nonatomic , retain) id<FontSliderViewDelegate> delegate;

- (void)setSliderValue:(CGFloat)value;

@end
