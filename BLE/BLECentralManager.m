//
//  BLEPeripheral.m
//  BLE
//
//  Created by Dan Kalinin on 5/25/18.
//

#import "BLECentralManager.h"










@interface BLEPeripheralConnection ()

@property CBPeripheral *peripheral;
@property NSDictionary<NSString *, id> *options;
@property NSTimeInterval timeout;

@end



@implementation BLEPeripheralConnection

@dynamic parent;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
        self.options = options;
        self.timeout = timeout;
        
        peripheral.connection = self;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    dispatch_group_enter(self.group);
    [self.parent.manager connectPeripheral:self.peripheral options:self.options];
    dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER); // TODO: timeout
    
    [self updateState:HLPOperationStateDidEnd];
}

- (void)cancel {
    [super cancel];
    
    [self.parent.manager cancelPeripheralConnection:self.peripheral];
}

#pragma mark - Helpers

- (void)endWithError:(NSError *)error {
    dispatch_group_leave(self.group);
    
    if (error) {
        [self.errors addObject:error];
    }
}

@end










@interface BLEPeripheralDisconnection ()

@property CBPeripheral *peripheral;

@end



@implementation BLEPeripheralDisconnection

@dynamic parent;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
    }
    return self;
}

- (void)main {
    [self.parent.manager cancelPeripheralConnection:self.peripheral];
}

@end










@interface BLEServicesDiscovery ()

@property CBPeripheral *peripheral;
@property NSArray<CBUUID *> *services;

@end



@implementation BLEServicesDiscovery

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral services:(NSArray<CBUUID *> *)services {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
        self.services = services;
    }
    return self;
}

- (void)main {
    [self.peripheral discoverServices:self.services];
}

#pragma mark - Peripheral

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    dispatch_group_leave(self.group);
    
    if (error) {
        [self.errors addObject:error];
    }
}

@end










@interface BLECharacteristicsDiscovery ()

@property CBService *service;
@property NSArray<CBUUID *> *characteristics;

@end



@implementation BLECharacteristicsDiscovery

- (instancetype)initWithService:(CBService *)service characteristics:(NSArray<CBUUID *> *)characteristics {
    self = super.init;
    if (self) {
        self.service = service;
        self.characteristics = characteristics;
    }
    return self;
}

- (void)main {
    [self.service.peripheral discoverCharacteristics:self.characteristics forService:self.service];
}

@end










@interface BLECharacteristicReading ()

@property CBCharacteristic *characteristic;

@end



@implementation BLECharacteristicReading

- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic {
    self = super.init;
    if (self) {
        self.characteristic = characteristic;
    }
    return self;
}

- (void)main {
    [self.characteristic.service.peripheral readValueForCharacteristic:self.characteristic];
}

@end










@interface BLEL2CAPChannelOpening ()

@property CBPeripheral *peripheral;
@property CBL2CAPPSM psm;

@end



@implementation BLEL2CAPChannelOpening

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral psm:(CBL2CAPPSM)psm {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
        self.psm = psm;
    }
    return self;
}

- (void)main {
    [self.peripheral openL2CAPChannel:self.psm];
}

@end










@interface BLECentralManager ()

@property NSDictionary<NSString *, id> *options;
@property CBCentralManager *manager;
@property NSMutableDictionary<NSUUID *, CBPeripheral *> *peripheralsByIdentifier;
@property NSMutableDictionary<NSString *, CBPeripheral *> *peripheralsByName;

@end



@implementation BLECentralManager

@dynamic delegates;

- (instancetype)initWithOptions:(NSDictionary<NSString *,id> *)options {
    self = super.init;
    if (self) {
        self.options = options;
        
        self.manager = [CBCentralManager.alloc initWithDelegate:self.delegates queue:nil options:options];
        
        self.peripheralsByIdentifier = NSMutableDictionary.dictionary;
        self.peripheralsByName = NSMutableDictionary.dictionary;
    }
    return self;
}

- (void)start {
    [self.states removeAllObjects];
    [self.errors removeAllObjects];
    
    [self.peripheralsByIdentifier removeAllObjects];
    [self.peripheralsByName removeAllObjects];
    
    [self updateState:HLPOperationStateDidBegin];
}

