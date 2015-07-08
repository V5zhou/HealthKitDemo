//
//  HealthKitManager.m
//  HealthKitDemo
//
//  Created by tentinet on 15/6/3.
//  Copyright (c) 2015年 tentinet. All rights reserved.
//

#import "HealthKitManager.h"

@interface HealthKitManager () {
    NSMutableArray *_stepCountArray;                 //一周行走步数数组
}

@end

static HealthKitManager *manager = nil;
@implementation HealthKitManager

+ (id)shareInstance {
    if (manager == nil) {
        manager = [[self alloc] init];
    }
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        
        [self makeDateFormat];
        
        //生成存放字典数组
        _stepCountArray = [NSMutableArray array];
    }
    return self;
}

- (void)makeDateFormat {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy年MM月dd日-H";
    format.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    self.dateFormat = format;
}

- (void)requestAuthorizationWithHandler:(void (^)(NSDictionary *))completionHandler {
    self.healthStore = [[HKHealthStore alloc] init];
    [_healthStore requestAuthorizationToShareTypes:nil readTypes:[self dataTypesToRead] completion:^(BOOL success, NSError *error) {

        if (!success) {
            NSDictionary *dic = @{@"code":@"0",@"msg":[NSString stringWithFormat:@"获取权限失败:%@",error]};
            if (completionHandler) {
                completionHandler(dic);
            }
            return;
        }
        else {
            NSDictionary *dic = @{@"code":@"1",@"msg":@"获取权限成功！"};
            if (completionHandler) {
                completionHandler(dic);
            }
        }
        
    }];
}

- (NSSet *)dataTypesToRead {
    //申请读取计步功能权限
    NSSet *set = [NSSet setWithObjects:
        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],nil];
    return set;
}

#pragma mark - 刷新数据

/**
 *  计步，返回数组，数组内为每一小时的值
 */
- (void)updateStepOnTheDay:(NSString *)day withHandler:(void (^)(NSArray *))completionHandler {
    
    [_stepCountArray removeAllObjects];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:[NSDate date]];
    
    NSInteger maxHour = 24;
    //判断输入是否为今天
    if ([[_dateFormat stringFromDate:[NSDate date]] isEqualToString:day]) {         //是今天
        
        maxHour = [components hour] + 1;
    }
    
    for (NSInteger i = 0; i < maxHour; i ++) {
        NSDate *date = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:-i toDate:[NSDate date] options:0];
        [self updateStepCountWithDate:date completionHandler:^(NSDictionary *dictionary){
            
            //加入数组
            [_stepCountArray addObject:dictionary];
            
            //当数组中元素为7个时,执行回调
            if (_stepCountArray.count >= maxHour) {
                if (completionHandler) {
                    
                    //按日期排序
                    NSArray *sortDesc = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
                    NSArray *resultArray = [_stepCountArray sortedArrayUsingDescriptors:sortDesc];
                    
                    //返回排序后数组
                    completionHandler(resultArray);
                }
            }
        }];
    }
}

- (void)updateStepCountWithDate:(NSDate *)date completionHandler:(void (^)(NSDictionary *))completionHandler{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:date];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:0];
    
    HKQuantityType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:sampleType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        
        if (!result) {
            NSLog(@"%@",error);
            NSDictionary *dic = @{@"date":startDate,@"stepCount":[NSNumber numberWithDouble:0]};
            if (completionHandler) {
                completionHandler(dic);
            }
        }
        
        double totalCalories = [result.sumQuantity doubleValueForUnit:[HKUnit countUnit]];
        NSDictionary *dic = @{@"date":startDate,@"stepCount":[NSNumber numberWithDouble:totalCalories]};
        if (completionHandler) {
            completionHandler(dic);
        }
    }];
    [self.healthStore executeQuery:query];
}

/**
 *  计消耗热量，返回指定日期值
 */
- (void)updateEnergyBurnedOnTheDay:(NSString *)day withHandler:(void (^)(NSDictionary *))completionHandler {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:[_dateFormat dateFromString:day]];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    HKQuantityType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:sampleType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        
        if (!result) {
            NSLog(@"%@",error);
            NSDictionary *dic = @{@"date":endDate,@"energyBurned":[NSNumber numberWithDouble:0]};
            if (completionHandler) {
                completionHandler(dic);
            }
        }
        
        double totalCalories = [result.sumQuantity doubleValueForUnit:[HKUnit kilocalorieUnit]];
        NSDictionary *dic = @{@"date":endDate,@"energyBurned":[NSNumber numberWithDouble:totalCalories]};
        if (completionHandler) {
            completionHandler(dic);
        }
    }];
    [self.healthStore executeQuery:query];
}

@end
