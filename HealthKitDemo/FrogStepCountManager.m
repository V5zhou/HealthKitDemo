//
//  FrogStepCountManager.m
//  Frog
//
//  Created by tentinet on 15/6/10.
//  Copyright (c) 2015年 Tentinet. All rights reserved.
//

#import "FrogStepCountManager.h"
#import <CoreMotion/CoreMotion.h>

@interface FrogStepCountManager () {
    CMStepCounter *stepCounter;
    CMPedometer *pedomer;
    CMMotionManager *motion;
    BOOL bM7;                               //是否采用M7计步
}

@end

static FrogStepCountManager *manager = nil;
@implementation FrogStepCountManager

#pragma mark - system
+ (id)shareInstance {
    if (manager == nil) {
        manager = [[self alloc] init];
    }
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        if([UIDevice currentDevice].systemVersion.floatValue > 7.0
           &&[CMStepCounter isStepCountingAvailable]) {
            bM7 = YES;
            stepCounter = [[CMStepCounter alloc] init];
        }
        else {
            bM7 = NO;
            motion = [[CMMotionManager alloc] init];
            motion.accelerometerUpdateInterval = 0.1; // 数据更新时间间隔
        }
    }
    return self;
}

#pragma mark - 开始计步
- (void)startCountWithSteps:(CGFloat)steps {
    _curruntSteps = steps;
    
    //开始计步，两种情况
    if(bM7){
        [self setpCpuntWithM7];         //M7处理器开始计步
    }
    else {
        [self smasherCount];            //加速计开始计步
    }
}

#pragma mark - 停止计步
- (void)stop {
    if (bM7) {
        [stepCounter stopStepCountingUpdates];
    }
    else {
        [motion stopAccelerometerUpdates];
    }
}

#pragma mark - M7计步
- (void)setpCpuntWithM7 {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [stepCounter startStepCountingUpdatesToQueue:queue
                                        updateOn:10
                                     withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error)
     {
         if (error) {
             UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"计步意外停止！" message:@"error" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
             [error show];
         }
         else {
             
         }
     }];
}

#pragma mark - 加速计计步
- (void)smasherCount {
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    
    if (!motion.accelerometerAvailable) {
        NSLog(@"CMMotionManager unavailable");
        return;
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [motion startAccelerometerUpdatesToQueue:queue
                                 withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                     if ([self bShakeWithData:accelerometerData]) {
                                         //
                                         
                                     }
                                 }];
}

//是否晃动
- (BOOL)bShakeWithData:(CMAccelerometerData *)data {
    double x = data.acceleration.x;
    double y = data.acceleration.y;
    double z = data.acceleration.z;
    if (fabs(x)>2.0 ||fabs(y)>2.0 ||fabs(z)>2.0) {
        return YES;
    }
    return NO;
}

@end
