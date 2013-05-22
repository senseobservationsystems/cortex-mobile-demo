//
//  DebugTabViewController.m
//  CortexDemo
//
//  Created by Pim Nijdam on 5/2/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "DebugTabViewController.h"
#import <mach/mach.h>
#import <asl.h>

@interface DebugTabViewController ()

@end

@implementation DebugTabViewController {
    NSMutableString* totalReport;
    NSDateFormatter* dateFormatter;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    totalReport = [[NSMutableString alloc] init];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) report:(id)sender {
    [totalReport appendFormat:@"%@ - %@\n", [dateFormatter stringFromDate:[NSDate date]], report_memory()];
    [self.logText setText:totalReport];
}

- (IBAction) reportLog:(id)sender {
    [self.logText setText:[self getLog]];
    //scroll to bottom
    [self.logText scrollRangeToVisible:NSMakeRange(self.logText.text.length, 0)];
}

NSString* report_memory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        return [NSString stringWithFormat:@"Memory in use: %u kb", info.resident_size/1024];
    } else {
        return [NSString stringWithFormat:@"Error with task_info(): %s", mach_error_string(kerr)];
    }
}

- (NSString*) getLog {
    aslmsg q, m;
    int i;
    const char *key, *val;
    
    NSMutableString* log = [[NSMutableString alloc] init];

    
    q = asl_new(ASL_TYPE_QUERY);
    
    aslresponse r = asl_search(NULL, q);
    while (NULL != (m = aslresponse_next(r)))
    {
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
        
        for (i = 0; (NULL != (key = asl_key(m, i))); i++)
        {
            NSString *keyString = [NSString stringWithUTF8String:(char *)key];
            
            val = asl_get(m, key);
            
            NSString *string = [NSString stringWithUTF8String:val];
            [tmpDict setValue:string forKey:keyString];
        }
        NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:[[tmpDict valueForKey:@"Time"] doubleValue]];
        [log appendFormat:@"%@ %@:%@\n\n", [dateFormatter stringFromDate:timestamp],[tmpDict valueForKey:@"Sender"], [tmpDict valueForKey:@"Message"]];
    }
    aslresponse_free(r);
    return log;
}

@end
