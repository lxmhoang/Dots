//
//  Circle.h
//  Dots
//
//  Created by Hoang Le on 12/6/14.
//  Copyright (c) 2014 hoang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Circle;

@protocol circleDelegate <NSObject>

- (void)tapOnCircle:(Circle *)sender;

@end

@interface Circle : UIView
{
    NSString *color;
}
@property (strong, nonatomic) IBOutlet UIImageView *imgView;

@property (nonatomic, unsafe_unretained) id delegate;

@property (nonatomic, assign) int numOfRedMoving;
@property (nonatomic, assign) int distance;
@property (nonatomic, strong) Circle *dest;

@property (strong, nonatomic) IBOutlet UILabel *lbDistance;

- (void)setColor:(NSString *)color;

- (int)getX;

- (int)getY;


- (BOOL)circleColor:(NSString *)_color;
- (IBAction)tapped:(id)sender;

@end
