//
//  BLEdetector.m
//  ofxBLE
//
//  Created by kim jung un on 5/16/13.
//  Copyright (c) 2013 azuremous.net All rights reserved.
//

#import "BLEdetector.h"

@implementation BLEdetector
@synthesize discoveryDelegate;                  //alarmBLEdelegate
@synthesize discoveredPeripherals = peripherals;//NSMutableArray
@synthesize BLEUUID;        //CBUUID
@synthesize RXUUID;         //CBUUID
@synthesize TXEUUID;        //CBUUID
@synthesize RX_data;        //NSInteger
@synthesize TX_data;        //NSInteger
@synthesize discoveredUUID; //bool
@synthesize beConnected;    //bool


-(id)init{
    
    [self initCM];
    [self initData];
    peripherals = [[NSMutableArray alloc] init];
    return self;
}

-(void)dealloc{
    
    [self stopScan];
    
    [peripherals release];
    peripherals = nil;
    
    [CBmanager release];
    CBmanager = nil;
    
    [activePeripheral release];
    activePeripheral = nil;
    
    [BLEUUID release];
    [RXUUID release];
    [TXEUUID release];
    
    [super dealloc];
}

-(void)initData{
    
    RX_data = 0;
    TX_data = 0;
    discoveredUUID = false;
    beConnected = false;
}

-(void)initCM{
    
    CBmanager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

-(BOOL)startScan{
    BLE_LOG(@"start scan!");
    [self disconnect];
    
    if (CBmanager.state != CBCentralManagerStatePoweredOn) {
        BLE_LOG(@"Corebluetooth not correctly initialized!");
        return false;
    }
    
    NSArray	*uuidArray	= [NSArray arrayWithObjects:BLEUUID, nil];
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [CBmanager scanForPeripheralsWithServices:uuidArray options:options];

    return true;    
}

-(void)stopScan{
    
    [CBmanager stopScan];
}

-(BOOL)connect:(CBPeripheral*)peripheral{
    
    if (![peripheral isConnected]) {
        [CBmanager connectPeripheral:peripheral options:nil];
        return true;
    }
    return false;
}

-(BOOL)disconnect{
    if (activePeripheral && activePeripheral.isConnected) {
        [self stopScan];
        [CBmanager cancelPeripheralConnection:activePeripheral];
        return true;
    }else{ return false; }
}

-(void)writeTX:(unsigned char)data{
    if (activePeripheral && activePeripheral.isConnected) {
        //uartSetting = uart_enable
        NSData *_data = [[NSData alloc] initWithBytes:&data length:1];
        //[self writeValue:<#(int)#> characteristicUUID:<#(int)#> peripheral:<#(CBPeripheral *)#> data:data];
    }
}

#pragma mark - BLE connect method

- (void) connectPeripheral:(CBPeripheral*)peripheral
{
    
    [CBmanager connectPeripheral:peripheral options:nil];
    
}

#pragma mark - BLE CM methods

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}

//when BLE is powerd on this fuction work on!
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BLE_LOG(@"Discover Peripheral action -");
    
    for (int i = 0; i < peripherals.count; i++) {
        CBPeripheral *p = [peripherals objectAtIndex:i];
        if ([self UUIDareEqual:p.UUID with:peripheral.UUID]) {
            [peripherals replaceObjectAtIndex:i withObject:peripheral];
            BLE_LOG(@"Duplicate UUID: %@", peripheral.name);
        }
    }
    discoveredUUID = true;
    [peripherals addObject:peripheral];
    [discoveryDelegate alarmDiscoverBLE];
    BLE_LOG(@"New UUID, adding: %@", peripheral.name);
    BLE_LOG(@"Peripherals: %d", [peripherals count]);
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    BLE_LOG(@"Connect Peripheral action -");
    activePeripheral = [peripheral retain];
    [activePeripheral setDelegate:self];
    NSArray	*serviceArray	= [NSArray arrayWithObjects:BLEUUID, nil];
    [activePeripheral discoverServices:serviceArray];
    [peripherals addObject:peripheral];
    beConnected = true;
    [discoveryDelegate alarmConnectBLE];
    BLE_LOG(@"connected with:%@",[activePeripheral description]);
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self initData];
    [discoveryDelegate alarmDisconnectBLE];
    BLE_LOG(@"Disconnect from the peripheral: %@", [peripheral name]);
}

