//
//  BLEdetector.h
//  ofxBLE
//
//  Created by kim jung un on 5/16/13.
//  Copyright (c) 2013 azuremous.net All rights reserved.
//

#pragma once
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// Debug
#define BLE_DEBUG

#ifdef BLE_DEBUG
#define BLE_LOG(...) NSLog(__VA_ARGS__)
#define BLE_LOG_METHOD NSLog(@"%@/%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))
#else
#define BLE_LOG(...)
#define BLE_LOG_METHOD
#endif

@class alarmBLE;
@protocol alarmBLEdelegate <NSObject>

-(void)alarmDiscoverBLE;
-(void)alarmConnectBLE;
-(void)alarmDisconnectBLE;

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
@property(nonatomic, retain)CBUUID *RXUUID;
@property(nonatomic, retain)CBUUID *TXEUUID;
@property(readonly)NSInteger RX_data;
@property(readwrite)NSInteger TX_data;
@property(readonly)BOOL discoveredUUID;
@property(readonly)BOOL beConnected;

-(BOOL)startScan;
-(void)stopScan;
-(BOOL)connect:(CBPeripheral*)peripheral;
-(BOOL)disconnect;

-(void)writeTX:(unsigned char)data;

@end
