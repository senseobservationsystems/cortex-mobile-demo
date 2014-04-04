//
//  FirstViewController.m
//  CortexDemo
//
//  Created by Pim Nijdam on 4/16/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "FallDetectionTabViewController.h"
#import <Cortex/CSSensePlatform.h>
#import <Cortex/FallDetectorModule.h>


static const NSUInteger MAX_ENTRIES = 10;

@interface FallDetectionTabViewController ()

@end

@implementation FallDetectionTabViewController {
    FallDetectorModule* fdm;
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
    fdm = [[FallDetectorModule alloc] init];
    
    //Set the UI for the parameter to the current values
    self.demoSwitch.on = fdm.isDemo;
    self.useInactivitySwitch.on = fdm.useInactivity;
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

- (IBAction) toggleSwitch: (id) sender {
    if (sender == self.demoSwitch) {
        fdm.isDemo = self.demoSwitch.on;
        
    } else if (sender == self.useInactivitySwitch) {
        fdm.useInactivity = self.useInactivitySwitch.on;
    }
    NSLog(@"Demo: %@, use inactivity: %@.", fdm.isDemo ? @"yes" : @"no", fdm.useInactivity ? @"yes" : @"no");
}

- (void) onNewData:(NSNotification*)notification {
    NSString* sensor = notification.object;
    if ([sensor isEqualToString:[fdm name]]) {
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
