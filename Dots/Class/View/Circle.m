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

- (CGPoint)corOfCircleBesidePos:(int)pos
{
    int newX,newY;
    int x = [self getX];
    int y = [self getY];
    switch (pos) {
        case 1:
            if (y%2==1)
            {
                newX = x;
                newY = y-1;
            }else
            {
                newX = x-1;
                newY = y-1;
            }
            break;
        case 2:
            if (y%2==1)
            {
                newX = x+1;
                newY = y-1;
            }else
            {
                newX = x;
                newY = y-1;
            }
            
            break;
        case 3:
            
            newX = x+1;
            newY = y;
            break;
        case 4:
            newY = y+1;
            if (y%2==1)
            {
                newX = x+1;
            }else
            {
                newX = x;
                
            }
            break;
        case 5:
            newY = y+1;
            newX = (y%2==1) ? x: x-1;
            
            break;
        case 6:
            newX = x-1;
            newY = y;
            break;
            
        default:
            break;
    }
    
    
    return CGPointMake(newX, newY);
    
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
    return (int)((self.tag-1) - y)/10;
}


@end
