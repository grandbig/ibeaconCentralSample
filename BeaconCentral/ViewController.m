//
//  ViewController.m
//  iBeaconSampleCentral
//
//  Created by Takahiro on 2014/04/12.
//  Copyright (c) 2014年 grandbig.github.io. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet NSUUID *proximityUUID;
@property (strong, nonatomic) IBOutlet CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) IBOutlet CLBeacon *nearestBeacon;
@property (strong, nonatomic) IBOutlet NSString *str;

@end

@implementation ViewController

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
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Central";
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"8D4DB809-032F-4771-96F3-99BD5C25F924"];
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID: self.proximityUUID
                                                               identifier:@"com.kato.ibeaconSample"];
        [self.locationManager startMonitoringForRegion: self.beaconRegion];
    } else {
        //iBeaconが利用できないOS, Deviceの場合
        NSLog(@"お使いの端末ではiBeaconを利用できません。");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"確認"
                                                        message:@"お使いの端末ではiBeaconを利用できません。"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 領域計測が開始した場合
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Start Monitoring Region"];
}

// 指定した領域に入った場合
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Enter Region"];
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

// 指定した領域から出た場合
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

// Beacon信号を検出した場合
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        //CLBeacon *nearestBeacon = beacons.firstObject;
        self.nearestBeacon = beacons.firstObject;
        
        NSString *rangeMessage;
        
        switch (self.nearestBeacon.proximity) {
            case CLProximityImmediate:
                rangeMessage = @"Range Immediate";
                break;
            case CLProximityNear:
                rangeMessage = @"Range Near";
                break;
            case CLProximityFar:
                rangeMessage = @"Range Far";
                break;
            default:
                rangeMessage = @"Range Unknown";
                break;
        }
        
        self.str = [[NSString alloc] initWithFormat:@"%f [m]", self.nearestBeacon.accuracy];
        NSLog(@"%@", self.str);
        [self sendLocalNotificationForMessage:rangeMessage];
    }
}

// 領域観測に失敗した場合
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
}

#pragma mark - Private methods

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
