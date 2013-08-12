//
//  ofxBLE.h
//
//  Created by kim jung un on 5/16/13.
//  Copyright (c) 2013 azuremous.net All rights reserved.
//

#pragma once
#import <Foundation/Foundation.h>
#import "ofMain.h"
#import "BLEdetector.h"

@interface ofxBLEdelegate : UIViewController<alarmBLEdelegate>
{
    BLEdetector * BLE;
}

-(id)init;
-(BOOL)scan;
-(void)stopScan;
-(void)setBLE:(NSString *)_BLEUUIDstring;
-(void)getData:(NSString *)_UUIDstring;
-(void)setNotification:(NSString *)_UUIDstring with:(BOOL)_switch;
-(BOOL)connect:(NSInteger)num;
-(BOOL)disconnect;
-(BOOL)beConnected;

@end

typedef enum {
    BLE_DISCONNECT,
    BLE_FIND,
    BLE_DISCOVER,
    BLE_TRY_CONNECT,
    BLE_CONNECT
}BLE_STATUS;

class ofxBLE {
    
private:
    ofxBLEdelegate * _BLEmodule;
    bool _bConnectedBLE;
    bool _bRealConnect;
    BLE_STATUS _status;
protected:
    NSString * sToNS(string _s);
    void connect(int num = 0);
    void disconnect();
    void setBLE(string _uuid) { [_BLEmodule setBLE:sToNS(_uuid)]; }
public:
    explicit ofxBLE();
    virtual~ofxBLE();
    bool setup();
    bool setup(string _BLEUUID);
    void getData(string _uuid) { [_BLEmodule getData:sToNS(_uuid)]; }
    void setNotification(string _uuid, bool _switch);
    void scan() { [_BLEmodule scan]; }
    void stopScan() { [_BLEmodule stopScan]; }
    void connectAction(int num = 0);
    void disconnected();
    void exit(){ [_BLEmodule disconnect]; }
    bool checkStatus(ofMessage _msg);
    bool isConnected() const { return _bRealConnect; }
    BLE_STATUS getStatus() const { return _status; }

};
