//
//  PBLViewController.m
//  PatientSafety
//
//  Created by 霍瑞鋒 on 2014/05/06.
//  Copyright (c) 2014年 kakuhrf. All rights reserved.
//

#import "PBLViewController.h"

@interface PBLViewController ()

@end

@implementation PBLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Beacon対象が存在すれば、初期化する
	if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        // CLLocationManagerの生成とデリゲートの設定
        self.manager = [CLLocationManager new];
        self.manager.delegate = self;
        
        // 監視対象UUIDを設定する
        NSString *uuid = @"268549C8-D64B-40B8-8217-C9673E0C7226";
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:uuid];
        
        // CLBeaconRegionを作成する
        self.region = [[CLBeaconRegion alloc]
                       initWithProximityUUID:self.proximityUUID
                       identifier:@"jp.ac.aiit.PatientSafety"];
        // 領域に入った事を監視する
        self.region.notifyOnEntry = YES;
        // 領域に出た事を監視する
        self.region.notifyOnExit = YES;
        // デバイスのディスプレイがオンの時、ビーコン通知が送信されないように設定する
        self.region.notifyEntryStateOnDisplay = NO;
        
        // 領域監視を開始する
        [self.manager startMonitoringForRegion:self.region];
        // 距離測定を開始する
        [self.manager startRangingBeaconsInRegion:self.region];
        
    }
}

// Beaconに入ったときに呼ばれる
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self sendNotification:@"didEnterRegion for PatientSafety"];
}

- (void)sendNotification:(NSString*)message
{
    // 通知を作成する
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = [[NSDate date] init];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = message;
    notification.alertAction = @"Open";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    // 通知を登録する
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}


// Beaconから出たときに呼ばれる
- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self sendNotification:@"didExitRegion for PatientSafety"];
}

// Beaconとの状態が確定したときに呼ばれる
- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    switch (state) {
        case CLRegionStateInside:
            NSLog(@"CLRegionStateInside");
            [self playSound:@"enter"];
            break;
        case CLRegionStateOutside:
            NSLog(@"CLRegionStateOutside");
            [self playSound:@"exit"];
            break;
        case CLRegionStateUnknown:
            NSLog(@"CLRegionStateUnknown");
            break;
        default:
            break;
    }
}

- (void)playSound:(NSString*)name
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:name ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    SystemSoundID sndId;
    OSStatus err = AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &sndId);
    if (!err) {
        AudioServicesPlaySystemSound(sndId);
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    CLProximity proximity = CLProximityUnknown;
    NSString *proximityString = @"CLProximityUnknown";
    CLLocationAccuracy locationAccuracy = 0.0;
    NSInteger rssi = 0;
    //NSNumber* major = @0;
    NSNumber* major = @1;
    NSNumber* minor = @0;
    
    // 最初のオブジェクト = 最も近いBeacon
    CLBeacon *beacon = beacons.firstObject;
    
    proximity = beacon.proximity;
    locationAccuracy = beacon.accuracy;
    rssi = beacon.rssi;
    major = beacon.major;
    minor = beacon.minor;
    
    CGFloat alpha = 1.0;
    switch (proximity) {
        case CLProximityUnknown:
            proximityString = @"CLProximityUnknown";
            alpha = 0.3;
            break;
        case CLProximityImmediate:
            proximityString = @"CLProximityImmediate";
            alpha = 1.0;
            break;
        case CLProximityNear:
            proximityString = @"CLProximityNear";
            alpha = 0.8;
            break;
        case CLProximityFar:
            proximityString = @"CLProximityFar";
            alpha = 0.5;
            break;
        default:
            break;
    }
    
    self.uuidLabel.text = beacon.proximityUUID.UUIDString;
    self.majorLabel.text = [NSString stringWithFormat:@"%@", major];
    self.minorLabel.text = [NSString stringWithFormat:@"%@", minor];
    self.proximityLabel.text = proximityString;
    self.accuracyLabel.text = [NSString stringWithFormat:@"%f", locationAccuracy];
    self.rssiLabel.text = [NSString stringWithFormat:@"%ld", (long)rssi];
    
    if ([minor isEqualToNumber:@1]) {
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0.749 blue:1.0 alpha:alpha];
    } else {
        self.view.backgroundColor = [UIColor colorWithRed:0.663 green:0.663 blue:0.663 alpha:1.0];
    }
    
    if (minor != nil && self.currentMinor != nil && ![minor isEqualToNumber:self.currentMinor]) {
        [self playSound:@"change"];
    }
    self.currentMinor = minor;
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"kCLAuthorizationStatusNotDetermined");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"kCLAuthorizationStatusRestricted");
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"kCLAuthorizationStatusDenied");
            break;
        case kCLAuthorizationStatusAuthorized:
            NSLog(@"kCLAuthorizationStatusAuthorized");
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
