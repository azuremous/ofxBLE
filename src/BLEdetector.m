//
//  BLEdetector.m
//
//  Created by kim jung un on 5/16/13.
//  Copyright (c) 2013 azuremous.net All rights reserved.
//


#import "BLEdetector.h"

@implementation BLEdetector
@synthesize discoveryDelegate;                  //alarmBLEdelegate
@synthesize discoveredPeripherals = peripherals;//NSMutableArray
@synthesize BLEUUID;        //CBUUID
@synthesize getUUID;
@synthesize BLEUUUIDstring; //NSString
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
    
    [super dealloc];
}

-(void)initData{
    
    discoveredUUID = false;
    beConnected = false;
}

-(void)initCM{
    
    CBmanager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (BOOL) isBLECapableHardware
{
    NSString * state = nil;
    
    switch ([CBmanager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            BLE_LOG(@"Central manager state: %@", state);
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            BLE_LOG(@"Central manager state: %@", state);
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            BLE_LOG(@"Central manager state: %@", state);
            break;
        case CBCentralManagerStatePoweredOn:
            //[self loadSavedDevices];
            BLE_LOG(@"CBCentralManagerStatePoweredOn");
			[CBmanager retrieveConnectedPeripherals];
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
    }
    
    return FALSE;
}


-(BOOL)startScan{
    
    BLE_LOG(@"scan with :%@",BLEUUUIDstring);
    [self disconnect];
    [self initData];
    if (CBmanager.state != CBCentralManagerStatePoweredOn) {
        BLE_LOG(@"Corebluetooth not correctly initialized!");
        return false;
    }
    [discoveryDelegate alarmFind];
    NSArray	*uuidArray	= [NSArray arrayWithObjects:BLEUUID, nil];
    [CBmanager scanForPeripheralsWithServices:uuidArray options:nil];
    return true;    
}

-(void)stopScan{
    
    [CBmanager stopScan];
}

-(BOOL)connect:(CBPeripheral*)peripheral{
    
    if (![peripheral isConnected]) {
        BLE_LOG(@"connectAction!!!");
        [CBmanager connectPeripheral:peripheral options:nil];
        return true;
    }
    BLE_LOG(@"fail connectAction!!!");
    return false;
}

-(BOOL)disconnect{
    if (activePeripheral && activePeripheral.isConnected) {
        [self stopScan];
        [CBmanager cancelPeripheralConnection:activePeripheral];
        return true;
    }else{ return false; }
}

-(void)sendData:(NSString *)_UUIDstring with:(NSData *)_data{
    if (activePeripheral && activePeripheral.isConnected) {
        [self writeValue:activePeripheral sUUID:BLEUUUIDstring cUUID:_UUIDstring data:_data];
    }
    
    
}

-(void)readData:(NSString *)_UUIDstring{
    if (activePeripheral && activePeripheral.isConnected) {
     [self readValue:activePeripheral sUUID:BLEUUUIDstring cUUID:_UUIDstring];
    }
    //return @"readDataNon";
}

-(void)setNotification:(NSString *)_UUIDstring status:(BOOL)notice{
    if (activePeripheral && activePeripheral.isConnected) {
        [self notificationValue:activePeripheral sUUID:BLEUUUIDstring cUUID:_UUIDstring enable:notice];
    }
}

#pragma mark - BLE connect method

- (void) connectPeripheral:(CBPeripheral*)peripheral
{
    
    BLE_LOG(@"connectPeripheral Peripheral");
    [CBmanager connectPeripheral:peripheral options:nil];
    
}

- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)_peripherals
{
	BLE_LOG(@"didRetrieveConnectedPeripherals");
    CBPeripheral	*peripheral;
	for (peripheral in _peripherals) {
		[central connectPeripheral:peripheral options:nil]; //Add to list.
	}
}

#pragma mark - BLE CM methods

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    BLE_LOG(@"start");
    [self isBLECapableHardware];
    //[self startScan];
}

//when BLE is powerd on this fuction work on!
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BLE_LOG(@"Discover Peripheral action -");
    
    for (int i = 0; i < peripherals.count; i++) {
        CBPeripheral *p = [peripherals objectAtIndex:i];
        if ([self UUIDareEqual:p.UUID with:peripheral.UUID]) {
            [peripherals removeObject:peripheral];
            BLE_LOG(@"remove UUID: %@", peripheral.name);
        }
    }
     
    discoveredUUID = true;
    [peripherals addObject:peripheral];
    BLE_LOG(@"New UUID: %@", peripheral.name);//nsstring
    BLE_LOG(@"Peripherals count: %d", [peripherals count]);
    [discoveryDelegate alarmDiscoverBLE:[peripherals count] name:peripheral.name];
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    BLE_LOG(@"did Retrieve Peripherals");
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    BLE_LOG(@"fail connect action");
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
    BLE_LOG(@"peripheral did update Characteristics For Service");
    if ([[characteristic UUID] isEqual:getUUID]) {
        NSData * _data = [characteristic value];
        NSString *dataDescription = [_data description];
        BLE_LOG(@"get data from:%@",characteristic.UUID);
        [discoveryDelegate alarmChangeValue:dataDescription];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    BLE_LOG(@"peripheral did Write Value For Characteristic");
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    BLE_LOG(@"peripheral did update notificatiom state for characteristic");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    BLE_LOG(@"peripheral discriptoon");
}

#pragma mark - value method

-(void) writeValue:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data
{
    for ( CBService *service in peripheral.services ) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    /* EVERYTHING IS FOUND, WRITE characteristic ! */
                    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    
                }
            }
        }
    }
}

-(void) readValue:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID
{
    for ( CBService *service in peripheral.services ) {
        if([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    /* Everything is found, read characteristic ! */
                    getUUID = characteristic.UUID;
                    [peripheral readValueForCharacteristic:characteristic];
                    BLE_LOG(@"read data from:%@",getUUID);
                }
            }
        }
    }
}

-(void)notificationValue:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID enable:(BOOL)enable {
    for (CBService *service in peripheral.services ) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]])
                {
                    BLE_LOG(@"set notification:%d",enable);
                    [peripheral setNotifyValue:enable forCharacteristic:characteristic];
                }
            }
        }
    }
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

@end
