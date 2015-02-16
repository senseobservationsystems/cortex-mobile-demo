//
//  DataCoverageTestViewController.m
//  CortexDemo
//
//  Created by Frehun Demissie on 02/02/15.
//  Copyright (c) 2015 Sense Observation Systems BV. All rights reserved.
//

#import "DataCoverageTestViewController.h"
#import "SensePlatform/CSSensePlatform.h"
#import "Cortex/Cortex.h"
#import "AppDelegate.h"
#import <Foundation/Foundation.h>


//static NSString* const user = @"unittesttestuser_958344";
//static NSString* const password = @";jadsf8wurljksdfw3rw";


@interface DataCoverageTestViewController ()

@end


@implementation DataCoverageTestViewController
    

NSDate *startDate;
NSDate *endDate;
NSDate *lastAddedPointDate;
//NSDateFormatter *formatter;
int *receivedPoints;
int nrLastPoints;
float timeInterval;



/* the three sensors
 NSString* const kCSSENSOR_ACCELEROMETER
 NSString* const kCSSENSOR_LOCATION
 NSString* const kCSSENSOR_NOISE
 */
    

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    
       // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testDataCoverage:) name:kCSNewSensorDataNotification object:nil];
}


- (IBAction) testDataCoverage:(id)sender {
    

    [CSSensePlatform initialize];
    //[CSSensePlatform loginWithUser:user andPassword:password];
    
    timeInterval = 24*60.0*60.0;
    
    [_summaryText setText:@""];
    
    endDate = [NSDate date];
    startDate = [[NSDate date] dateByAddingTimeInterval:-timeInterval];
    nrLastPoints = 999;
    
    
    // selecet required sensors
    
    NSString* nameAccelerometerSensor = @"accelerometer";
    NSString* nameLocationSensor = @"position";
    NSString* nameNoiseSensor = @"noise_sensor";
    
    
    // get data from CommonSense CSSensePlatform 
    
    NSArray *accelerometerData = [CSSensePlatform getDataForSensor:nameAccelerometerSensor onlyFromDevice:YES nrLastPoints:nrLastPoints];
    
    
    NSArray *accelerometerLocalData = [CSSensePlatform getLocalDataForSensor:nameAccelerometerSensor from: startDate to: endDate];

    NSArray *locationData = [CSSensePlatform getDataForSensor:nameLocationSensor onlyFromDevice:YES nrLastPoints:nrLastPoints];
    
    NSArray *locationLocalData = [CSSensePlatform getLocalDataForSensor:nameLocationSensor from: startDate to: endDate];
    
    NSArray *noiseData = [CSSensePlatform getDataForSensor:nameNoiseSensor onlyFromDevice:YES nrLastPoints:nrLastPoints];
    
    NSArray *noiseLocalData = [CSSensePlatform getLocalDataForSensor:nameNoiseSensor from: startDate to: endDate];
    
    
    NSDictionary *lastRemotePoint = [noiseData lastObject];
    NSDate *lastRemoteDate = [lastRemotePoint valueForKey:@"timestamp"];
    
    NSDictionary *firstRemotePoint = [noiseData objectAtIndex:0];
    NSDate *firstRemoteDate = [firstRemotePoint valueForKey:@"timestamp"];
    
    NSTimeInterval  timeFirstToLastRemotepoint = [lastRemoteDate timeIntervalSinceDate:firstRemoteDate];
    
    double totalNoMinutesRemote = timeFirstToLastRemotepoint/60.0;
    
    NSTimeInterval totalTimeLocal = [endDate timeIntervalSinceDate:startDate];
    
    double totalNoMinutesLocal = totalTimeLocal/60.0;
    
    
    NSLog(@"First Point Date : %@",  firstRemoteDate);
    NSLog(@"Last Point Date : %@",  lastRemoteDate);
  
    
    /*Last Point Date : {
        timestamp = "2015-02-06 17:13:40 +0000";
        value =     {
            date = "1423242820.316";
            value = "34.7";
        };*/
    
    
    double accLocalPerMinute = accelerometerLocalData.count/totalNoMinutesLocal;
    NSLog(@"Accelerometer Local Points per min : %f", accLocalPerMinute);
    
    double locationLocalPerMinute = locationLocalData.count/totalNoMinutesLocal;
    NSLog(@"Location Local Points per min : %f", locationLocalPerMinute);
    
    double noiseLocalPerMinute = noiseLocalData.count/totalNoMinutesLocal;
    NSLog(@"Noise Local Points per min : %f", noiseLocalPerMinute);
    
    double accPerMinute = accelerometerData.count/totalNoMinutesLocal;
    NSLog(@"Accelerometer Remote Points per min : %f", accPerMinute);
    
    double locationPerMinute = locationData.count/totalNoMinutesLocal;
    NSLog(@"Location Remote Points per min : %f", locationPerMinute);
    
    double noisePerMinute = noiseData.count/totalNoMinutesLocal;
    NSLog(@"Noise Remote Points per min : %f", noisePerMinute);
    
    
    NSString *startDateString = [NSDateFormatter localizedStringFromDate:startDate
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    
    NSLog(@"Start Date %@\n", startDateString);
    
    
    NSString *endDateString = [NSDateFormatter localizedStringFromDate:endDate
                                                               dateStyle:NSDateFormatterShortStyle
                                                               timeStyle:NSDateFormatterShortStyle];
    NSLog(@"End Date : %@\n", endDateString);
    
    
    
    //[self.summaryText setText: [NSString stringWithFormat:@"Start Date : %@\n", startDateString]];
    
    //[self.summaryText setText: [NSString stringWithFormat:@"%@", endDateString]];
    
    
    
    [self updateSummaryText: [NSString stringWithFormat:@"Start Date    : %@\n", startDateString]];
    [self updateSummaryText: [NSString stringWithFormat:@"End Date      : %@\n", endDateString]];
   // [self updateSummaryText: [NSString stringWithFormat:@"Time Interval Local  : %@\n", [self timeFormatted:totalTimeLocal]]];
    //[self updateSummaryText: [NSString stringWithFormat:@"Time Interval Remote : %@\n", [self timeFormatted:timeFirstToLastRemotepoint]]];
    
    [self updateSummaryText: [NSString stringWithFormat:@"Accelerometer Data Stat : \n"]];
    [self updateSummaryText: [NSString stringWithFormat:@" o Number of Local Points       = %0.d\n", (int) accelerometerLocalData.count]];
    [self updateSummaryText: [NSString stringWithFormat:@" o Number of Remote Points      = %0.d\n", (int) accelerometerData.count]];
    [self updateSummaryText: [NSString stringWithFormat:@" o Max. Number of Local Points  = %0.f\n", (int) timeInterval/60.0]];
    
    [self updateSummaryText: [NSString stringWithFormat:@"Noise Data Stat : \n"]];
    [self updateSummaryText: [NSString stringWithFormat:@" o Number of Local Points       = %0.d\n", (int) noiseLocalData.count]];
    [self updateSummaryText: [NSString stringWithFormat:@" o Number of Remote Points      = %0.d\n", (int) noiseData.count]];
    [self updateSummaryText: [NSString stringWithFormat:@" o Max. Number of Local Points  = %0.f\n", (int) timeInterval/60.0]];
    
    [self updateSummaryText: [NSString stringWithFormat:@"Location Data Stat : \n"]];
    [self updateSummaryText: [NSString stringWithFormat:@" o Number of Local Points      = %0.d\n", (int) locationLocalData.count]];
    [self updateSummaryText: [NSString stringWithFormat:@" o Number of Remote Points     = %0.d\n", (int) locationData.count]];
    [self updateSummaryText: [NSString stringWithFormat:@" o Max. Number of Local Points = %0.f\n", (int) timeInterval/120.0]];
    

    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) updateSummaryText: (NSString *) newSummaryText {
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
        
            [self.summaryText setText: [[[self summaryText] text] stringByAppendingString: newSummaryText]];
            [[self view] setNeedsDisplay];
        }
    });
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

@end