#pragma mark - peripheral method

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    NSArray		*services	= nil;
    
    if (peripheral != activePeripheral) {
		BLE_LOG(@"Wrong Peripheral.\n");
		return ;
	}
    
    if (error != nil) {
        BLE_LOG(@"Error %@\n", error);
		return ;
	}
    
	services = [peripheral services];
	if (!services || ![services count]) {
		return ;
	}
    
    for (int i=0; i < services.count; i++) {
        CBService *s = [services objectAtIndex:i];
        BLE_LOG(@"Fetching characteristics for service with UUID : %@", [s.UUID.data description]);
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    BLE_LOG(@"peripheral did Discover Characteristics For Service");
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    BLE_LOG(@"peripheral did Update Value For Characteristic");
    
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    BLE_LOG(@"peripheral did Write Value For Characteristic");
}

#pragma mark - value method

-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID peripheral:(CBPeripheral *)peripheral data:(NSData *)data
{
    UInt16 _service = [self swap:serviceUUID];
    UInt16 _characteristic = [self swap:characteristicUUID];
    NSData *_serviceData = [[NSData alloc] initWithBytes:(char *)&_service length:2];
    NSData *_characteristicData = [[NSData alloc] initWithBytes:(char *)&_characteristic length:2];
    CBUUID *_serviceUUID = [CBUUID UUIDWithData:_serviceData];
    CBUUID *_characteristicUUID = [CBUUID UUIDWithData:_characteristicData];
    CBService *service = [self findServiceFromUUID:_serviceUUID with:peripheral];
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:_characteristicUUID service:service];
    if (!service) { BLE_LOG(@"Could not find service with UUID"); return; }
    if (!characteristic) { BLE_LOG(@"Could not find service with UUID"); return; }
    
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    
    [NSThread sleepForTimeInterval:0.03];//timer
}

-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID peripheral:(CBPeripheral *)peripheral
{
    UInt16 _service = [self swap:serviceUUID];
    UInt16 _characteristic = [self swap:characteristicUUID];
    NSData *_serviceData = [[NSData alloc] initWithBytes:(char *)&_service length:2];
    NSData *_characteristicData = [[NSData alloc] initWithBytes:(char *)&_characteristic length:2];
    CBUUID *_serviceUUID = [CBUUID UUIDWithData:_serviceData];
    CBUUID *_characteristicUUID = [CBUUID UUIDWithData:_characteristicData];
    CBService *service = [self findServiceFromUUID:_serviceUUID with:peripheral];
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:_characteristicUUID service:service];
    if (!service) { BLE_LOG(@"Could not find service with UUID"); return; }
    if (!characteristic) { BLE_LOG(@"Could not find service with UUID"); return; }
    
    [peripheral readValueForCharacteristic:characteristic];
}

#pragma mark - calculation method

-(BOOL)UUIDareEqual:(CFUUIDRef)u1 with:(CFUUIDRef)u2{
    
    CFUUIDBytes b1 = CFUUIDGetUUIDBytes(u1);
    CFUUIDBytes b2 = CFUUIDGetUUIDBytes(u2);
    if (memcmp(&b1, &b2, 16) == 0) return true;
    else return false;
}

-(BOOL) compareCBUUID:(CBUUID *)u1 with:(CBUUID *)u2
{
    char b1[16];
    char b2[16];
    [u1.data getBytes:b1];
    [u2.data getBytes:b2];
    if (memcmp(b1, b2, u1.data.length) == 0) return true;
    else return false;
}

- (UInt16) swap:(UInt16)s
{
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

- (CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service
{
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *_characteristics = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:_characteristics.UUID with:UUID]) return _characteristics;
    }
    return nil;
}

- (CBService*) findServiceFromUUID:(CBUUID *)UUID with:(CBPeripheral *)peripheral
{
    for(int i = 0; i < peripheral.services.count; i++) {
        CBService *_service = [peripheral.services objectAtIndex:i];
        if ([self compareCBUUID:_service.UUID with:UUID]) return _service;
    }
    return nil;
}

@end
