//
//  BLEdetector.h
//
//  Created by kim jung un on 5/16/13.
//  Copyright (c) 2013 azuremous.net All rights reserved.
//

#pragma once
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// Debug
#define BLE_DEBUGs

#ifdef BLE_DEBUG
#define BLE_LOG(...) NSLog(__VA_ARGS__)
#define BLE_LOG_METHOD NSLog(@"%@/%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))
#else
#define BLE_LOG(...)
#define BLE_LOG_METHOD
#endif
//

@class alarmBLE;
@protocol alarmBLEdelegate <NSObject>

-(void)alarmFind;
-(void)alarmDiscoverBLE:(NSUInteger)_id name:(NSString *)_name;
-(void)alarmConnectBLE;
-(void)alarmDiscoverCharacteristic;
-(void)alarmDisconnectBLE;
-(void)alarmChangeValue:(NSString*)value;

@end

@interface BLEdetector : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    NSMutableArray *peripherals;
    CBCentralManager *CBmanager;
    CBPeripheral *activePeripheral;
}

@property(nonatomic, assign) id <alarmBLEdelegate> discoveryDelegate;
@property(nonatomic, strong)NSMutableArray * discoveredPeripherals;
@property(nonatomic, retain)CBUUID *BLEUUID;
@property(nonatomic, retain)CBUUID *getUUID;
@property(nonatomic, retain)NSString * BLEUUUIDstring;
@property(readonly)BOOL discoveredUUID;
@property(readonly)BOOL beConnected;

-(BOOL)startScan;
-(void)stopScan;
-(BOOL)connect:(CBPeripheral*)peripheral;
-(BOOL)disconnect;

-(void)sendData:(NSString *)_UUIDstring with:(NSData *)_data;
-(void)readData:(NSString *)_UUIDstring;
-(void)setNotification:(NSString *)_UUIDstring status:(BOOL)notice;

@end
