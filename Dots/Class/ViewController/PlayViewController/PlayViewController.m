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
    numOfDot = 6;
    self.numOfRow.text = [NSString stringWithFormat:@"%d",numOfDot];
    size = self.map.frame.size.width/(numOfDot+0.5);
    [self createCircles];
    turn = 0;
    self.progressView.progress = 0;
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
    self.progressView.transform = transform;
    self.lbTurns.text = @"0";
    
    power = 0;
    
    self.lblPower.text = [NSString stringWithFormat:@"%d",power];
    
    redList = [[NSMutableArray alloc] init];
    noTap = NO;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnMap:)];
    [map addGestureRecognizer:pan];
    // Do any additional setup after loading the view from its nib.
}

- (CGFloat) pointPairToBearingDegrees:(CGPoint)startingPoint secondPoint:(CGPoint) endingPoint
{
    CGPoint originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y); // get origin point to origin by subtracting end from start
    float bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    float bearingDegrees = bearingRadians * (180.0 / M_PI); // convert to degrees
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    return bearingDegrees;
}

- (Circle *)circleFromDegree:(float)degree
{
    degree += 30;
    CGPoint point;
    if (degree<60)
    {
        point = [blueCircle corOfCircleBesidePos:3];
    }else if (degree<120)
    {
        point = [blueCircle corOfCircleBesidePos:2];
        
    }else if (degree<180)
    {
        point = [blueCircle corOfCircleBesidePos:1];
        
    }else if (degree<240)
    {
        point = [blueCircle corOfCircleBesidePos:6];
        
    }else if (degree<300)
    {
        point = [blueCircle corOfCircleBesidePos:5];
        
    }else if (degree<360)
    {
        point = [blueCircle corOfCircleBesidePos:4];
        
    }
    
    return [self getCircleRow:point.x Col:point.y];
}

- (void)panOnMap:(UISwipeGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        // Store the initial touch so when we change positions we do not snap
        startPoint = [gesture locationInView:gesture.view];
        
    }
    
    endPoint = [gesture locationInView:gesture.view];
    float degree = 360-[self pointPairToBearingDegrees:startPoint secondPoint:endPoint];
    
    if ([self circleFromDegree:degree])
    {
        
        if (highlightingCircle !=  [self circleFromDegree:degree]) {
            if (highlightingCircle)
            {
                [highlightingCircle.highlightImageView setHidden:YES];
            }
            
            highlightingCircle = [self circleFromDegree:degree];
            [highlightingCircle.highlightImageView setHidden:NO];
        }
    }
    

    
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
        //All fingers are lifted.

        NSLog(@"degree %f",degree);
        
        
        if (highlightingCircle)
        {
            [highlightingCircle.highlightImageView setHidden:YES];
            [self tapOnCircle:highlightingCircle];
        }
    }
    
    
//    NSLog(@"end point : %f %f", endPoint.x, endPoint.y);
    

    
}

- (Circle *)createACircleAtPoint:(CGPoint)point temp:(BOOL)temp color:(NSString *)color delegate:(id)delegate
{
    Circle *circle = [[[NSBundle mainBundle] loadNibNamed:@"Circle" owner:nil options:nil] objectAtIndex:0];
    [circle setFrame:CGRectMake(0, 0, size, size)];
    [circle.imgView setFrame:CGRectMake(1, 1, size-2, size-2)];
    [circle.highlightImageView setFrame:CGRectMake(1, 1, size-2, size-2)];
    int x = point.x;
    int y = point.y;
    
    CGPoint actualPoint;
    
    if (y%2==1)
    {
        actualPoint.x = size*x+size;
    }else
    {
        actualPoint.x = size*x+size/2;
    }
    
    actualPoint.y = y*size+size/2;
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
    if ((x>(numOfDot-1))||(y>(numOfDot-1))||(x<0)||(y<0))
    {
        return nil;
    }
    return (Circle *)[map viewWithTag:(x*10+y+1)];
}

- (void)setBorderCircles
{
    borderCircles = [[NSMutableArray alloc] init];
    for (int i=0;i<numOfDot;i++)
    {
        [borderCircles addObject:[self getCircleRow:i Col:0]];
        [borderCircles addObject:[self getCircleRow:i Col:(numOfDot-1)]];
        
        [borderCircles addObject:[self getCircleRow:0 Col:i]];
        
        [borderCircles addObject:[self getCircleRow:(numOfDot -1) Col:i]];
    }
    
    NSSet *set = [NSSet setWithArray:borderCircles];
    borderCircles = [NSMutableArray arrayWithArray:[set allObjects]];
}

