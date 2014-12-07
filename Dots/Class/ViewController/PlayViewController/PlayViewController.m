//
//  PlayViewController.m
//  Dots
//
//  Created by Hoang Le on 12/6/14.
//  Copyright (c) 2014 hoang. All rights reserved.
//

#import "PlayViewController.h"
#import "Circle.h"


@interface PlayViewController ()

@end

@implementation PlayViewController
@synthesize map;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCircles];
    
    power = 10;
    
    self.lblPower.text = [NSString stringWithFormat:@"%d",power];
    
    redList = [[NSMutableArray alloc] init];
    noTap = NO;
    // Do any additional setup after loading the view from its nib.
}

- (Circle *)createACircleAtPoint:(CGPoint)point temp:(BOOL)temp color:(NSString *)color delegate:(id)delegate
{
    Circle *circle = [[[NSBundle mainBundle] loadNibNamed:@"Circle" owner:nil options:nil] objectAtIndex:0];
    [circle setFrame:CGRectMake(0, 0, 30, 30)];
    
    int x = point.x;
    int y = point.y;
    
    CGPoint actualPoint;
    
    if (y%2==1)
    {
        actualPoint.x = 30*x+15+15;
    }else
    {
        actualPoint.x = 30*x+15;
    }
    
    actualPoint.y = y*30+15;
    circle.center = actualPoint;
    
    [circle setColor:color];
    
    if (!temp)
    {
        circle.tag = point.x*10+point.y+1;
        circle.delegate = delegate;
    }
    
    
    [map addSubview:circle];
    
    return circle;
}

- (Circle *)getCircleRow:(int)x Col:(int)y
{
    if ((x>8)||(y>8)||(x<0)||(y<0))
    {
        return nil;
    }
    return (Circle *)[map viewWithTag:(x*10+y+1)];
}

- (void)setBorderCircles
{
    borderCircles = [[NSMutableArray alloc] init];
    for (int i=0;i<9;i++)
    {
        [borderCircles addObject:[self getCircleRow:i Col:0]];
//        [borderCircles addObject:[self getCircleRow:i Col:8]];
//        
//        [borderCircles addObject:[self getCircleRow:0 Col:i]];
//        
//        [borderCircles addObject:[self getCircleRow:8 Col:i]];
    }
    
    NSSet *set = [NSSet setWithArray:borderCircles];
    borderCircles = [NSMutableArray arrayWithArray:[set allObjects]];
}

- (void)createCircles
{
    for (int i=0;i<9;i++)
        for (int j=0;j<9;j++)
            [self createACircleAtPoint:CGPointMake(i, j) temp:NO color:@"gray" delegate:self];
    
    [[self getCircleRow:4 Col:5] setColor:@"blue"];
    blueCircle = [self getCircleRow:4 Col:5];
    [self setDistanceForAll];
    
    [self setBorderCircles];
    
 
    
    
    
}

#pragma functions

- (void)setDistanceForCirclesAround:(Circle *)circle
{
    NSMutableArray *arr = [self circlesAround:circle];
    for (Circle *c in arr)
    {
        if (c.distance > circle.distance +1)
        {
            c.distance = circle.distance + 1;
//            c.lbDistance.text = [NSString stringWithFormat:@"%d",c.distance];
            [self setDistanceForCirclesAround:c];
            
        }
    }
}

- (void)setDistanceForAll
{
    for (int i=0;i<9;i++)
    {
        for (int j=0;j<9;j++)
        {
            [self getCircleRow:i Col:j].distance = 100;
//            [self getCircleRow:i Col:j].lbDistance.text = [NSString stringWithFormat:@"%d",100];
        }
    }
    
    blueCircle.distance = 0;
//    blueCircle.lbDistance.text = @"0";
    [self setDistanceForCirclesAround:blueCircle];
}


- (NSMutableArray *)circlesAround:(Circle *)circle
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    int x = [circle getX];
    int y = [circle getY];
    //
    Circle *c = [self getCircleRow:x-1 Col:y];
    if (c)
        [arr addObject:c];
    c = [self getCircleRow:x+1 Col:y];
    if (c)
        [arr addObject:c];
    
    c = [self getCircleRow:x Col:y+1];
    if (c)
        [arr addObject:c];
    
    c = [self getCircleRow:x Col:y-1];
    if (c)
        [arr addObject:c];
    
    if (y%2==1)
    {
        c = [self getCircleRow:x+1 Col:y-1];
        if (c)
            [arr addObject:c];
        c = [self getCircleRow:x+1 Col:y+1];
        if (c)
            [arr addObject:c];
    }else
    {
        c = [self getCircleRow:x-1 Col:y-1];
        if (c)
            [arr addObject:c];
        c = [self getCircleRow:x-1 Col:y+1];
        if (c)
            [arr addObject:c];
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [arr sortUsingDescriptors:sortDescriptors];
    
    return arr;
}

- (BOOL)checkIfBlueAround:(Circle *)circle
{
    NSMutableArray *arr = [self circlesAround:circle];
    for (Circle *c in arr)
    {
        if ([c circleColor:@"blue"])
        {
            return YES;
        }
    }
    
    return NO;
    
}


