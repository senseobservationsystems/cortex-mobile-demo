//
//  PersistencyViewController.m
//  CortexDemo
//
//  Created by Joris Janssen on 12/01/15.
//  Copyright (c) 2015 Sense Observation Systems BV. All rights reserved.
//

#import "PersistencyViewController.h"
#import "Cortex/Cortex.h"
#import "Cortex/CSSensePlatform.h"

@interface PersistencyViewController ()

@end

@implementation PersistencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//fills up the database to about 110mb and to see if it can handle gowing over the limit
- (IBAction) testDatabaseFillUp:(id)sender {
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
       @autoreleasepool {
        //Fill up like crazy so that we have some decently sized db
        int totalPoints = 15000;
        [self updateLogText:[NSString stringWithFormat:@"Starting ... free space: %lli mb, db size: %lli \n", [[self getFreeSpaceOnDisk] longLongValue]/(1000*1000), [[self getDbSize] longLongValue]/(1000*1000)]];
        NSString *value = [self getHugeDatapoint];
        
        for( int i = 0; i < totalPoints; i++) { // add totalPoints points
            //put one datapoint in the database
        @autoreleasepool {
            [CSSensePlatform addDataPointForSensor:@"dummySensor" displayName:@"dummyDisplayName" description:@"dummyDescription" dataType:@"dummyDataType" stringValue:value timestamp:[NSDate date]];
            
            if(i%1000 == 0) {
             //   [NSThread sleepForTimeInterval:.5];
                [self updateLogText:[NSString stringWithFormat:@"Another %d points added, free space: %lli mb, db size: %lli mb\n", totalPoints, [[self getFreeSpaceOnDisk] longLongValue]/(1000*1000), [[self getDbSize] longLongValue]/(1000*1000)]];
            }
        }
        }
        [self updateLogText:[NSString stringWithFormat:@"Done adding %d points. Free space %lli, Db size: %lli mb\n", totalPoints, [[self getFreeSpaceOnDisk] longLongValue]/(1000*1000), [[self getDbSize] longLongValue]/(1000*1000)]];
       }
    });
    //NSLog(@"Number of rows: %li", [storage getNumberOfRowsInTable:@"data"]);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark Helper functions

/*
 * Returns the number of bytes of free space on the disk
 */

- (NSNumber *) getFreeSpaceOnDisk {
    NSError *error = nil;
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    
    NSDictionary *fileSystemAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:docDirectory error:&error];
    //NSLog(@"Free space on file system: %@ bytes", [fileSystemAttributes objectForKey:NSFileSystemFreeSize]);
    
    return [fileSystemAttributes objectForKey:NSFileSystemFreeSize];
}

- (NSNumber *) getDbSize {
    NSError *error = nil;
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* dbPath =[rootPath stringByAppendingPathComponent:@"data.db"];
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:dbPath error:&error];
    // NSLog(@"Local database store size: %@ bytes", [fileAttributes objectForKey:NSFileSize]);
    
    return [fileAttributes objectForKey:NSFileSize];
}

- (void) updateLogText: (NSString *) newText {
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            NSLog(newText);
            [self.logText setText: [[[self logText] text] stringByAppendingString: newText]];
    //[[self view] setNeedsDisplay];
        }
    });
}

- (NSString *) getHugeDatapoint {
    
    return [NSString stringWithFormat:@"Point %i - this is a huge datapoint  - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint this is a huge datapoint  - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapointthis is a huge datapoint  - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint - this is a huge datapoint", 1];
}

@end
