//
//  RoundGradientButton.m
//  CronkiteVR
//
//  Created by student on 4/1/16.
//  Copyright © 2016 NMIL. All rights reserved.
//

#import "RoundGradientButton.h"
#import "CNDefinitions.h"

@implementation RoundGradientButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)newButton {

    CALayer *btnLayer = [self layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:self.frame.size.width/2];
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    
    CAGradientLayer *btnGradient1 = [CAGradientLayer layer];
    btnGradient1.frame = self.bounds;
    btnGradient1.colors = [NSArray arrayWithObjects:
                           COLOR1,
                           COLOR2,
                           nil];
    [self.layer insertSublayer:btnGradient1 atIndex:0];
    return self;
    
}

@end
