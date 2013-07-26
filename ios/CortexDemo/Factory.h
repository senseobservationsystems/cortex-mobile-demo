//
//  Factory.h
//  CortexDemo
//
//  Created by Pim Nijdam on 7/1/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cortex/FallDetectorModule.h>
#import <Cortex/StepCounterModule.h>
#import <Cortex/TimeActiveModule.h>
#import <Cortex/CarryDeviceModule.h>
#import <Cortex/ActivityModule.h>

@interface Factory : NSObject

+ (Factory*) sharedFactory;

@property (strong, nonatomic, readonly) FallDetectorModule* fallDetectorModule;
@property (strong, nonatomic, readonly) StepCounterModule* stepCounterModule;
@property (strong, nonatomic, readonly) TimeActiveModule* timeActiveModule;
@property (strong, nonatomic, readonly) CarryDeviceModule* carryDeviceModule;
@property (strong, nonatomic, readonly) ActivityModule* activityModule;

@end
