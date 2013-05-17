//
//  ofxBLE.m
//  ofxBLE
//
//  Created by kim jung un on 5/16/13.
//  Copyright (c) 2013 azuremous.net All rights reserved.
//

#import "ofxBLE.h"

@implementation ofxBLEdelegate

-(id)init
{
    BLE = [[BLEdetector alloc] init];
    [BLE setDiscoveryDelegate:self];
    return self;
}

-(void)dealloc
{
    [BLE release];
    BLE = nil;
    [super dealloc];
}
-(BOOL)scan{ return [BLE startScan]; }
-(void)stopScan{ [BLE stopScan]; }

-(void)setBLE:(NSString *)_BLEUUIDstring
{
    BLE.BLEUUID = [[CBUUID UUIDWithString:_BLEUUIDstring] retain];
}
-(void)setRX:(NSString *)_RXUUIDstring
{
    BLE.RXUUID = [[CBUUID UUIDWithString:_RXUUIDstring] retain];
}
-(void)setTX:(NSString *)_TXUUIDstring
{
    BLE.TXEUUID = [[CBUUID UUIDWithString:_TXUUIDstring] retain];
}
-(BOOL)connect:(NSInteger)num
{
    NSArray * devices = [BLE  discoveredPeripherals];
    //NSLog(@"devices:%@", BLE.discoveredPeripherals);
    CBPeripheral * peripheral = (CBPeripheral*)[devices objectAtIndex:num];
    //return true;
    return [BLE connect:peripheral];
}
-(BOOL)disconnect
{
    return [BLE disconnect];
}
-(BOOL)beConnected
{
    return [BLE beConnected];
}

#pragma mark - delegate

-(void)alarmDiscoverBLE{ if ([BLE discoveredUUID]) ofMessage("alarmDiscoverBLE"); }
-(void)alarmConnectBLE{ if ([BLE beConnected]) ofMessage("alarmConnectBLE"); }
-(void)alarmDisconnectBLE{ if (![BLE beConnected]) ofMessage("alarmDisconnectBLE"); }

@end

//////////////////////////////////////////////////////
//////////////////      ofxBLE     //////////////////
////////////////////////////////////////////////////

ofxBLE::ofxBLE():bConnectedBLE(false)
{
    
}

ofxBLE::~ofxBLE(){
    
    [BLEmodule dealloc];
}

bool ofxBLE::setup(){
    BLEmodule = [[ofxBLEdelegate alloc] init];
    return true;
}

bool ofxBLE::setup(string _BLEUUID, string _RXUUID, string _TXUUID){
    
    BLEmodule = [[ofxBLEdelegate alloc] init];
    setBLE(_BLEUUID);
    setRX(_RXUUID);
    setTX(_TXUUID);
    return true;
}

void ofxBLE::setBLE(string _uuid){
    [BLEmodule setBLE:[NSString stringWithFormat:@"%s",_uuid.c_str()]];
}

void ofxBLE::setRX(string _uuid){
    [BLEmodule setRX:[NSString stringWithFormat:@"%s",_uuid.c_str()]];
}

void ofxBLE::setTX(string _uuid){
    [BLEmodule setTX:[NSString stringWithFormat:@"%s",_uuid.c_str()]];
}

void ofxBLE::scan(){
    [BLEmodule scan];
}

void ofxBLE::stopScan(){
    [BLEmodule stopScan];
}

void ofxBLE::connectAction(int num){
    
    if (!bConnectedBLE) connect(num);
    else disconnect();
}

void ofxBLE::connect(int num){
    bConnectedBLE = [BLEmodule connect:num];
}

void ofxBLE::disconnect(){
    if([BLEmodule disconnect]) bConnectedBLE = false;
}
