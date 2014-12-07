//
//  PlayViewController.h
//  Dots
//
//  Created by Hoang Le on 12/6/14.
//  Copyright (c) 2014 hoang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Circle.h"

@interface PlayViewController : UIViewController <circleDelegate>
{
    Circle *blueCircle;
    BOOL noTap;
    NSMutableArray *borderCircles;
    NSMutableArray *redList;
    int power;
}
@property (strong, nonatomic) IBOutlet UILabel *lblPower;
@property (strong, nonatomic) IBOutlet UIView *map;

@end
