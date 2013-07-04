//
//  StepCounterTabViewController.m
//  CortexDemo
//
//  Created by Pim Nijdam on 7/1/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "Factory.h"
#import "StepCounterTabViewController.h"
#import <Cortex/CSSensePlatform.h>
#import <Cortex/StepCounterModule.h>

static const NSUInteger MAX_ENTRIES = 10;

@implementation StepCounterTabViewController{
    StepCounterModule* scm;
    NSMutableArray* fallLog;
    
    NSDateFormatter* dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    fallLog = [[NSMutableArray alloc] init];
    
    //subscribe to sensor data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewData:) name:kCSNewSensorDataNotification object:nil];

    //setup fall detector module
    scm = [Factory sharedFactory].stepCounterModule;

    self.sensitivitySlider.value = [scm getSensitivity];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) resetStepCount: (id) sender {
    [scm resetStepCounter];
}

- (IBAction) setSensitivity:(UISlider *)sensitivitySlider {
    NSLog(@"Set sensitivity %f ", sensitivitySlider.value);
    [scm setSensitivity:sensitivitySlider.value];
}

- (void) onNewData:(NSNotification*)notification {
    NSString* sensor = notification.object;
    if ([sensor isEqualToString:@"step counter"]) {
        NSString* json = [notification.userInfo valueForKey:@"value"];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[[notification.userInfo valueForKey:@"date"] doubleValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                NSString* entry = [NSString stringWithFormat:@"%@:%@", [dateFormatter stringFromDate:date], json];
                [fallLog insertObject:entry atIndex:0];
                while ([fallLog count] > MAX_ENTRIES) {
                    [fallLog removeLastObject];
                }
                
                [self.logText setText:[fallLog componentsJoinedByString:@"\n"]];
            }
        });
    }
}

@end
