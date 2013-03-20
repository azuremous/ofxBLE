//
//  ofxBLE.mm
//  ofxBLE
//
//  Created by kim jung un a.k.a azuremous on 8/15/12.
//  Copyright (c) 2012 azuremous.net All rights reserved.
//

#include "ofxBLE.h"

@implementation ofxBLEDelgate

-(id)init{
    
    BLE = [[BLeDiscovery alloc] init];
    [BLE setDiscoveryDelegate:self];
    return self;
}

-(void)dealloc{
    
    [BLE release];
    [super dealloc];
}

-(void)scan{
    
    [BLE startScan];
}

-(BOOL)connect{
    if (BLE.discoverUUID) {
        NSArray * devices = [BLE  discoveredPeripherals];
        CBPeripheral * peripheral = (CBPeripheral*)[devices objectAtIndex:0];
        
        if (![peripheral isConnected]) {
            [BLE connectPeripheral:peripheral];
            NSString *dataDescription = [peripheral description];
            NSLog(@"conect:%@",dataDescription);
            return true;
        }
    }
    return false;
}

-(BOOL)disconnect{
    
    CBPeripheral * peripheral = [BLE peripheral];
    NSString *dataDescription = [peripheral description];
    NSLog(@"disconect:%@",dataDescription);
    if ([peripheral isConnected]) {
        [BLE disconnectPeripheral:peripheral];
        return false;
    }
    
    return true;
}

-(BOOL)IsBLEConnected{
    
    CBPeripheral	*peripheral;
    NSArray			*devices;
    devices = [BLE  connectedServices];
    peripheral = [(BLeDiscovery*)[devices objectAtIndex:0] peripheral];
    
    if ([peripheral isConnected]) {
        return true;
    }
    
    return false;
}

#pragma mark -
#pragma mark bluetoothDelegate

-(void)alarmDiscoverBLE{ ofSendMessage("alarmDiscoverBLE"); }

-(void)alarmconnect{ ofSendMessage("alarmconnecting"); }

-(void)alarmDisconectedBLE{ ofSendMessage("alarmDisconnectedBLE"); }

-(void)alarmChangeValue:(NSString*)value{
    
    const char * _value = [value UTF8String];
    string valueString = _value;
    ofSendMessage(valueString);
    
}

@end

//////////////////////////////////////////////////////
//////////////////        c++       //////////////////
//////////////////////////////////////////////////////

ofxBLE::ofxBLE():bSetUUID(false),connectedBLE(false)
{
    
}

ofxBLE::~ofxBLE(){
    
    [bleModule release];
}

void ofxBLE::setup(){
    
    bleModule = [[ofxBLEDelgate alloc]init];
    scanning();
    bSetUUID = true;
    
}

void ofxBLE::scanning(){
    
    [bleModule scan];
}

void ofxBLE::update(){
    
}

void ofxBLE::connect(){
    
    connectedBLE = [bleModule connect];
    return;
    
}

void ofxBLE::disconnect(){
    
    connectedBLE = [bleModule disconnect];
    return;
}

void ofxBLE::connectAction(){
    
    if (bSetUUID) {
        if (!connectedBLE) { connect(); }
        else{ disconnect(); }
    }else{ ofLogError("You didn't setup UUID!!!\n"); }
    
}

void ofxBLE::setConnect(bool status){
    
    connectedBLE = status;
}

bool ofxBLE::isConnected() const{ return connectedBLE; }