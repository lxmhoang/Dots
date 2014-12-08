//
//  PlayViewController.h
//  Dots
//
//  Created by Hoang Le on 12/6/14.
//  Copyright (c) 2014 hoang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Circle.h"

@interface PlayViewController : UIViewController <circleDelegate, UIAlertViewDelegate>
{
    Circle *blueCircle, *highlightingCircle;
    BOOL noTap;
    NSMutableArray *borderCircles;
    NSMutableArray *redList;
    int power;
    int numOfDot;
    int size, turn;
    
    CGPoint startPoint, endPoint;
}
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *lblPower;
@property (strong, nonatomic) IBOutlet UITextField *numOfRow;
@property (strong, nonatomic) IBOutlet UIView *map;
@property (strong, nonatomic) IBOutlet UILabel *lbTurns;
- (IBAction)resetTapped:(id)sender;

@end
