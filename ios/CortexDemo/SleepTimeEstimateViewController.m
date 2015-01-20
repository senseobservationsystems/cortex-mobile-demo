//
//  SleepTimeEstimateViewController.m
//  CortexDemo
//
//  Created by Joris Janssen on 19/01/15.
//  Copyright (c) 2015 Sense Observation Systems BV. All rights reserved.
//

#import "SleepTimeEstimateViewController.h"
#import "SensePlatform/CSSensePlatform.h"
#import "Cortex/Cortex.h"

@implementation SleepTimeEstimateViewController
    NSDate *startDate;
    NSDate *lastAddedPointDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1421712001 = Tue, 20 Jan 2015 00:00:01 GMT
    //1421730000 = Tue, 20 Jan 2015 05:00:00 GMT
    //1421704800 = Tue, 19 Jan 2015 22:00:00 GMT
    
    
    startDate = [NSDate dateWithTimeIntervalSince1970:1421704800];
    lastAddedPointDate = [NSDate dateWithTimeIntervalSince1970:1421704800];
    
    //subscribe to sensor data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewData:) name:kCSNewSensorDataNotification object:nil];
}


- (IBAction) addSleepPoint: (id) sender {
    [self addDataPoints:1];
}

- (void) onNewData: (NSNotification*)notification {
    NSString* sensor = notification.object;
    
    if ([sensor isEqualToString:[Cortex sharedCortex].sleepTimeEstimateModule.name]) {
        
        
//        ([sensor isEqualToString:[Cortex sharedCortex].sleepTimeModule.name]) {
       // NSDate* endDate = [startDate dateByAddingTimeInterval: 5*60*60];
        
        NSArray* sleepTimeData = [CSSensePlatform getLocalDataForSensor:[Cortex sharedCortex].sleepTimeModule.name from:[startDate dateByAddingTimeInterval:-2] to:[lastAddedPointDate dateByAddingTimeInterval:+2]];
        NSArray* sleepTimeEstimateData = [CSSensePlatform getLocalDataForSensor:[Cortex sharedCortex].sleepTimeEstimateModule.name from:[startDate dateByAddingTimeInterval:-2] to:[lastAddedPointDate dateByAddingTimeInterval:+2]];
        
        NSLog(@"Sleep points: %lu", (unsigned long)sleepTimeData.count);
        NSLog(@"Estimate points: %lu", (unsigned long)sleepTimeEstimateData.count);
        
        [self updateLogText: [NSString stringWithFormat:@"Sleep points: %lu\n", (unsigned long)sleepTimeData.count ]];
        [self updateLogText: [NSString stringWithFormat:@"Sleep Estimate points: %lu\n", (unsigned long)sleepTimeEstimateData.count ]];
        
        //NSDictionary* latestSleep = [sleepTimeData lastObject];
        //NSDictionary* latestSleepEstimate = [sleepTimeEstimateData lastObject];
        
        NSNumber *max = [self maxOfSensorDataArray:sleepTimeEstimateData];
        NSLog(@"Result adding datapoints: max estimate - %f", [max floatValue]);
        //NSString * resultSleep = [[latestSleep valueForKey:@"value"] valueForKey:@"value"];
        //NSString * resultSleepEstimate = [[latestSleepEstimate valueForKey:@"value"] valueForKey:@"value"];
        
        //NSLog(@"Result adding datapoints: sleep - %@, estimate - %@", resultSleep, resultSleepEstimate);
        
    }
    
}


- (void) addDataPoints: (int) numberOfPoints {

    NSTimeInterval fiveMinutes = 60*5; //300 seocnds
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @autoreleasepool {
            for(int i = 0; i < numberOfPoints; i++) {
                NSDate *date = [startDate dateByAddingTimeInterval:fiveMinutes*i];
                
 //               NSString *value = [NSString stringWithFormat:@"{\"date\": %f, \"value\": {\"end_date\" : 0.00000000000000, \"metadata\" : {\"core version\" : \"1.4.1-rc1_coaching_v1.28\",\"module version\" : \"1.6.4\",\"status\" : \"awake - device is carried\"}, \"sleepTime\" : 0.00000000000000, \"start_date\" : 0.00000000000000}}", [date timeIntervalSince1970]];
                
                NSString *value = [NSString stringWithFormat:@"{\"end_date\" : 0.00000000000000, \"metadata\" : {\"core version\" : \"1.4.1-rc1_coaching_v1.28\",\"module version\" : \"1.6.4\",\"status\" : \"awake - device is carried\"}, \"sleepTime\" : 0.00000000000000, \"start_date\" : 0.00000000000000}"];
                                   
                [CSSensePlatform addDataPointForSensor:@"sleep_time" displayName:@"Sleep time value" description:@"Dummy sleep data" deviceType:@"dummy" deviceUUID:@"dummy" dataType:@"jsonString" stringValue:value timestamp:date];
                
                if(date > lastAddedPointDate) {
                    lastAddedPointDate = date;
                }
            }
            
        }
    });


}


- (IBAction) add4hoursofSleepPoints: (id) sender {
    [self addDataPoints: (int)(8*12+1)];
}

- (void) updateLogText: (NSString *) newText {
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            NSLog(newText);
            [self.logText setText: [[[self logText] text] stringByAppendingString: newText]];
            //[[self view] setNeedsDisplay];
        }
    });
}

- (NSNumber*) maxOfSensorDataArray: (NSArray*) input {
    
    NSNumber *result = [[NSNumber alloc] init];
    NSNumber* value = [[NSNumber alloc] init];
    
    for(NSDictionary* dict in input) {
        
        value = [[[dict valueForKey:@"value"] valueForKey:@"value"] valueForKey:@"sleepTime"];
        
        if (! result) {result = value;}
        else if (value.doubleValue > result.doubleValue) { result = value; }
    }
    
    return result;
}

@end
