//
//  SecondViewController.m
//  CortexDemo
//
//  Created by Pim Nijdam on 4/16/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "CarryDeviceTabViewController.h"
#import <Cortex/Cortex/CarryDeviceModule.h>
#import <Cortex/SensePlatform/CSSensePlatform.h>

@interface CarryDeviceTabViewController ()

@end

@implementation CarryDeviceTabViewController {
    CarryDeviceModule* carryDeviceModule;
    NSString* carryDeviceLog;
    
    NSDateFormatter* dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];

    //subscribe to sensor data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewData:) name:kCSNewSensorDataNotification object:nil];
    

    //setup carry device module
    carryDeviceModule = [[CarryDeviceModule alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) onNewData:(NSNotification*)notification {
    NSString* sensor = notification.object;
    if ([sensor isEqualToString:@"CarryDevice"]) {
        id json = [notification.userInfo valueForKey:@"value"];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[[notification.userInfo valueForKey:@"date"] doubleValue]];

        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
            carryDeviceLog = [NSString stringWithFormat:@"%@\n%@:%@", carryDeviceLog, [dateFormatter stringFromDate:date], json];
            [self.logText setText:carryDeviceLog];
            }
        });
    }
}

@end
