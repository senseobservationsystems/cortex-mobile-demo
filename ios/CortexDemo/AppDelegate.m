//
//  AppDelegate.m
//  CortexDemo
//
//  Created by Pim Nijdam on 4/16/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "AppDelegate.h"
#import <Cortex/Cortex.h>
#import <SensePlatform/CSSensePlatform.h>
#import <SensePlatform/CSSettings.h>
#import <Cortex/CoachingEngine/CSCoachingEngine.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    //Setup sense platform
    [CSSensePlatform initialize];
    //initialize cortex
    [Cortex sharedCortex];

    self->_loadingDate = [NSDate date];
    
    //initialize coaching engine.
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCoachMessage:) name:kCORTEX_COACHING_ENGINE_NEW_MESSAGE_NOTIFICATION object:nil];
    //[[CSCoachingEngine sharedCoachingEngine] initializeWithAppKey:appKey ];
    //set into simulation mode
    //[CSSensorRequirements sharedRequirements].isEnabled = NO;
    //[CSCoachingEngine sharedCoachingEngine].simulationMode = YES;
    //[[CSCoachingEngine sharedCoachingEngine] loginWithUser:user withPassword:password success:nil failure:^(NSError* error) {
    //    NSLog(@"$$$$$$$$$$$$$ Failure to login ^^^^^^^^^^^^^^^^^^^^^^^^^");
    //}];

    
    //set the requirements, i.e. all sensors that the demo uses
    Cortex* cortex = [Cortex sharedCortex];
    NSString* consumerName = @"com.sense.cortexdemo";
    NSArray* commonRequirements = @[@{kCSREQUIREMENT_FIELD_SENSOR_NAME:cortex.timeActiveModule.name},
                                    @{kCSREQUIREMENT_FIELD_SENSOR_NAME:cortex.carryDeviceModule.name},
                                    @{kCSREQUIREMENT_FIELD_SENSOR_NAME:cortex.sitStandModule.name},
                                    @{kCSREQUIREMENT_FIELD_SENSOR_NAME:cortex.activityModule.name},
                                    @{kCSREQUIREMENT_FIELD_SENSOR_NAME:cortex.sleepTimeModule.name},
                                    @{kCSREQUIREMENT_FIELD_SENSOR_NAME:cortex.sleepTimeEstimateModule.name},
                                    @{kCSREQUIREMENT_FIELD_SENSOR_NAME:cortex.stepCounterModule.name},
                                    @{kCSREQUIREMENT_FIELD_SENSOR_NAME:cortex.loudnessModule.name},
                                    //@{kCSREQUIREMENT_FIELD_SENSOR_NAME:cortex.locationTraceModule.name},
                                    @{kCSREQUIREMENT_FIELD_SENSOR_NAME:kCSSENSOR_BATTERY},
                                    @{kCSREQUIREMENT_FIELD_SENSOR_NAME:kCSSENSOR_CALL},
                                    @{kCSREQUIREMENT_FIELD_SENSOR_NAME:kCSSENSOR_CONNECTION_TYPE},
                                    @{kCSREQUIREMENT_FIELD_SENSOR_NAME:kCSSENSOR_SCREEN_STATE},
                                    //@{kCSREQUIREMENT_FIELD_SENSOR_NAME:kCSSENSOR_ACCELERATION_BURST, kCSREQUIREMENT_FIELD_SAMPLE_INTERVAL:@30},
                                    //@{kCSREQUIREMENT_FIELD_SENSOR_NAME:kCSSENSOR_ACCELEROMETER_BURST, kCSREQUIREMENT_FIELD_SAMPLE_INTERVAL:@30},
                                    //@{kCSREQUIREMENT_FIELD_SENSOR_NAME:kCSSENSOR_NOISE, kCSREQUIREMENT_FIELD_SAMPLE_INTERVAL:@10},
                                    //location sensor is needed so that we keep running in the background
                                    @{kCSREQUIREMENT_FIELD_SENSOR_NAME:kCSSENSOR_LOCATION, kCSREQUIREMENT_FIELD_SAMPLE_ACCURACY:@10000}];
    [[CSSensorRequirements sharedRequirements] setRequirements:commonRequirements byConsumer:consumerName];
    
    //enable uploading to common sense
    [[CSSettings sharedSettings] setSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingUploadToCommonSense value:kCSSettingYES];
    
    [[CSSettings sharedSettings] setSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingDontUploadBursts value:kCSSettingYES];
    
    //pause location updates for 2/3 minutes between every location update
    [[CSSettings sharedSettings] setSettingType:kCSSettingTypeLocation setting:kCSLocationSettingCortexAutoPausing value:kCSSettingYES];

    //enable the background restart hack
    [[CSSettings sharedSettings] setSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingBackgroundRestarthack value:kCSSettingYES];
    
    //Don't record audio when the screen is on. This avoids users being annoyed by an iOS red bar
    [[CSSettings sharedSettings] setSettingType:kCSSettingTypeAmbience setting:kCSAmbienceSettingSampleOnlyWhenScreenLocked value:kCSSettingNO];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) handleCoachMessage:(NSNotification*) notification {
    Message* msg = notification.userInfo[@"message"];
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            NSString* text = [NSString stringWithFormat:@"%@: %@: %@", [Coach stringFromCoachType:msg.coachType], [Message stringFromMessageType:msg.type], msg.fullText];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:msg.title message:text delegate:nil cancelButtonTitle:@"Got it" otherButtonTitles: nil];
        [alert show];
        });
        
    } else {
        NSString* text = [NSString stringWithFormat:@"%@: %@: %@", [Coach stringFromCoachType:msg.coachType], [Message stringFromMessageType:msg.type], msg.notificationText];
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = nil;
        localNotification.alertAction = @"Show me more";
        localNotification.alertBody = text;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

@end
