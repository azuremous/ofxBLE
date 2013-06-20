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


class ofxBLE {
    
private:
    ofxBLEdelegate * BLEmodule;
    bool bConnectedBLE;
    
protected:
    NSString * sToNS(string _s);
    void connect(int num = 0);
    void disconnect();
    
public:
    explicit ofxBLE();
    virtual~ofxBLE();
    bool setup();
    bool setup(string _BLEUUID);
    void setBLE(string _uuid) { [BLEmodule setBLE:sToNS(_uuid)]; }
    void getData(string _uuid) { [BLEmodule getData:sToNS(_uuid)]; }
    void setNotification(string _uuid, bool _switch);
    void scan() { [BLEmodule scan]; }
    void stopScan() { [BLEmodule stopScan]; }
    void connectAction(int num = 0);
    void disconnected() { bConnectedBLE = false; }
    bool isConnected() const { return bConnectedBLE; }
};
