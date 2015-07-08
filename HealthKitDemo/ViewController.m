//
//  ViewController.m
//  HealthKitDemo
//
//  Created by tentinet on 15/6/2.
//  Copyright (c) 2015年 tentinet. All rights reserved.
//

#import "ViewController.h"
#import "HealthKitManager.h"
#import "FrogStepCountManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    HealthKitManager *manager = [HealthKitManager shareInstance];
//    NSString *dateString = [manager.dateFormat stringFromDate:[NSDate date]];
//    dateString = @"2015年06月8日-10";
//    //申请权限
//    [manager requestAuthorizationWithHandler:^(NSDictionary *dic) {
//        if ([[dic objectForKey:@"code"] integerValue] == 0) {   //权限失败
//            NSLog(@"%@",[dic objectForKey:@"msg"]);
//        }
//        else {
//            NSLog(@"%@",[dic objectForKey:@"msg"]);
//            //获取步数数组
//            [manager updateStepOnTheDay:dateString withHandler:^(NSArray *stepCountArray) {
//                for (NSInteger i = 0; i < stepCountArray.count; i++) {
//                    NSDictionary *dic = stepCountArray[i];
//                    NSLog(@"%@--->%@步",[manager.dateFormat stringFromDate:[dic objectForKey:@"date"]],[dic objectForKey:@"stepCount"]);
//                }
//            }];
//            
//            //获取消耗卡路里
//            [manager updateEnergyBurnedOnTheDay:dateString withHandler:^(NSDictionary *dic) {
//                NSLog(@"%@",dic);
//            }];
//        }
//    }];
    
    FrogStepCountManager *manager = [FrogStepCountManager shareInstance];
    [manager startCountWithSteps:1000];
    [manager addObserver:self forKeyPath:@"curruntSteps" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"curruntSteps"]) {
        NSLog(@"%@",[change objectForKey:@"new"]);
    }
}

@end
