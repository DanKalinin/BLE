//
//  BLEPeripheral.m
//  BLE
//
//  Created by Dan Kalinin on 5/25/18.
//

#import "BLECentralManager.h"










@interface BLEPeripheralOperation ()

@property CBPeripheral *peripheral;

@end



@implementation BLEPeripheralOperation

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
        
        peripheral.delegate = self.delegates;
    }
    return self;
}

@end










@interface BLEServiceOperation ()

@property CBService *service;

@end



@implementation BLEServiceOperation

- (instancetype)initWithService:(CBService *)service {
    self = [super initWithPeripheral:service.peripheral];
    if (self) {
        self.service = service;
    }
    return self;
}

@end










@interface BLECharacteristicOperation ()

@property CBCharacteristic *characteristic;

@end



@implementation BLECharacteristicOperation

- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic {
    self = [super initWithService:characteristic.service];
    if (self) {
        self.characteristic = characteristic;
    }
    return self;
}

@end










@interface BLEPeripheralConnection ()

@property NSDictionary<NSString *, id> *options;
@property NSTimeInterval timeout;

@end



@implementation BLEPeripheralConnection

@dynamic delegates;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout {
    self = [super initWithPeripheral:peripheral];
    if (self) {
        self.options = options;
        self.timeout = timeout;
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

#pragma mark - Central manager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

#pragma mark - Helpers

- (void)updateState:(HLPOperationState)state {
    [super updateState:state];
    
    [self.delegates BLEPeripheralConnectionDidUpdateState:self];
    if (state == HLPOperationStateDidBegin) {
        [self.delegates BLEPeripheralConnectionDidBegin:self];
    } else if (state == HLPOperationStateDidEnd) {
        [self.delegates BLEPeripheralConnectionDidEnd:self];
    }
}

- (void)updateProgress:(uint64_t)completedUnitCount {
    [super updateProgress:completedUnitCount];
    
    [self.delegates BLEPeripheralConnectionDidUpdateProgress:self];
}

@end










@interface BLEServicesDiscovery ()

@property NSArray<CBUUID *> *services;

@end



@implementation BLEServicesDiscovery

@dynamic delegates;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral services:(NSArray<CBUUID *> *)services {
    self = [super initWithPeripheral:peripheral];
    if (self) {
        self.services = services;
        
        self.progress.totalUnitCount = services.count;
    }
    return self;
}

- (void)main {
    [self.peripheral discoverServices:self.services];
}

#pragma mark - Peripheral

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        [self.errors addObject:error];
    }
    
    dispatch_group_leave(self.group);
}

#pragma mark - Helpers

- (void)updateState:(HLPOperationState)state {
    [super updateState:state];
    
    [self.delegates BLEServicesDiscoveryDidUpdateState:self];
    if (state == HLPOperationStateDidBegin) {
        [self.delegates BLEServicesDiscoveryDidBegin:self];
    } else if (state == HLPOperationStateDidEnd) {
        [self.delegates BLEServicesDiscoveryDidEnd:self];
    }
}

- (void)updateProgress:(uint64_t)completedUnitCount {
    [super updateProgress:completedUnitCount];
    
    [self.delegates BLEServicesDiscoveryDidUpdateProgress:self];
}

@end










@interface BLECharacteristicsDiscovery ()

@property NSArray<CBUUID *> *characteristics;

@end



@implementation BLECharacteristicsDiscovery

@dynamic delegates;

- (instancetype)initWithService:(CBService *)service characteristics:(NSArray<CBUUID *> *)characteristics {
    self = [super initWithService:service];
    if (self) {
        self.characteristics = characteristics;
        
        self.progress.totalUnitCount = characteristics.count;
    }
    return self;
}

- (void)main {
    [self.peripheral discoverCharacteristics:self.characteristics forService:self.service];
}

#pragma mark - Helpers

- (void)updateState:(HLPOperationState)state {
    [super updateState:state];
    
    [self.delegates BLECharacteristicsDiscoveryDidUpdateState:self];
    if (state == HLPOperationStateDidBegin) {
        [self.delegates BLECharacteristicsDiscoveryDidBegin:self];
    } else if (state == HLPOperationStateDidEnd) {
        [self.delegates BLECharacteristicsDiscoveryDidEnd:self];
    }
}

- (void)updateProgress:(uint64_t)completedUnitCount {
    [super updateProgress:completedUnitCount];
    
    [self.delegates BLECharacteristicsDiscoveryDidUpdateProgress:self];
}

@end










@interface BLECharacteristicReading ()

@end



@implementation BLECharacteristicReading

@dynamic delegates;

- (void)main {
    [self.peripheral readValueForCharacteristic:self.characteristic];
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

#pragma mark - Central manager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    self.peripheralsByIdentifier[peripheral.identifier] = peripheral;
    self.peripheralsByName[peripheral.name] = peripheral;
}

@end
