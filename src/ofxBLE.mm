//
//  ofxBLE.m
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
-(BOOL)scan { return [BLE startScan]; }
-(void)stopScan { [BLE stopScan]; }

-(void)setBLE:(NSString *)_BLEUUIDstring
{
    BLE.BLEUUID = [[CBUUID UUIDWithString:_BLEUUIDstring] retain];
    BLE.BLEUUUIDstring = _BLEUUIDstring;
}

-(void)getData:(NSString *)_UUIDstring { [BLE readData:_UUIDstring]; }

-(void)setNotification:(NSString *)_UUIDstring with:(BOOL)_switch
{
    [BLE setNotification:_UUIDstring status:_switch];
}

-(BOOL)connect:(NSInteger)num
{
    if (BLE.discoveredUUID) {
        NSArray * devices = [BLE  discoveredPeripherals];
        BLE_LOG(@"devices:%@", BLE.discoveredPeripherals);
        CBPeripheral * peripheral = (CBPeripheral*)[devices objectAtIndex:num];
        return [BLE connect:peripheral];
    }
    return false;
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

-(void)alarmFind{
    ofSendMessage("find action start");
}

-(void)alarmDiscoverBLE:(NSUInteger)_id name:(NSString *)_name{
    
    if ([BLE discoveredUUID]){
        ofSendMessage("Discover");
        char * number = new char[5];
        sprintf(number, "%d", _id);
        ofSendMessage(number);
        const char * namePtr = [_name UTF8String];
        ofSendMessage(namePtr);
        delete [] number;
    }
}
-(void)alarmConnectBLE{ if ([BLE beConnected]) ofSendMessage("alarmConnectBLE"); }
-(void)alarmDisconnectBLE{ if (![BLE beConnected]) ofSendMessage("alarmDisconnectBLE"); }
-(void)alarmDiscoverCharacteristic{ if([BLE beConnected]) ofSendMessage("alarmReady"); }
-(void)alarmChangeValue:(NSString*)value{
    
    const char * _value = [value UTF8String];
    BLE_LOG(@"data:%@",value);
    ofSendMessage(_value);
}

@end

//--------------------------------------------------------------
/*public */ofxBLE::ofxBLE():bConnectedBLE(false)
{
    
}

//--------------------------------------------------------------
/*public */ofxBLE::~ofxBLE(){
    
    [BLEmodule disconnect];
    [BLEmodule dealloc];
}

//--------------------------------------------------------------
/*public */bool ofxBLE::setup(){
    BLEmodule = [[ofxBLEdelegate alloc] init];
    return true;
}

//--------------------------------------------------------------
/*public */bool ofxBLE::setup(string _BLEUUID){
    
    BLEmodule = [[ofxBLEdelegate alloc] init];
    setBLE(_BLEUUID);
    return true;
}

//--------------------------------------------------------------
/*public */void ofxBLE::setNotification(string _uuid, bool _switch)
{
    [BLEmodule setNotification:sToNS(_uuid) with:_switch];
}

//--------------------------------------------------------------
/*public */void ofxBLE::connectAction(int num){
    
    if (!bConnectedBLE) connect(num);
    else disconnect();
}

//--------------------------------------------------------------
/*protected */void ofxBLE::connect(int num){ bConnectedBLE = [BLEmodule connect:num]; }

//--------------------------------------------------------------
/*protected */void ofxBLE::disconnect(){ if([BLEmodule disconnect]) disconnected(); }

//--------------------------------------------------------------
/*protected */NSString * ofxBLE::sToNS(string _s){ return [NSString stringWithFormat:@"%s",_s.c_str()]; }

