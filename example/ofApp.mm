#include "ofApp.h"
bool isFirstTime = true;
string my_id = "";
//--------------------------------------------------------------
void ofApp::setup(){	

    ble.setup("BLE UUID");
    
}

//--------------------------------------------------------------
void ofApp::update(){
    
}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){
    if (ble.checkStatus(msg)) {
        cout<<msg.message<<endl;
    }
    
    switch (ble.getStatus()) {
        case BLE_DISCONNECT:
            ble.disconnected();
            break;
            
        case BLE_FIND:
            
            break;
            
        case BLE_DISCOVER:
            if (isFirstTime) { ble.connectAction(); }
            break;
            
        case BLE_TRY_CONNECT:
            
            break;
            
        case BLE_CONNECT:
            if (isFirstTime) { my_id = ble.getID(); }
            break;
            
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){

    ble.scan();
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}
