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

@property (weak) HLPTimer *timer;
@property (weak) BLEPeripheralDisconnection *disconnection;

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
    [self.parent.central connectPeripheral:self.peripheral options:self.options];
    self.timer = [HLPClock.shared timerWithInterval:self.timeout repeats:1 completion:^{
        dispatch_group_leave(self.group);
    }];
    dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
    
    if (self.timer.cancelled) {
    } else {
        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
        [self.errors addObject:error];
    }
    
    if (self.cancelled || (self.errors.count > 0)) {
        self.disconnection = [self.parent disconnectPeripheral:self.peripheral];
        [self.disconnection waitUntilFinished];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

- (void)cancel {
    [super cancel];
    
    [self.timer cancel];
}

#pragma mark - Helpers

- (void)endWithError:(NSError *)error {
    [self.timer cancel];
    
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
        
        peripheral.disconnection = self;
        
        dispatch_group_enter(self.group);
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    [self.parent.central cancelPeripheralConnection:self.peripheral];
    dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
    
    [self updateState:HLPOperationStateDidEnd];
}

- (void)cancel {
    [super cancel];
    
    dispatch_group_leave(self.group);
}

#pragma mark - Helpers

- (void)end {
    dispatch_group_leave(self.group);
}

@end










@interface BLEServicesDiscovery ()

@property CBPeripheral *peripheral;
@property NSArray<CBUUID *> *services;
@property NSTimeInterval timeout;

@property (weak) HLPTimer *timer;
@property (weak) BLEPeripheralDisconnection *disconnection;

@end



@implementation BLEServicesDiscovery

@dynamic delegates;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral services:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
        self.services = services;
        self.timeout = timeout;
        
        peripheral.delegate = self.delegates;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    dispatch_group_enter(self.group);
    [self.peripheral discoverServices:self.services];
    self.timer = [HLPClock.shared timerWithInterval:self.timeout repeats:1 completion:^{
        dispatch_group_leave(self.group);
    }];
    dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
    
    if (self.timer.cancelled) {
        if (self.peripheral.services.count < self.services.count) {
            NSError *error = [NSError errorWithDomain:BLEErrorDomain code:BLEErrorLessServicesDiscovered userInfo:nil];
            [self.errors addObject:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
        [self.errors addObject:error];
    }
    
    if (self.cancelled || (self.errors.count > 0)) {
        self.disconnection = [self.parent disconnectPeripheral:self.peripheral];
        [self.disconnection waitUntilFinished];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

- (void)cancel {
    [super cancel];
    
    [self.timer cancel];
}

#pragma mark - Peripheral

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    [self.timer cancel];
    
    if (error) {
        [self.errors addObject:error];
    }
}

@end










@interface BLECharacteristicsDiscovery ()

@property CBService *service;
@property NSArray<CBUUID *> *characteristics;
@property NSTimeInterval timeout;

@property (weak) HLPTimer *timer;
@property (weak) BLEPeripheralDisconnection *disconnection;

@end



@implementation BLECharacteristicsDiscovery

@dynamic delegates;

- (instancetype)initWithService:(CBService *)service characteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.service = service;
        self.characteristics = characteristics;
        self.timeout = timeout;
        
        service.peripheral.delegate = self.delegates;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    dispatch_group_enter(self.group);
    [self.service.peripheral discoverCharacteristics:self.characteristics forService:self.service];
    self.timer = [HLPClock.shared timerWithInterval:self.timeout repeats:1 completion:^{
        dispatch_group_leave(self.group);
    }];
    dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
    
    if (self.timer.cancelled) {
        if (self.service.characteristics.count < self.characteristics.count) {
            NSError *error = [NSError errorWithDomain:BLEErrorDomain code:BLEErrorLessCharacteristicsDiscovered userInfo:nil];
            [self.errors addObject:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
        [self.errors addObject:error];
    }
    
    if (self.cancelled || (self.errors.count > 0)) {
        self.disconnection = [self.parent disconnectPeripheral:self.service.peripheral];
        [self.disconnection waitUntilFinished];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

#pragma mark - Peripheral

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [self.timer cancel];
    
    if (error) {
        [self.errors addObject:error];
    }
}

@end










@interface BLECharacteristicReading ()

@property CBCharacteristic *characteristic;

@end



@implementation BLECharacteristicReading

@dynamic delegates;

- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic {
    self = super.init;
    if (self) {
        self.characteristic = characteristic;
        
        characteristic.service.peripheral.delegate = self.delegates;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    dispatch_group_enter(self.group);
    [self.characteristic.service.peripheral readValueForCharacteristic:self.characteristic];
    dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
    
    [self updateState:HLPOperationStateDidEnd];
}

#pragma mark - Peripheral

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    dispatch_group_leave(self.group);
    
    if (error) {
        [self.errors addObject:error];
    }
}

@end










@interface BLEL2CAPChannelOpening ()

@property CBPeripheral *peripheral;
@property CBL2CAPPSM psm;
@property NSTimeInterval timeout;

@property (weak) HLPTimer *timer;
@property (weak) BLEPeripheralDisconnection *disconnection;

@end



@implementation BLEL2CAPChannelOpening

@dynamic delegates;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral psm:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
        self.psm = psm;
        self.timeout = timeout;
        
        peripheral.delegate = self.delegates;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    dispatch_group_enter(self.group);
    [self.peripheral openL2CAPChannel:self.psm];
    self.timer = [HLPClock.shared timerWithInterval:self.timeout repeats:1 completion:^{
        dispatch_group_leave(self.group);
    }];
    dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
    
    if (self.timer.cancelled) {
    } else {
        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
        [self.errors addObject:error];
    }
    
    if (self.cancelled || (self.errors.count > 0)) {
        self.disconnection = [self.parent disconnectPeripheral:self.peripheral];
        [self.disconnection waitUntilFinished];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

- (void)cancel {
    [super cancel];
    
    [self.timer cancel];
}

#pragma mark - Peripheral

- (void)peripheral:(CBPeripheral *)peripheral didOpenL2CAPChannel:(CBL2CAPChannel *)channel error:(NSError *)error {
    [self.timer cancel];
    
    if (error) {
        [self.errors addObject:error];
    }
}

@end










@interface BLECentralManager ()

@property NSDictionary<NSString *, id> *options;
@property CBCentralManager *central;
@property NSMutableDictionary<NSUUID *, CBPeripheral *> *peripheralsByIdentifier;
@property NSMutableDictionary<NSString *, CBPeripheral *> *peripheralsByName;

@end



@implementation BLECentralManager

@dynamic delegates;

- (instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options {
    self = super.init;
    if (self) {
        self.options = options;
        
        self.central = [CBCentralManager.alloc initWithDelegate:self.delegates queue:nil options:options];
        
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
    [self.central stopScan];
    
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

- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout {
    BLEServicesDiscovery *discovery = [BLEServicesDiscovery.alloc initWithPeripheral:peripheral services:services timeout:timeout];
    [self addOperation:discovery];
    return discovery;
}

- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout completion:(VoidBlock)completion {
    BLEServicesDiscovery *discovery = [self peripheral:peripheral discoverServices:services timeout:timeout];
    discovery.completionBlock = completion;
    return discovery;
}

- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout {
    BLECharacteristicsDiscovery *discovery = [BLECharacteristicsDiscovery.alloc initWithService:service characteristics:characteristics timeout:timeout];
    [self addOperation:discovery];
    return discovery;
}

- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout completion:(VoidBlock)completion {
    BLECharacteristicsDiscovery *discovery = [self service:service discoverCharacteristics:characteristics timeout:timeout];
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

- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout {
    BLEL2CAPChannelOpening *opening = [BLEL2CAPChannelOpening.alloc initWithPeripheral:peripheral psm:psm timeout:timeout];
    [self addOperation:opening];
    return opening;
}

- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout completion:(VoidBlock)completion {
    BLEL2CAPChannelOpening *opening = [self peripheral:peripheral openL2CAPChannel:psm timeout:timeout];
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
    [peripheral.disconnection end];
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

- (BLEPeripheralDisconnection *)disconnection {
    return self.weakDictionary[NSStringFromSelector(@selector(disconnection))];
}

- (void)setDisconnection:(BLEPeripheralDisconnection *)disconnection {
    self.weakDictionary[NSStringFromSelector(@selector(disconnection))] = disconnection;
}

@end
