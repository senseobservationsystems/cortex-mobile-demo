//
//  FirstViewController.m
//  CortexDemo
//
//  Created by Pim Nijdam on 4/16/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "FallDetectionTabViewController.h"
#import <Cortex/SensePlatform/CSSensePlatform.h>
#import <Cortex/Cortex/FallDetectorModule.h>

@interface FallDetectionTabViewController ()

@end

@implementation FallDetectionTabViewController {
    FallDetectorModule* fdm;
    NSString* fallLog;
    
    NSDateFormatter* dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    fallLog = @"";
    
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
    // Release any retained subviews of the main view.
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
    if ([sensor isEqualToString:@"fall detector"]) {
        NSString* json = [notification.userInfo valueForKey:@"value"];
        id data = [notification.userInfo valueForKey:@"value"];
        NSLog(@"DATA: <%@> %@", [data class], data);
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[[notification.userInfo valueForKey:@"date"] doubleValue]];

        bool fall = [[data valueForKey:@"fall"] boolValue];
        bool criticalFall = [[data valueForKey:@"critical free fall"] boolValue];
        NSLog(@"Fall: %@, critical fall: %@", fall? @"yes":@"no", criticalFall ? @"yes":@"no");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {

            fallLog = [NSString stringWithFormat:@"%@\n%@:%@", fallLog, [dateFormatter stringFromDate:date], json];
            [self.logText setText:fallLog];
            }
        });
    }
}

@end
