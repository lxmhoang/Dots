//
//  Circle.m
//  Dots
//
//  Created by Hoang Le on 12/6/14.
//  Copyright (c) 2014 hoang. All rights reserved.
//

#import "Circle.h"

@implementation Circle

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setColor:(NSString *)_color
{
    color = _color;
    self.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@circle", color]];
    
}

- (BOOL)circleColor:(NSString *)_color
{
    if ([color isEqualToString:_color])
    {
        return YES;
    }
    return NO;
}

- (IBAction)tapped:(id)sender {
    [self.delegate tapOnCircle:self];
}

- (int)getY
{
    return (self.tag-1) % 10;
}

- (int)getX
{
    int y = (self.tag-1) % 10;
    return ((self.tag-1) - y)/10;
}


@end
