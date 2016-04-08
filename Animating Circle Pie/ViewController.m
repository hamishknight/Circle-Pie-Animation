//
//  ViewController.m
//  Animating Circle Pie
//
//  Created by Hamish Knight on 08/04/2016.
//  Copyright © 2016 Redonkulous Apps. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) CAShapeLayer* circleLayer;

@end

@implementation ViewController {
    CABasicAnimation* drawAnimation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat radius = self.view.bounds.size.width*0.25-10;
    
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:(CGPoint){self.view.bounds.size.width*0.5, self.view.bounds.size.height*0.5} radius:radius startAngle:-M_PI*0.5 endAngle:M_PI*3.0/2.0 clockwise:YES];
    
    
    self.circleLayer = [CAShapeLayer layer];
    self.circleLayer.frame = self.view.bounds;
    self.circleLayer.strokeColor = [UIColor blackColor].CGColor;
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.path = path.CGPath;
    self.circleLayer.lineWidth = radius*2.0;
    self.circleLayer.strokeEnd = 0.0;
    [self.view.layer addSublayer:self.circleLayer];
    
    
    // define your animation
    drawAnimation = [CABasicAnimation animation];
    drawAnimation.duration = 1;
    
    // use an NSNumber literal to make your code easier to read
    drawAnimation.fromValue = @(0.0f);
    drawAnimation.toValue   = @(1.0f);
    
    // your timing function
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // kick off the animation loop
    [self animate];
    
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.circleLayer removeFromSuperlayer];
}

-(void) animate {
    
    if (self.circleLayer.superlayer) { // check circle layer is the layer heirachy before attempting to animate
        
        // begin your transaction
        [CATransaction begin];
        
        // prevent implicit animations from being generated
        [CATransaction setDisableActions:YES];
        
        // reset values
        self.circleLayer.strokeEnd = 0.0;
        self.circleLayer.strokeStart = 0.0;
        
        // update key path of animation
        drawAnimation.keyPath = @"strokeEnd";
        
        // set your completion block of forward animation
        [CATransaction setCompletionBlock:^{
            
            // weak link to self to prevent a retain cycle
            __weak ViewController* weakSelf = self;
            
            // begin new transaction
            [CATransaction begin];
            
            // prevent implicit animations from being generated
            [CATransaction setDisableActions:YES];
            
            // set completion block of backward animation to call animate (recursive)
            [CATransaction setCompletionBlock:^{
                [weakSelf animate];
            }];
            
            // re-use your drawAnimation, just changing the key path
            drawAnimation.keyPath = @"strokeStart";
            
            // add backward animation
            [weakSelf.circleLayer addAnimation:drawAnimation forKey:@"circleBack"];
            
            // update your layer to new stroke start value
            weakSelf.circleLayer.strokeStart = 1.0;
            
            // end transaction
            [CATransaction commit];
            
        }];
        
        // add forward animation
        [self.circleLayer addAnimation:drawAnimation forKey:@"circleFront"];
        
        // update layer to new stroke end value
        self.circleLayer.strokeEnd = 1.0;
        
        [CATransaction commit];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
