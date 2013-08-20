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
-(BOOL)scan {
    return [BLE checkStatus];
}
    //return [BLE startScan]; }
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
        CBPeripheral * peripheral = (CBPeripheral*)[devices objectAtIndex:num];
        
        return [BLE connect:peripheral];
    }
    return false;
}

-(BOOL)connectWithID:(NSString *)_id
{
    if (BLE.discoveredUUID) {
        NSArray * devices = [BLE discoveredPeripherals];
        BLE_LOG(@"get id is:%@", _id);
        for (int i = 0; i < devices.count; i++) {
            CBPeripheral *peripheral = [devices objectAtIndex:i];
            
            if (memcmp(_id, peripheral.name, sizeof(NSString*)) == 0) {
                BLE_LOG(@"connect success!!:%@", peripheral.name);
                return [BLE connect:peripheral];
            }else{
                BLE_LOG(@"connect fail:%@", peripheral.name);
                return false;
            }
        }
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

-(NSString*)getBLEID
{
    return [BLE BLEID];
}

#pragma mark - delegate

-(void)alarmFind{
    ofSendMessage("find action start");
}

-(void)alarmDiscoverBLE{
    
    if ([BLE discoveredUUID]){ ofSendMessage("Discover"); }
    //if (!BLE.discoveredUUID) { BLE.discoveredUUID = true; }
}
-(void)alarmConnectBLE{ if ([BLE beConnected]) ofSendMessage("try to connect"); }
-(void)alarmDisconnectBLE{ if (![BLE beConnected]) ofSendMessage("Disconnected BLE"); }
-(void)alarmDiscoverCharacteristic{ if([BLE beConnected]) ofSendMessage("ready BLE"); }
-(void)alarmChangeValue:(NSString*)value{
    
    const char * _value = [value UTF8String];
    ofSendMessage(_value);
}

@end

//--------------------------------------------------------------
/*public */ofxBLE::ofxBLE()
:_bConnectedBLE(false)
,_bRealConnect(false)
{
    
}

//--------------------------------------------------------------
/*public */ofxBLE::~ofxBLE(){
    
    [_BLEmodule disconnect];
    [_BLEmodule dealloc];
}

//--------------------------------------------------------------
/*public */bool ofxBLE::setup(){
    _BLEmodule = [[ofxBLEdelegate alloc] init];
    return true;
}

//--------------------------------------------------------------
/*public */bool ofxBLE::setup(string _BLEUUID){
    
    _BLEmodule = [[ofxBLEdelegate alloc] init];
    setBLE(_BLEUUID);
    return true;
}

//--------------------------------------------------------------
/*public */void ofxBLE::setNotification(string _uuid, bool _switch)
{
    [_BLEmodule setNotification:sToNS(_uuid) with:_switch];
}

//--------------------------------------------------------------
/*public */void ofxBLE::connectAction(int num){
    
    if (!_bConnectedBLE) connect(num);
    else disconnect();
}

//--------------------------------------------------------------
/*public */void ofxBLE::connectActionWithID(string id){
    if (!_bConnectedBLE) connectWithID(id);
    else disconnect();
}

//--------------------------------------------------------------
/*public */void ofxBLE::disconnected(){
    _status = BLE_DISCONNECT;
    _bRealConnect = false;
    _bConnectedBLE = false;
}

//--------------------------------------------------------------
/*public */bool ofxBLE::checkStatus(ofMessage _msg){
    
    string _msgString = _msg.message;
    if (_msgString == "find action start") {
        _status = BLE_FIND;
    }else if (_msgString == "Discover") {
        _status = BLE_DISCOVER;
    }else if (_msgString == "try to connect") {
        _status = BLE_TRY_CONNECT;
    }else if (_msgString == "Disconnected BLE") {
        disconnected();
    }else if (_msgString == "ready BLE") {
        _status = BLE_CONNECT;
        _bRealConnect = true;
    }else if (_msgString != " " && _bRealConnect){
        return true;
    }
    return false;
}

//--------------------------------------------------------------
/*public */string ofxBLE::getID(){
    
    const char * _value = [[_BLEmodule getBLEID] UTF8String];
    //string _id(_value, 12, 8);
    return _value;
}

//--------------------------------------------------------------
/*protected */void ofxBLE::connect(int num){ _bConnectedBLE = [_BLEmodule connect:num]; }

//--------------------------------------------------------------
/*protected */void ofxBLE::connectWithID(string id){ _bConnectedBLE = [_BLEmodule connectWithID:sToNS(id)]; }

//--------------------------------------------------------------
/*protected */void ofxBLE::disconnect(){ if([_BLEmodule disconnect]) disconnected(); }

//--------------------------------------------------------------
/*protected */NSString * ofxBLE::sToNS(string _s){ return [NSString stringWithFormat:@"%s",_s.c_str()]; }

