//
//  ActivityTabViewController.m
//  CortexDemo
//
//  Created by Pim Nijdam on 7/2/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "ActivityTabViewController.h"
#import <Cortex/Cortex.h>
#import <Cortex/ActivityModule.h>
#import <SensePlatform/CSSensePlatform.h>
#import <SensePlatform/CSSettings.h>

static const size_t MAX_ENTRIES = 60;

@implementation ActivityTabViewController{
    ActivityModule* pam;
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
    pam = [Cortex sharedCortex].activityModule;
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

- (void) onNewData:(NSNotification*)notification {
    NSString* sensor = notification.object;
    if ([sensor isEqualToString:[pam name]]) {
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