- (void)createCircles
{
    for (int i=0;i<numOfDot;i++)
        for (int j=0;j<numOfDot;j++)
            [self createACircleAtPoint:CGPointMake(i, j) temp:NO color:@"gray" delegate:self];
    
    int x = numOfDot/2;
    int y = numOfDot/2;
    [[self getCircleRow:x Col:y] setColor:@"blue"];
    blueCircle = [self getCircleRow:x Col:y];
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
    for (int i=0;i<numOfDot;i++)
    {
        for (int j=0;j<numOfDot;j++)
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
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Game over" message:@"No more room for red" delegate:self cancelButtonTitle:@"Suck" otherButtonTitles:nil, nil];
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
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Game over" message:@"The red catched blue" delegate:self cancelButtonTitle:@"Suck" otherButtonTitles:nil, nil];
                    [al show];
                });
                
            }else
            {
                power --;
                c2.numOfRedMoving --;
//                c2.lbDistance.text = [NSString stringWithFormat:@"%d",c2.numOfRedMoving];
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
        }
        
        completion();
    }];
}

- (void)allRedMove: (void (^)())completion
{
    __block int rcount = redList.count;
    if (rcount ==0)
        completion();
    else
    {
        for (Circle *redCircle in redList)
        {
            [self moveRedFromCircle:redCircle toCircle:redCircle.dest completion:^() {
                rcount --;
                if (rcount ==0)
                    completion();
            }];
        }
    }
    


}

- (void)redChase
{
    [redList removeAllObjects];
    
    for (int i=0;i<numOfDot;i++)
        for (int j=0;j<numOfDot;j++)
        {
            Circle *c = [self getCircleRow:i Col:j];
            c.numOfRedMoving = 0;
            
//            c.lbDistance.text = [NSString stringWithFormat:@"%d",c.numOfRedMoving];
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
        
//        c.lbDistance.text = [NSString stringWithFormat:@"%d",c.numOfRedMoving];
        if (c.numOfRedMoving >= 2)
        {
            NSLog(@"upcomming collision : %@ num : %d",c,c.numOfRedMoving);
        }
        
        redCircle.dest = c;
        NSLog(@"redcircle : %@   dest %@", redCircle, redCircle.dest);
        
    }
    
    [self allRedMove:^{
        [redList removeAllObjects];
        
        for (int i=0;i<numOfDot;i++)
            for (int j=0;j<numOfDot;j++)
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

- (BOOL)checkIfDoidienBlue:(Circle *)circle
{
    int bx = blueCircle.getX;
    int by = blueCircle.getY;
    if ((bx>0)&&(bx<numOfDot-1)&&(by>0)&&(by<numOfDot-1))
    {
        // blue not in the border
        return NO;
    }
    
    if ((circle.getX == numOfDot-1-bx) && (circle.getY == numOfDot - 1 - by))
    {
        return YES;
    }
    
    return NO;
    
}


#pragma mark circle delegate

- (void)tapOnCircle:(Circle *)sender
{
    if (noTap)
        return;
    if ([sender circleColor:@"gray"])
    {
        if (([self checkIfBlueAround:sender]) || ([self checkIfDoidienBlue:sender]))
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
                turn ++;
                self.lbTurns.text = [NSString stringWithFormat:@"%d", turn];
                float p = (float)turn/100;
                [self.progressView setProgress:p animated:YES];
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

- (IBAction)resetTapped:(id)sender {
    
    for (int i=0;i<numOfDot; i++)
        for (int j=0;j<numOfDot; j++)
        {
            Circle *c = [self getCircleRow:i Col:j];
            [c removeFromSuperview];
        }
    
    numOfDot = [self.numOfRow.text intValue];
    
    size = self.map.frame.size.width/(numOfDot+0.5);
    [self createCircles];
    
    power = 0;
    turn = 0;
    self.progressView.progress = 0;
    
    self.lblPower.text = [NSString stringWithFormat:@"%d",power];
    
    redList = [[NSMutableArray alloc] init];
    noTap = NO;
    [self.numOfRow resignFirstResponder];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self resetTapped:nil];
}
@end
