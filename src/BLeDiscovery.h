//
//  BLeDiscovery.h
//  BLeDiscovery
//
//  Created by kim jung un a.k.a azuremous on 8/14/12.
//  Copyright (c) 2012 azuremous.net All rights reserved.
//
#pragma once
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString *BLEUUIDString;
extern NSString *RXUUIDString;
extern NSString *TXUUIDString;

@class BLeDiscovery;

@protocol BLeDiscoveryDelegate <NSObject>
-(void)alarmDiscoverBLE;
-(void)alarmconnect;
-(void)alarmDisconectedBLE;
-(void)alarmChangeValue:(NSString*)value;
@end

@interface BLeDiscovery : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate> {
    
    CBPeripheral * activePeripheral;
    CBService *BLECBService;
    CBCharacteristic * RXCharacteristic;
    CBUUID *RXUUID;
    
}

@property (nonatomic, assign) id <BLeDiscoveryDelegate> discoveryDelegate;
@property (strong, nonatomic) CBCentralManager * manager;

- (void) startScan;
- (void) stopScan;
- (void) connectPeripheral:(CBPeripheral*)peripheral;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;

@property (strong, nonatomic) NSMutableArray * discoveredPeripherals;
@property (retain, nonatomic) NSMutableArray *connectedServices;
@property (readonly) CBPeripheral *peripheral;
@property (readwrite) BOOL discoverUUID;
@end