- (BOOL)anyRoomForRedCircleComming
{
    for (Circle *c in borderCircles)
    {
        if ([c circleColor:@"gray"])
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)newRedComming
{
    if (![self anyRoomForRedCircleComming])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Game over" message:@"No more room for red" delegate:nil cancelButtonTitle:@"Suck" otherButtonTitles:nil, nil];
            [al show];
        });
        return;
    }

    
    int k = rand() % borderCircles.count;
    while (![[borderCircles objectAtIndex:k] circleColor:@"gray"]) {
        
        k = rand()%borderCircles.count;
    }
    
    Circle *c = borderCircles[k];
    c.alpha = 0;
    [c setColor:@"red"];
    [UIView animateWithDuration:0.2 animations:^{
        c.alpha = 1;
    } completion:^(BOOL finished) {
        nil;
    }];
    [redList addObject:c];
    
}
- (void)moveRedFromCircle:(Circle *)c1 toCircle:(Circle *)c2 completion:(void (^)())completion;
{
    [c1 setColor:@"gray"];
    Circle *tempCircle = [self createACircleAtPoint:CGPointMake(c1.getX, c1.getY) temp:YES color:@"red" delegate:nil];
    noTap = YES;
    [UIView animateWithDuration:0.3 animations:^{
        tempCircle.center = c2.center;
    } completion:^(BOOL finished) {
        noTap = NO;
        [tempCircle removeFromSuperview];
        if (c2==blueCircle)
        {
            if (power == 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Game over" message:@"The red catched blue" delegate:nil cancelButtonTitle:@"Suck" otherButtonTitles:nil, nil];
                    [al show];
                });
                
            }else
            {
                power --;
                c2.numOfRedMoving --;
                c2.lbDistance.text = [NSString stringWithFormat:@"%d",c2.numOfRedMoving];
                self.lblPower.text = [NSString stringWithFormat:@"%d",power];
            }
        }else
        {
            if (c2.numOfRedMoving < 2)
            {
                
                [c2 setColor:@"red"];
            }else
            {
                // collision here
            }
            completion();
        }
    }];
}

- (void)allRedMove: (void (^)())completion
{
    __block int count = redList.count;
    if (count ==0)
        completion();
    else
    {
        for (Circle *redCircle in redList)
        {
            [self moveRedFromCircle:redCircle toCircle:redCircle.dest completion:^() {
                count --;
                if (count ==0)
                    completion();
            }];
        }
    }
    


}

- (void)redChase
{
    [redList removeAllObjects];
    
    for (int i=0;i<9;i++)
        for (int j=0;j<9;j++)
        {
            Circle *c = [self getCircleRow:i Col:j];
            c.numOfRedMoving = 0;
            
            c.lbDistance.text = [NSString stringWithFormat:@"%d",c.numOfRedMoving];
            c.dest = nil;
            
            if ([c circleColor:@"red"])
            {
                [redList addObject:c];
            }
        }
    
    for (Circle *redCircle in redList)
    {
        NSMutableArray *arr = [self circlesAround:redCircle];
        Circle *c = [arr firstObject];
        c.numOfRedMoving++;
        
        c.lbDistance.text = [NSString stringWithFormat:@"%d",c.numOfRedMoving];
        if (c.numOfRedMoving >= 2)
        {
            NSLog(@"upcomming collision : %@ num : %d",c,c.numOfRedMoving);
        }
        
        redCircle.dest = c;
        NSLog(@"redcircle : %@   dest %@", redCircle, redCircle.dest);
        
    }
    
    [self allRedMove:^{
        [redList removeAllObjects];
        
        for (int i=0;i<9;i++)
            for (int j=0;j<9;j++)
            {
                Circle *c = [self getCircleRow:i Col:j];
                if (c.numOfRedMoving==1)
                {
                    [redList addObject:c];
                }else if (c.numOfRedMoving>=2)
                {
                    [c setColor:@"gray"];
                    power+=c.numOfRedMoving;
                    self.lblPower.text = [NSString stringWithFormat:@"%d",power];
                }
            }
        
        
        [self newRedComming];
    }];
    
}

#pragma mark circle delegate

- (void)tapOnCircle:(Circle *)sender
{
    if (noTap)
        return;
    if ([sender circleColor:@"gray"])
    {
        if ([self checkIfBlueAround:sender])
        {
            
            [blueCircle setColor:@"gray"];
            // create temporary circle
            
            Circle *tempCircle = [self createACircleAtPoint:CGPointMake(blueCircle.getX, blueCircle.getY) temp:YES color:@"blue" delegate:nil];
            
            noTap = YES;
            [UIView animateWithDuration:0.3 animations:^{
                tempCircle.center = sender.center;
            } completion:^(BOOL finished) {
                noTap = NO;
                
                [sender setColor:@"blue"];
                blueCircle = sender;
                [self setDistanceForAll];
                
                [tempCircle removeFromSuperview];
                [self redChase];
                
            }];
            
            
            
            
        }
    }else
    {
        // do nothing
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
