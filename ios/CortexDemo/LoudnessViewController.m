//
//  LoudnessViewController.m
//  CortexDemo
//
//  Created by Joris Janssen on 12/01/15.
//  Copyright (c) 2015 Sense Observation Systems BV. All rights reserved.
//

#import "LoudnessViewController.h"
#import "Cortex/Cortex.h"
#import "SensePlatform/CSSensePlatform.h"
#import "AppDelegate.h"
#include <stdlib.h>

@interface LoudnessViewController ()

@end

@implementation LoudnessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
       
    //subscribe to sensor data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewData:) name:kCSNewSensorDataNotification object:nil];
    
    //fastforward
    [self fastforward];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) fastForward:(id)sender {
    [self fastforward];
}

- (void) fastforward {
    [self simulateNoiseDataOf:100];
}

//Add some noise data to fast forward
- (void) simulateNoiseDataOf: (int)numberOfPoints {

    for(int i = 0; i < numberOfPoints; i++) {
        
        int value = arc4random_uniform(74);
        
        [CSSensePlatform addDataPointForSensor:kCSSENSOR_NOISE displayName:@"Noise" description:@"Dummy noise data" deviceType:@"dummy" deviceUUID:@"dummy" dataType:@"string" stringValue:[NSString stringWithFormat:@"%d",value] timestamp:[NSDate date]];
    }
}

- (void) onNewData: (NSNotification*)notification {
    NSString* sensor = notification.object;
        
    NSString* loudnessModuleName = [Cortex sharedCortex].loudnessModule.name;
    
    if ([sensor isEqualToString:loudnessModuleName] || [sensor isEqualToString:kCSSENSOR_NOISE]) {
    
        NSDate* startDate = [[NSDate date] dateByAddingTimeInterval: -60*60*24]; // 24 hours ago
        
        //((AppDelegate*)[UIApplication sharedApplication]).loadingDate;
        NSArray* noiseData = [CSSensePlatform getLocalDataForSensor:kCSSENSOR_NOISE from:startDate to:[NSDate date]];
        NSArray* loudnessData = [CSSensePlatform getLocalDataForSensor:loudnessModuleName from:startDate to:[NSDate date]];
        
        //NSTimeInterval timeSinceLoading = [[NSDate date] timeIntervalSinceDate: startDate];
        
        //calculate min, max, and average of noise data
        
        NSNumber *noiseMin, *noiseMax, *noiseAvg, *loudnessAvg, *nNoise, *nLoudness;
        
        if (noiseData) {
            NSLog(@"Noisedata found.. %d rows", noiseData.count);
            noiseMin = [self minOfSensorDataArray:noiseData];
            noiseMax = [self maxOfSensorDataArray:noiseData];
            noiseAvg = [NSNumber numberWithFloat:[self avgOfSensorDataArray:noiseData]];
            nNoise = [NSNumber numberWithInt:noiseData.count];
        } else {
            NSLog(@"No noise data found ...");
            noiseMin = [NSNumber numberWithDouble: 0.0];
            noiseMax = [NSNumber numberWithDouble: 0.0];
            noiseAvg = [NSNumber numberWithDouble: 0.0];
            nNoise = [NSNumber numberWithInt:0];
        }
        
        
        if (loudnessData) {
            loudnessAvg = [NSNumber numberWithFloat:[self avgOfSensorDataArray:loudnessData]];
            nLoudness = [NSNumber numberWithInt:loudnessData.count];
        } else {
            loudnessAvg = [NSNumber numberWithDouble: 0.0];
            nLoudness = [NSNumber numberWithInt:0];
        }
        
        //create string and set the new text
        NSString* newText = [NSString stringWithFormat:@"DATA FROM LAST 24h \n NOISE -- min: %f - max %f - avg %f (n: %d) \n LOUDNESS avg %f (n: %d)",
                             [noiseMin floatValue], [noiseMax floatValue], [noiseAvg floatValue], [nNoise intValue], [loudnessAvg floatValue], [nLoudness intValue]];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [self.logText setText:newText];
            }
        });
        
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Helper functions for calculating min, max, and avg


//note that we assume the right format here, no need for fancy processing, this is just a test application
- (NSNumber*) minOfSensorDataArray: (NSArray*) input {
    
    NSNumber *result = [[NSNumber alloc] init];
    NSNumber* value = [[NSNumber alloc] init];
    
    for(NSDictionary* dict in input) {
        
        value = [[dict valueForKey:@"value"] valueForKey:@"value"];
        
        if (! result) {result = value;}
        if (value.doubleValue < result.doubleValue) { result = value; }
    }
    
    return result;
}

- (NSNumber*) maxOfSensorDataArray: (NSArray*) input {
    
    NSNumber *result = [[NSNumber alloc] init];
    NSNumber* value = [[NSNumber alloc] init];
    
    for(NSDictionary* dict in input) {
        
        value = [[dict valueForKey:@"value"] valueForKey:@"value"];
        
        if (! result) {result = value;}
        else if (value.doubleValue > result.doubleValue) { result = value; }
    }
    
    return result;
}

- (float) avgOfSensorDataArray: (NSArray*) input {
    
    float sum = 0.0;
    
    for(NSDictionary* dict in input) {
        sum += [(NSNumber *)[[dict valueForKey:@"value"] valueForKey:@"value"] floatValue];
    }
    
    return sum / input.count;
}

@end
