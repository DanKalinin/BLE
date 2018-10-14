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
@property HLPTick *tick;
@property BLEPeripheralDisconnection *disconnection;

@end



@implementation BLEPeripheralConnection

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
        self.options = options;
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    self.peripheral.connection = self;
    [self.parent.central connectPeripheral:self.peripheral options:self.options];
    
    self.operation = self.tick = [HLPClock.shared tickWithInterval:self.timeout];
    [self.tick waitUntilFinished];
    if (self.cancelled) {
    } else if (!self.tick.cancelled) {
        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
        [self.errors addObject:error];
    } else if (self.errors.count > 0) {
    } else {
        self.peripheral.servicesByUUID = HLPDictionary.strongToWeakDictionary;
        self.peripheral.channelsByPSM = NSMutableDictionary.dictionary;
    }
    
    if (self.cancelled || (self.errors.count > 0)) {
        self.disconnection = [self.parent disconnectPeripheral:self.peripheral];
        [self.disconnection waitUntilFinished];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

#pragma mark - Helpers

- (void)endWithError:(NSError *)error {
    [self.tick cancel];
    
    if (error) {
        [self.errors addObject:error];
    }
}

@end










@interface BLEPeripheralDisconnection ()

@property CBPeripheral *peripheral;
@property HLPTick *tick;

@end



@implementation BLEPeripheralDisconnection

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    if ((self.peripheral.state == CBPeripheralStateConnecting) || (self.peripheral.state == CBPeripheralStateConnected)) {
        self.peripheral.disconnection = self;
        [self.parent.central cancelPeripheralConnection:self.peripheral];
        
        self.tick = [HLPClock.shared tickWithInterval:DBL_MAX];
        [self.tick waitUntilFinished];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

#pragma mark - Helpers

- (void)updateState:(HLPOperationState)state {
    [super updateState:state];
    
    [self.delegates BLEPeripheralDisconnectionDidUpdateState:self];
    if (state == HLPOperationStateDidBegin) {
        [self.delegates BLEPeripheralDisconnectionDidBegin:self];
    } else if (state == HLPOperationStateDidEnd) {
        [self.delegates BLEPeripheralDisconnectionDidEnd:self];
    }
}

- (void)end {
    [self.tick cancel];
}

@end










@interface BLEServicesDiscovery ()

@property CBPeripheral *peripheral;
@property NSArray<CBUUID *> *services;
@property NSTimeInterval timeout;
@property HLPTick *tick;
@property BLEPeripheralDisconnection *disconnection;

@end



@implementation BLEServicesDiscovery

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral services:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
        self.services = services;
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    self.peripheral.delegate = self.delegates;
    [self.peripheral discoverServices:self.services];
    
    self.operation = self.tick = [HLPClock.shared tickWithInterval:self.timeout];
    [self.tick waitUntilFinished];
    if (self.cancelled) {
    } else if (!self.tick.cancelled) {
        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
        [self.errors addObject:error];
    } else if (self.errors.count > 0) {
    } else if (self.peripheral.services.count < self.services.count) {
        NSError *error = [NSError errorWithDomain:BLEErrorDomain code:BLEErrorLessServicesDiscovered userInfo:nil];
        [self.errors addObject:error];
    } else {
        for (CBService *service in self.peripheral.services) {
            self.peripheral.servicesByUUID[service.UUID] = service;
            service.characteristicsByUUID = HLPDictionary.strongToWeakDictionary;
        }
    }
    
    if (self.cancelled || (self.errors.count > 0)) {
        self.disconnection = [self.parent disconnectPeripheral:self.peripheral];
        [self.disconnection waitUntilFinished];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

#pragma mark - Peripheral

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    [self.tick cancel];
    
    if (error) {
        [self.errors addObject:error];
    }
}

@end










@interface BLECharacteristicsDiscovery ()

@property CBService *service;
@property NSArray<CBUUID *> *characteristics;
@property NSTimeInterval timeout;
@property HLPTick *tick;
@property BLEPeripheralDisconnection *disconnection;

@end



@implementation BLECharacteristicsDiscovery

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithService:(CBService *)service characteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.service = service;
        self.characteristics = characteristics;
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    self.service.peripheral.delegate = self.delegates;
    [self.service.peripheral discoverCharacteristics:self.characteristics forService:self.service];
    
    self.operation = self.tick = [HLPClock.shared tickWithInterval:self.timeout];
    [self.tick waitUntilFinished];
    if (self.cancelled) {
    } else if (!self.tick.cancelled) {
        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
        [self.errors addObject:error];
    } else if (self.errors.count > 0) {
    } else if (self.service.characteristics.count < self.characteristics.count) {
        NSError *error = [NSError errorWithDomain:BLEErrorDomain code:BLEErrorLessCharacteristicsDiscovered userInfo:nil];
        [self.errors addObject:error];
    } else {
        for (CBCharacteristic *characteristic in self.service.characteristics) {
            self.service.characteristicsByUUID[characteristic.UUID] = characteristic;
        }
    }
    
    if (self.cancelled || (self.errors.count > 0)) {
        self.disconnection = [self.parent disconnectPeripheral:self.service.peripheral];
        [self.disconnection waitUntilFinished];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

#pragma mark - Peripheral

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [self.tick cancel];
    
    if (error) {
        [self.errors addObject:error];
    }
}

@end










@interface BLECharacteristicReading ()

@property CBCharacteristic *characteristic;
@property NSTimeInterval timeout;
@property HLPTick *tick;
@property BLEPeripheralDisconnection *disconnection;

@end



@implementation BLECharacteristicReading

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.characteristic = characteristic;
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    self.characteristic.service.peripheral.delegate = self.delegates;
    [self.characteristic.service.peripheral readValueForCharacteristic:self.characteristic];
    
    self.operation = self.tick = [HLPClock.shared tickWithInterval:self.timeout];
    [self.tick waitUntilFinished];
    if (self.cancelled) {
    } else if (!self.tick.cancelled) {
        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
        [self.errors addObject:error];
    }
    
    if (self.cancelled || (self.errors.count > 0)) {
        self.disconnection = [self.parent disconnectPeripheral:self.characteristic.service.peripheral];
        [self.disconnection waitUntilFinished];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

#pragma mark - Peripheral

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [self.tick cancel];
    
    if (error) {
        [self.errors addObject:error];
    }
}

@end










@interface BLEL2CAPChannelOpening ()

@property CBPeripheral *peripheral;
@property CBL2CAPPSM psm;
@property NSTimeInterval timeout;
@property CBL2CAPChannel *channel;
@property HLPTick *tick;
@property BLEPeripheralDisconnection *disconnection;

@end



@implementation BLEL2CAPChannelOpening

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral psm:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
        self.psm = psm;
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    self.peripheral.delegate = self.delegates;
    [self.peripheral openL2CAPChannel:self.psm];
    
    self.operation = self.tick = [HLPClock.shared tickWithInterval:self.timeout];
    [self.tick waitUntilFinished];
    if (self.cancelled) {
    } else if (!self.tick.cancelled) {
        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
        [self.errors addObject:error];
    } else if (self.errors.count > 0) {
    } else {
        self.peripheral.channelsByPSM[@(self.channel.PSM)] = self.channel;
    }
    
    if (self.cancelled || (self.errors.count > 0)) {
        self.disconnection = [self.parent disconnectPeripheral:self.peripheral];
        [self.disconnection waitUntilFinished];
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

#pragma mark - Peripheral

- (void)peripheral:(CBPeripheral *)peripheral didOpenL2CAPChannel:(CBL2CAPChannel *)channel error:(NSError *)error {
    [self.tick cancel];
    
    if (error) {
        [self.errors addObject:error];
    } else {
        self.channel = channel;
    }
}

@end










@interface BLEL2CAPStreamsOpening ()

@property CBL2CAPChannel *channel;
@property NSTimeInterval timeout;
@property HLPStreams *streams;
@property HLPStreamsOpening *opening;
@property BLEPeripheralDisconnection *disconnection;

@end



@implementation BLEL2CAPStreamsOpening

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithChannel:(CBL2CAPChannel *)channel timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.channel = channel;
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
    self.streams = [HLPStreams streamsWithInputStream:self.channel.inputStream outputStream:self.channel.outputStream];
    
    self.operation = self.opening = [self.streams openWithTimeout:self.timeout];
    [self.opening waitUntilFinished];
    if (self.opening.cancelled) {
    } else if (self.opening.errors.count > 0) {
        [self.errors addObjectsFromArray:self.opening.errors];
    }
    
    if (self.cancelled || (self.errors.count > 0)) {
        self.disconnection = [self.parent disconnectPeripheral:(CBPeripheral *)self.channel.peer];
        [self.disconnection waitUntilFinished];
    }
    
    [self updateState:HLPOperationStateDidEnd];
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

- (BLEPeripheralConnection *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *,id> *)options timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    BLEPeripheralConnection *connection = [self connectPeripheral:peripheral options:options timeout:timeout];
    connection.completionBlock = completion;
    return connection;
}

- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral {
    BLEPeripheralDisconnection *disconnection = [BLEPeripheralDisconnection.alloc initWithPeripheral:peripheral];
    [self addOperation:disconnection];
    return disconnection;
}

- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral completion:(HLPVoidBlock)completion {
    BLEPeripheralDisconnection *disconnection = [self disconnectPeripheral:peripheral];
    disconnection.completionBlock = completion;
    return disconnection;
}

- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout {
    BLEServicesDiscovery *discovery = [BLEServicesDiscovery.alloc initWithPeripheral:peripheral services:services timeout:timeout];
    [self addOperation:discovery];
    return discovery;
}

- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    BLEServicesDiscovery *discovery = [self peripheral:peripheral discoverServices:services timeout:timeout];
    discovery.completionBlock = completion;
    return discovery;
}

- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout {
    BLECharacteristicsDiscovery *discovery = [BLECharacteristicsDiscovery.alloc initWithService:service characteristics:characteristics timeout:timeout];
    [self addOperation:discovery];
    return discovery;
}

- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    BLECharacteristicsDiscovery *discovery = [self service:service discoverCharacteristics:characteristics timeout:timeout];
    discovery.completionBlock = completion;
    return discovery;
}

- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic timeout:(NSTimeInterval)timeout {
    BLECharacteristicReading *reading = [BLECharacteristicReading.alloc initWithCharacteristic:characteristic timeout:timeout];
    [self addOperation:reading];
    return reading;
}

- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    BLECharacteristicReading *reading = [self readCharacteristic:characteristic timeout:timeout];
    reading.completionBlock = completion;
    return reading;
}

- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout {
    BLEL2CAPChannelOpening *opening = [BLEL2CAPChannelOpening.alloc initWithPeripheral:peripheral psm:psm timeout:timeout];
    [self addOperation:opening];
    return opening;
}

- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    BLEL2CAPChannelOpening *opening = [self peripheral:peripheral openL2CAPChannel:psm timeout:timeout];
    opening.completionBlock = completion;
    return opening;
}

- (BLEL2CAPStreamsOpening *)openL2CAPStreams:(CBL2CAPChannel *)channel timeout:(NSTimeInterval)timeout {
    BLEL2CAPStreamsOpening *opening = [BLEL2CAPStreamsOpening.alloc initWithChannel:channel timeout:timeout];
    [self addOperation:opening];
    return opening;
}

- (BLEL2CAPStreamsOpening *)openL2CAPStreams:(CBL2CAPChannel *)channel timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    BLEL2CAPStreamsOpening *opening = [self openL2CAPStreams:channel timeout:timeout];
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

