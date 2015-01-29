//
//  CoachesViewController.m
//  CortexDemo
//
//  Created by Pim Nijdam on 04/08/14.
//  Copyright (c) 2014 Sense Observation Systems BV. All rights reserved.
//

#import "CoachesViewController.h"
#import <Cortex/CoachingEngine/CSCoachingEngine.h>
#import <SensePlatform/CSSensePlatform.h>
#import <Cortex/Cortex.h>

@implementation CoachesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setExerciseGoal:(id)sender {
    [CSCoachingEngine sharedCoachingEngine].simulationTime = [NSDate date];
    [[CSCoachingEngine sharedCoachingEngine].exerciseCoach setManualGoalDailyExercise:20*60];
    [self injectData];
}

- (void) injectData {
    NSDate* now = [NSDate date];

    NSString* sensor = [Cortex sharedCortex].timeActiveModule.name;
    NSString* description = sensor;
    double value = 0;
    
    //send initial data point
    [CSSensePlatform addDataPointForSensor:sensor displayName:nil description:description dataType:kCSDATA_TYPE_FLOAT stringValue:@(value) timestamp:now];
    //send too low data point
    value = 19*60;
    [CSSensePlatform addDataPointForSensor:sensor displayName:nil description:description dataType:kCSDATA_TYPE_FLOAT stringValue:@(value) timestamp:now];
    value = 30 * 60;
    [CSSensePlatform addDataPointForSensor:sensor displayName:nil description:description dataType:kCSDATA_TYPE_FLOAT stringValue:@(value) timestamp:now];
}

- (IBAction)synchronizeWithServer:(id)sender {
    [[CSCoachingEngine sharedCoachingEngine] synchronizeWithServer];
}

- (void) updateText {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
