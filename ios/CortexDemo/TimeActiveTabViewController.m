//
//  TimeActiveTabViewController.m
//  CortexDemo
//
//  Created by Pim Nijdam on 7/26/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//
#import <Cortex/Cortex.h>
#import "TimeActiveTabViewController.h"
#import <SensePlatform/CSSensePlatform.h>
#import <Cortex/TimeActiveModule.h>

@implementation TimeActiveTabViewController{
    TimeActiveModule* tam;
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
    
    //setup module
    tam = [Cortex sharedCortex].timeActiveModule;
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

- (IBAction) resetTimeActive:(id)sender {
    [tam reset];
}

- (void) onNewData:(NSNotification*)notification {
    NSString* sensor = notification.object;
    if ([sensor isEqualToString:[tam name]]) {
        NSString* json = [notification.userInfo valueForKey:@"value"];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[[notification.userInfo valueForKey:@"date"] doubleValue]];
        
        NSTimeInterval totalSeconds = [json doubleValue];
        int hours = totalSeconds / 3600;
        int minutes = ((int)(totalSeconds / 60)) % 60;
        int seconds = ((int)totalSeconds) % 60;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                NSString* entry = [NSString stringWithFormat:@"%@: Active for %.2i:%.2i:%.2i", [dateFormatter stringFromDate:date], hours, minutes, seconds];
                
                [self.logText setText:entry];
            }
        });
    }
}

@end