//- (NSDictionary<NSString *, id> *)advertisement {
//    return self.strongDictionary[NSStringFromSelector(@selector(advertisement))];
//}
//
//- (void)setAdvertisement:(NSDictionary<NSString *, id> *)advertisement {
//    self.strongDictionary[NSStringFromSelector(@selector(advertisement))] = advertisement;
//}
//
//- (NSNumber *)rssi {
//    return self.strongDictionary[NSStringFromSelector(@selector(rssi))];
//}
//
//- (void)setRssi:(NSNumber *)rssi {
//    self.strongDictionary[NSStringFromSelector(@selector(rssi))] = rssi;
//}
//
//- (HLPDictionary<CBUUID *, CBService *> *)servicesByUUID {
//    return self.strongDictionary[NSStringFromSelector(@selector(servicesByUUID))];
//}
//
//- (void)setServicesByUUID:(HLPDictionary<CBUUID *, CBService *> *)servicesByUUID {
//    self.strongDictionary[NSStringFromSelector(@selector(servicesByUUID))] = servicesByUUID;
//}

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










@implementation CBService (BLE)

- (HLPDictionary<CBUUID *, CBCharacteristic *> *)characteristicsByUUID {
    return self.strongDictionary[NSStringFromSelector(@selector(characteristicsByUUID))];
}

- (void)setCharacteristicsByUUID:(HLPDictionary<CBUUID *, CBCharacteristic *> *)characteristicsByUUID {
    self.strongDictionary[NSStringFromSelector(@selector(characteristicsByUUID))] = characteristicsByUUID;
}

@end































@interface CBEPeripheralConnection ()

@property NSDictionary<NSString *, id> *options;

@end



@implementation CBEPeripheralConnection

@dynamic parent;

- (instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout {
    self = [super initWithTimeout:timeout];
    if (self) {
        self.options = options;
    }
    return self;
}

- (void)main {
    [super main];
    
    if ((self.parent.peripheral.state == CBPeripheralStateDisconnecting) || (self.parent.peripheral.state == CBPeripheralStateDisconnected)) {
        self.parent.connection = self;
        [self.parent.parent.central connectPeripheral:self.parent.peripheral options:self.options];
    } else if (self.parent.peripheral.state == CBPeripheralStateConnecting) {
        self.parent.connection = self;
    } else if (self.parent.peripheral.state == CBPeripheralStateConnected) {
        [self finish];
    }
}

@end










@interface CBEPeripheralDisconnection ()

@end



@implementation CBEPeripheralDisconnection

@dynamic parent;

- (void)main {
    if ((self.parent.peripheral.state == CBPeripheralStateConnecting) || (self.parent.peripheral.state == CBPeripheralStateConnected)) {
        self.parent.disconnection = self;
        [self.parent.parent.central cancelPeripheralConnection:self.parent.peripheral];
    } else if (self.parent.peripheral.state == CBPeripheralStateDisconnecting) {
        self.parent.disconnection = self;
    } else if (self.parent.peripheral.state == CBPeripheralStateDisconnected) {
        [self finish];
    }
}

@end










@interface CBEPeripheral ()

@property CBPeripheral *peripheral;

@end



@implementation CBEPeripheral

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
        
        self.peripheral.delegate = self.delegates;
    }
    return self;
}

