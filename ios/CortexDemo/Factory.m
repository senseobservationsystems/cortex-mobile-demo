//
//  Factory.m
//  CortexDemo
//
//  Created by Pim Nijdam on 7/1/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "Factory.h"

@implementation Factory {
}



//Singleton instance
static Factory* sharedFactoryInstance = nil;

+ (Factory*) sharedFactory {
	if (sharedFactoryInstance == nil) {
		sharedFactoryInstance = [[super allocWithZone:NULL] init];
	}
	return sharedFactoryInstance;
}

//override to ensure singleton
+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedFactory];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (Factory*) init {
    self = [super init];
    if (self) {
        _fallDetectorModule = [[FallDetectorModule alloc] init];
        _stepCounterModule = [[StepCounterModule alloc] init];
        _timeActiveModule = [[TimeActiveModule alloc] init];
        _activityModule = [[ActivityModule alloc] init];
        _carryDeviceModule = [[CarryDeviceModule alloc] init];
    }
    return self;
}

@end
