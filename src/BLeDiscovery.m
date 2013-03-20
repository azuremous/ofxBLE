//
//  BLeDiscovery.m
//  BLeDiscovery
//
//  Created by kim jung un a.k.a azuremous on 8/14/12.
//  Copyright (c) 2012 azuremous.net All rights reserved.
//

/*
 
 http://www.mkroll.mobi/?page_id=386
 
 from Bluetooth Low Energy (BLE) Shield for Arduino
 
 Generic Access Profile (UUID 1800)
 Device Name (UUID 2A00)
 Appereance (UUID 2A01)
 Device Information (UUID 180A)
 Manufacturer Name String (UUID 2A29)
 Model Number String (UUID 2A24)
 Firmware Revision String (UUID 2A26)
 Hardware Revision String (UUID 2A27)
 BLE Shield Service (UUID F9266FD7-EF07-45D6-8EB6-BD74F13620F9)
 BD-Addr (UUID 38117F3C-28AB-4718-AB95-172B363F2AE0) “READ”, fixed size of 6 bytes
 RX (UUID 4585C102-7784-40B4-88E1-3CB5C4FD37A3) “READ/NOTIFY”, fixed size of 16 bytes
 RX Buffer Count (UUID 11846C20-6630-11E1-B86C-0800200C9A66) “READ”, fixed size of 1 byte
 RX Buffer Clear (UUID DAF75440-6EBA-11E1-B0C4-0800200C9A66) “WRITE”, fixed size of 1 byte
 TX (UUID E788D73B-E793-4D9E-A608-2F2BAFC59A00) “WRITE/READ”, variable size up to 16 bytes

 by Dr. Michael Kroll
 */

#import "BLeDiscovery.h"

NSString *BLEUUIDString = @"F9266FD7-EF07-45D6-8EB6-BD74F13620F9";//ble uuid
NSString *RXUUIDString = @"4585C102-7784-40B4-88E1-3CB5C4FD37A3";//rx uuid
NSString *TXUUIDString = @"E788D73B-E793-4D9E-A608-2F2BAFC59A00";//tx uuid

@implementation BLeDiscovery

@synthesize discoveryDelegate;
@synthesize manager;
@synthesize discoveredPeripherals;
@synthesize connectedServices;
@synthesize discoverUUID;
@synthesize peripheral = activePeripheral;

#pragma mark Init

-(id)init{
    
    discoverUUID = false;
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];//queue:dispatch_get_main_queue()
    discoveredPeripherals =[[NSMutableArray alloc] init];
    connectedServices = [[NSMutableArray alloc] init];
    return self;
}

-(void)dealloc{
    
    [self stopScan];
    
    [discoveredPeripherals release];
    [manager release];
    [activePeripheral release];
    activePeripheral = nil;
    
    [RXUUID release];
    
    [super dealloc];
}

- (void) removeSavedDevice:(CFUUIDRef) uuid
{
	NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
	NSMutableArray	*newDevices		= nil;
	CFStringRef		uuidString		= NULL;
    
	if ([storedDevices isKindOfClass:[NSArray class]]) {
		newDevices = [NSMutableArray arrayWithArray:storedDevices];
        
		uuidString = CFUUIDCreateString(NULL, uuid);
		if (uuidString) {
			[newDevices removeObject:(NSString*)uuidString];
            CFRelease(uuidString);
        }
		
		[[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

#pragma mark Discovery
/****************************************************************************/
/*								Discovery                                   */
/****************************************************************************/
- (BOOL) isBLECapableHardware
{
    NSString * state = nil;
    
    switch ([manager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            NSLog(@"Central manager state: %@", state);
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            NSLog(@"Central manager state: %@", state);
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            NSLog(@"Central manager state: %@", state);
            break;
        case CBCentralManagerStatePoweredOn:
            //[self loadSavedDevices];
            NSLog(@"CBCentralManagerStatePoweredOn");
			[manager retrieveConnectedPeripherals];
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
    }
    
    return FALSE;
}

-(void)startScan{
    
    
    NSArray	*uuidArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:BLEUUIDString], nil];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    [manager scanForPeripheralsWithServices:uuidArray options:options];
    NSLog(@"scan with :%@",BLEUUIDString);
}

- (void)stopScan
{
    [manager stopScan];
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self isBLECapableHardware];
}

- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
	CBPeripheral	*peripheral;
    
	for (peripheral in peripherals) {
		[central connectPeripheral:peripheral options:nil]; //Add to list.
	}
}

- (void) centralManager:(CBCentralManager *)central didRetrievePeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didRetrievePeripheral\n");
	[central connectPeripheral:peripheral options:nil];
}


