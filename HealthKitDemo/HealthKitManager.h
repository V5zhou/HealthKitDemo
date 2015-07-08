//
//  HealthKitManager.h
//  HealthKitDemo
//
//  Created by tentinet on 15/6/3.
//  Copyright (c) 2015年 tentinet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface HealthKitManager : NSObject

+ (id)shareInstance;

/**
 * 申请认证权限
 */
- (void)requestAuthorizationWithHandler:(void (^)(NSDictionary *))completionHandler;

/**
 *  计步，返回数组，数组内为每一小时的值
 */
- (void)updateStepOnTheDay:(NSString *)day withHandler:(void (^)(NSArray *))completionHandler;

/**
 *  计消耗热量，返回指定日期值
 */
- (void)updateEnergyBurnedOnTheDay:(NSString *)day withHandler:(void (^)(NSDictionary *))completionHandler;

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) NSDateFormatter *dateFormat;

@end
