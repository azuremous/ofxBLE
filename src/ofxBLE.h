//
//  ofxBLE.h
//  ofxBLE
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
-(void)setRX:(NSString *)_RXUUIDstring;
-(void)setTX:(NSString *)_TXUUIDstring;
-(BOOL)connect:(NSInteger)num;
-(BOOL)disconnect;
-(BOOL)beConnected;

@end


class ofxBLE {
    
private:
    ofxBLEdelegate * BLEmodule;
    bool bConnectedBLE;
    
public:
    ofxBLE();
    virtual~ofxBLE();
    bool setup();
    bool setup(string _BLEUUID, string _RXUUID, string _TXUUID);
    void setBLE(string _uuid);
    void setRX(string _uuid);
    void setTX(string _uuid);
    void scan();
    void stopScan();
    void connectAction(int num = 0);
    void connect(int num = 0);
    void disconnect();
    
    
};
