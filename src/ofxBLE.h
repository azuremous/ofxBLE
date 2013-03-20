//
//  ofxBLE.h
//  ofxBLE
//
//  Created by kim jung un a.k.a azuremous on 8/15/12.
//  Copyright (c) 2012 azuremous.net All rights reserved.
//

#pragma once

#import <UIKit/UIKit.h>
#import "BLeDiscovery.h"
#import "ofMain.h"

@interface ofxBLEDelgate : UIViewController <BLeDiscoveryDelegate>
{
    
    BLeDiscovery * BLE;
    NSInteger currentValue;
    
}

-(id)init;
-(void)scan;
-(BOOL)connect;
-(BOOL)disconnect;
-(BOOL)IsBLEConnected;
@end

class ofxBLE {
    
private:
    
    ofxBLEDelgate * bleModule;
    bool connectedBLE;
    
protected:
    
    bool bSetUUID;
    
public:
    ofxBLE();
    ~ofxBLE();
    void setup();
    void scanning();
    void update();
    void connect();
    void disconnect();
    void connectAction();
    void setConnect(bool status);
    bool isConnected() const;
};