- (void) centralManager:(CBCentralManager *)central didFailToRetrievePeripheralForUUID:(CFUUIDRef)UUID error:(NSError *)error
{
    NSLog(@"didFailToRetrievePeripheralForUUID\n");
	[self removeSavedDevice:UUID]; // Nuke from plist.
}

//when BLE is powerd on this fuction work on!
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (![self.discoveredPeripherals containsObject:peripheral]){
        [discoveredPeripherals addObject:peripheral];
        if ([peripheral name] != NULL) {
            discoverUUID = true;
            printf("%s is Discovered\r\n",[[peripheral name] cStringUsingEncoding:NSUTF8StringEncoding]);
            [discoveryDelegate alarmDiscoverBLE];
        }
    }
}

#pragma mark Connection/Disconnection
/****************************************************************************/
/*						Connection/Disconnection                            */
/****************************************************************************/
- (void) connectPeripheral:(CBPeripheral*)peripheral
{
    if (![peripheral isConnected]) {
        [manager connectPeripheral:peripheral options:nil];
    }
}

- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    [manager cancelPeripheralConnection:peripheral];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    activePeripheral = [peripheral retain];
    [activePeripheral setDelegate:self];
    RXUUID = [[CBUUID UUIDWithString:RXUUIDString] retain];
    NSArray	*serviceArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:BLEUUIDString], nil];
    
    [activePeripheral discoverServices:serviceArray];
    
	if (![connectedServices containsObject:activePeripheral])
		[connectedServices addObject:activePeripheral];
	
//    if ([discoveredPeripherals containsObject:activePeripheral]) {
//        [discoveredPeripherals removeObject:activePeripheral];
//    }
    //[discoveryDelegate alarmconnect];
    //printf("didConnectPeripheral\n");
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
}


- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    printf("didDisconnectPeripheral\n");
	for (activePeripheral in connectedServices) {
		if ([self peripheral] == peripheral) {
			[connectedServices removeObject:activePeripheral];
            printf("remove Peripheral\n");
            [discoveryDelegate alarmDisconectedBLE];
			break;
		}
	}
    
}
/****************************************************************************/
/*						discoverCharacteristics                             */
/****************************************************************************/

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    NSArray		*services	= nil;
    NSArray     *uuids = [NSArray arrayWithObject:RXUUID];
    if (peripheral != activePeripheral) {
		printf("Wrong Peripheral.\n");
		return ;
	}
    
    if (error != nil) {
        
        NSLog(@"Error %@\n", error);
		return ;
	}
    
	services = [peripheral services];
	if (!services || ![services count]) {
		return ;
	}
    
	BLECBService = nil;
    
	for (CBService *service in services) {
		if ([[service UUID] isEqual:[CBUUID UUIDWithString:BLEUUIDString]]) {
			BLECBService = service;
			break;
		}
	}
    
	if (BLECBService) [peripheral discoverCharacteristics:uuids forService:BLECBService];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
	NSArray		*characteristics	= [service characteristics];
	CBCharacteristic *characteristic;
	if (peripheral != activePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
	
	if (service != BLECBService) {
		NSLog(@"Wrong Service.\n");
		return ;
	}
    
    if (error != nil) {
		NSLog(@"Error %@\n", error);
		return ;
	}
    
	for (characteristic in characteristics) {
        NSLog(@"discovered characteristic %@", [characteristic UUID]);
        
		if ([[characteristic UUID] isEqual:RXUUID]) { // rx
			RXCharacteristic = [characteristic retain];
			[peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
		}
        
	}
    
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
	if (peripheral != activePeripheral) {
		NSLog(@"Wrong peripheral\n");
		return ;
	}
    
    if ([error code] != 0) {
		NSLog(@"Error %@\n", error);
		return ;
	}
    
    /* Alarm change */
    if ([[characteristic UUID] isEqual:RXUUID]) {
       
        //NSData * _data = [[characteristic value] subdataWithRange:NSMakeRange(0, 8)];
        NSData * _data = [characteristic value];
        NSString *dataDescription = [_data description];
        NSLog(@"get data %@", dataDescription);
        [discoveryDelegate alarmChangeValue:dataDescription];
        return;
    }
    
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
    printf("WriteValueForCharacteristic!\n");
    // [peripheral readValueForCharacteristic:characteristic];
    
    /* Upper or lower bounds changed */
    //if ([characteristic.UUID isEqual:RXUUID] || [characteristic.UUID isEqual:RXUUID]) {
        //[discoveryDelegate alarmServiceDidChangeTemperatureBounds:self];
    //}
}

@end
