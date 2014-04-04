//
//  SecondViewController.m
//  CortexDemo
//
//  Created by Pim Nijdam on 4/16/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "CarryDeviceTabViewController.h"
#import <Cortex/CarryDeviceModule.h>
#import <Cortex/CSSensePlatform.h>
#import "Factory.h"

static const NSUInteger MAX_ENTRIES = 60;

@interface CarryDeviceTabViewController ()

@end

@implementation CarryDeviceTabViewController {
    CarryDeviceModule* carryDeviceModule;
    NSMutableArray* carryDeviceLog;
    
    NSDateFormatter* dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    carryDeviceLog = [[NSMutableArray alloc] init];

    //subscribe to sensor data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewData:) name:kCSNewSensorDataNotification object:nil];
    

    //setup carry device module
    carryDeviceModule = [Factory sharedFactory].carryDeviceModule;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) onNewData:(NSNotification*)notification {
    NSString* sensor = notification.object;
    if ([sensor isEqualToString:[carryDeviceModule name]]) {
        id json = [notification.userInfo valueForKey:@"value"];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[[notification.userInfo valueForKey:@"date"] doubleValue]];

        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                //only look at the carried state, as the others don't work on iOS anyway
                bool carried = [(NSNumber*)[(NSDictionary*)json valueForKey:@"carried"] boolValue];
                NSString* value = carried ? @"Device is being carried": @"Device is not being carried";
                NSString* entry = [NSString stringWithFormat:@"%@:%@", [dateFormatter stringFromDate:date], value];
                //log entry
                [carryDeviceLog insertObject:entry atIndex:0];
                while ([carryDeviceLog count] > MAX_ENTRIES) {
                    [carryDeviceLog removeLastObject];
                }
                
                
                [self.logText setText:[carryDeviceLog componentsJoinedByString:@"\n"]];
            }
        });
    }
}

@end
