//
//  FrogStepCountManager.h
//  Frog
//
//  Created by tentinet on 15/6/10.
//  Copyright (c) 2015年 Tentinet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrogStepCountManager : NSObject

+ (id)shareInstance;

/**
 *  开始计步
 */
- (void)startCountWithSteps:(CGFloat)steps;

/**
 *  停止计步
 */
- (void)stop;

@property (nonatomic, assign ,readonly)CGFloat curruntSteps;                           //当前步数

@end