- (void)cancel {
    [self.manager stopScan];
    
    [self updateState:HLPOperationStateDidEnd];
}

- (BLEPeripheralConnection *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *,id> *)options timeout:(NSTimeInterval)timeout {
    BLEPeripheralConnection *connection = [BLEPeripheralConnection.alloc initWithPeripheral:peripheral options:options timeout:timeout];
    [self addOperation:connection];
    return connection;
}

- (BLEPeripheralConnection *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *,id> *)options timeout:(NSTimeInterval)timeout completion:(VoidBlock)completion {
    BLEPeripheralConnection *connection = [self connectPeripheral:peripheral options:options timeout:timeout];
    connection.completionBlock = completion;
    return connection;
}

- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral {
    BLEPeripheralDisconnection *disconnection = [BLEPeripheralDisconnection.alloc initWithPeripheral:peripheral];
    [self addOperation:disconnection];
    return disconnection;
}

- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral completion:(VoidBlock)completion {
    BLEPeripheralDisconnection *disconnection = [self disconnectPeripheral:peripheral];
    disconnection.completionBlock = completion;
    return disconnection;
}

- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services {
    BLEServicesDiscovery *discovery = [BLEServicesDiscovery.alloc initWithPeripheral:peripheral services:services];
    [self addOperation:discovery];
    return discovery;
}

- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services completion:(VoidBlock)completion {
    BLEServicesDiscovery *discovery = [self peripheral:peripheral discoverServices:services];
    discovery.completionBlock = completion;
    return discovery;
}

- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics {
    BLECharacteristicsDiscovery *discovery = [BLECharacteristicsDiscovery.alloc initWithService:service characteristics:characteristics];
    [self addOperation:discovery];
    return discovery;
}

- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics completion:(VoidBlock)completion {
    BLECharacteristicsDiscovery *discovery = [self service:service discoverCharacteristics:characteristics];
    discovery.completionBlock = completion;
    return discovery;
}

- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic {
    BLECharacteristicReading *reading = [BLECharacteristicReading.alloc initWithCharacteristic:characteristic];
    [self addOperation:reading];
    return reading;
}

- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic completion:(VoidBlock)completion {
    BLECharacteristicReading *reading = [self readCharacteristic:characteristic];
    reading.completionBlock = completion;
    return reading;
}

- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm {
    BLEL2CAPChannelOpening *opening = [BLEL2CAPChannelOpening.alloc initWithPeripheral:peripheral psm:psm];
    [self addOperation:opening];
    return opening;
}

- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm completion:(VoidBlock)completion {
    BLEL2CAPChannelOpening *opening = [self peripheral:peripheral openL2CAPChannel:psm];
    opening.completionBlock = completion;
    return opening;
}

#pragma mark - Central manager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    self.peripheralsByIdentifier[peripheral.identifier] = peripheral;
    self.peripheralsByName[peripheral.name] = peripheral;
    
    peripheral.advertisement = advertisementData;
    peripheral.rssi = RSSI;
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral.connection endWithError:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [peripheral.connection endWithError:error];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [peripheral.connection endWithError:error];
}

@end










@implementation CBPeripheral (BLE)

- (NSDictionary<NSString *, id> *)advertisement {
    return self.strongDictionary[NSStringFromSelector(@selector(advertisement))];
}

- (void)setAdvertisement:(NSDictionary<NSString *, id> *)advertisement {
    self.strongDictionary[NSStringFromSelector(@selector(advertisement))] = advertisement;
}

- (NSNumber *)rssi {
    return self.strongDictionary[NSStringFromSelector(@selector(rssi))];
}

- (void)setRssi:(NSNumber *)rssi {
    self.strongDictionary[NSStringFromSelector(@selector(rssi))] = rssi;
}

- (BLEPeripheralConnection *)connection {
    return self.weakDictionary[NSStringFromSelector(@selector(connection))];
}

- (void)setConnection:(BLEPeripheralConnection *)connection {
    self.weakDictionary[NSStringFromSelector(@selector(connection))] = connection;
}

@end