- (CBEPeripheralConnection *)connectWithOptions:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout {
    CBEPeripheralConnection *connection = [CBEPeripheralConnection.alloc initWithOptions:options timeout:timeout];
    [self addOperation:connection];
    return connection;
}

- (CBEPeripheralConnection *)connectWithOptions:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    CBEPeripheralConnection *connection = [self connectWithOptions:options timeout:timeout];
    connection.completionBlock = completion;
    return connection;
}

- (CBEPeripheralDisconnection *)disconnect {
    CBEPeripheralDisconnection *disconnection = CBEPeripheralDisconnection.new;
    [self addOperation:disconnection];
    return disconnection;
}

- (CBEPeripheralDisconnection *)disconnectWithCompletion:(HLPVoidBlock)completion {
    CBEPeripheralDisconnection *disconnection = [self disconnect];
    disconnection.completionBlock = completion;
    return disconnection;
}

#pragma mark - Peripheral

@end










const NSEOperationState CBECentralManagerStateDidScanForPeripherals = 2;
const NSEOperationState CBECentralManagerStateDidStopScan = 3;



@interface CBECentralManager ()

@property NSDictionary<NSString *, id> *options;
@property CBCentralManager *central;
@property NSMutableDictionary<NSUUID *, CBEPeripheral *> *peripheralsByIdentifier;
@property NSMutableDictionary<NSString *, CBEPeripheral *> *peripheralsByName;

@end



@implementation CBECentralManager

@dynamic delegates;

- (instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options {
    self = super.init;
    if (self) {
        self.options = options;
        
        self.central = [CBCentralManager.alloc initWithDelegate:self.delegates queue:nil options:self.options];
        
        self.peripheralsByIdentifier = NSMutableDictionary.dictionary;
        self.peripheralsByName = NSMutableDictionary.dictionary;
    }
    return self;
}

- (void)scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs options:(NSDictionary<NSString *, id> *)options {
    [self.peripheralsByIdentifier removeAllObjects];
    [self.peripheralsByName removeAllObjects];
    
    [self.central scanForPeripheralsWithServices:serviceUUIDs options:options];
    
    [self updateState:CBECentralManagerStateDidScanForPeripherals];
}

- (void)stopScan {
    [self.central stopScan];
    
    [self updateState:CBECentralManagerStateDidStopScan];
}

#pragma mark - Central manager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    CBEPeripheral *cbePeripheral = self.peripheralsByIdentifier[peripheral.identifier];
    if (cbePeripheral) {
    } else {
        cbePeripheral = [CBEPeripheral.alloc initWithPeripheral:peripheral];
        [self addOperation:cbePeripheral];
        
        self.peripheralsByIdentifier[peripheral.identifier] = cbePeripheral;
        self.peripheralsByName[peripheral.name] = cbePeripheral;
    }
    
    cbePeripheral.advertisement = advertisementData;
    cbePeripheral.rssi = RSSI;
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    CBEPeripheral *cbePeripheral = self.peripheralsByIdentifier[peripheral.identifier];
    if (cbePeripheral.connection.isFinished) {
    } else {
        [cbePeripheral.connection finish];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    CBEPeripheral *cbePeripheral = self.peripheralsByIdentifier[peripheral.identifier];
    [cbePeripheral.disconnection finish];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    CBEPeripheral *cbePeripheral = self.peripheralsByIdentifier[peripheral.identifier];
    if (cbePeripheral.connection.isFinished) {
    } else {
        [cbePeripheral.connection.errors addObject:error];
        [cbePeripheral.connection finish];
    }
}

@end










@implementation CBPeripheral (CBE)

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

- (HLPDictionary<CBUUID *, CBService *> *)servicesByUUID {
    return self.strongDictionary[NSStringFromSelector(@selector(servicesByUUID))];
}

- (void)setServicesByUUID:(HLPDictionary<CBUUID *, CBService *> *)servicesByUUID {
    self.strongDictionary[NSStringFromSelector(@selector(servicesByUUID))] = servicesByUUID;
}

@end
