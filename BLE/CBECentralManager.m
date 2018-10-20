//
//  CBEPeripheral.m
//  CBE
//
//  Created by Dan Kalinin on 5/25/18.
//

#import "CBECentralManager.h"










//@interface BLEPeripheralConnection ()
//
//@property CBPeripheral *peripheral;
//@property NSDictionary<NSString *, id> *options;
//@property NSTimeInterval timeout;
//@property HLPTick *tick;
//@property BLEPeripheralDisconnection *disconnection;
//
//@end
//
//
//
//@implementation BLEPeripheralConnection
//
//@dynamic parent;
//@dynamic delegates;
//
//- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout {
//    self = super.init;
//    if (self) {
//        self.peripheral = peripheral;
//        self.options = options;
//        self.timeout = timeout;
//    }
//    return self;
//}
//
//- (void)main {
//    [self updateState:HLPOperationStateDidBegin];
//    
//    self.peripheral.connection = self;
//    [self.parent.central connectPeripheral:self.peripheral options:self.options];
//    
//    self.operation = self.tick = [HLPClock.shared tickWithInterval:self.timeout];
//    [self.tick waitUntilFinished];
//    if (self.cancelled) {
//    } else if (!self.tick.cancelled) {
//        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
//        [self.errors addObject:error];
//    } else if (self.errors.count > 0) {
//    } else {
//        self.peripheral.servicesByUUID = HLPDictionary.strongToWeakDictionary;
//        self.peripheral.channelsByPSM = NSMutableDictionary.dictionary;
//    }
//    
//    if (self.cancelled || (self.errors.count > 0)) {
//        self.disconnection = [self.parent disconnectPeripheral:self.peripheral];
//        [self.disconnection waitUntilFinished];
//    }
//    
//    [self updateState:HLPOperationStateDidEnd];
//}
//
//#pragma mark - Helpers
//
//- (void)endWithError:(NSError *)error {
//    [self.tick cancel];
//    
//    if (error) {
//        [self.errors addObject:error];
//    }
//}
//
//@end
//
//
//
//
//
//
//
//
//
//
//@interface BLEPeripheralDisconnection ()
//
//@property CBPeripheral *peripheral;
//@property HLPTick *tick;
//
//@end
//
//
//
//@implementation BLEPeripheralDisconnection
//
//@dynamic parent;
//@dynamic delegates;
//
//- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
//    self = super.init;
//    if (self) {
//        self.peripheral = peripheral;
//    }
//    return self;
//}
//
//- (void)main {
//    [self updateState:HLPOperationStateDidBegin];
//    
//    if ((self.peripheral.state == CBPeripheralStateConnecting) || (self.peripheral.state == CBPeripheralStateConnected)) {
//        self.peripheral.disconnection = self;
//        [self.parent.central cancelPeripheralConnection:self.peripheral];
//        
//        self.tick = [HLPClock.shared tickWithInterval:DBL_MAX];
//        [self.tick waitUntilFinished];
//    }
//    
//    [self updateState:HLPOperationStateDidEnd];
//}
//
//#pragma mark - Helpers
//
//- (void)updateState:(HLPOperationState)state {
//    [super updateState:state];
//    
//    [self.delegates BLEPeripheralDisconnectionDidUpdateState:self];
//    if (state == HLPOperationStateDidBegin) {
//        [self.delegates BLEPeripheralDisconnectionDidBegin:self];
//    } else if (state == HLPOperationStateDidEnd) {
//        [self.delegates BLEPeripheralDisconnectionDidEnd:self];
//    }
//}
//
//- (void)end {
//    [self.tick cancel];
//}
//
//@end
//
//
//
//
//
//
//
//
//
//
//@interface BLEServicesDiscovery ()
//
//@property CBPeripheral *peripheral;
//@property NSArray<CBUUID *> *services;
//@property NSTimeInterval timeout;
//@property HLPTick *tick;
//@property BLEPeripheralDisconnection *disconnection;
//
//@end
//
//
//
//@implementation BLEServicesDiscovery
//
//@dynamic parent;
//@dynamic delegates;
//
//- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral services:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout {
//    self = super.init;
//    if (self) {
//        self.peripheral = peripheral;
//        self.services = services;
//        self.timeout = timeout;
//    }
//    return self;
//}
//
//- (void)main {
//    [self updateState:HLPOperationStateDidBegin];
//    
//    self.peripheral.delegate = self.delegates;
//    [self.peripheral discoverServices:self.services];
//    
//    self.operation = self.tick = [HLPClock.shared tickWithInterval:self.timeout];
//    [self.tick waitUntilFinished];
//    if (self.cancelled) {
//    } else if (!self.tick.cancelled) {
//        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
//        [self.errors addObject:error];
//    } else if (self.errors.count > 0) {
//    } else if (self.peripheral.services.count < self.services.count) {
//        NSError *error = [NSError errorWithDomain:BLEErrorDomain code:BLEErrorLessServicesDiscovered userInfo:nil];
//        [self.errors addObject:error];
//    } else {
//        for (CBService *service in self.peripheral.services) {
//            self.peripheral.servicesByUUID[service.UUID] = service;
//            service.characteristicsByUUID = HLPDictionary.strongToWeakDictionary;
//        }
//    }
//    
//    if (self.cancelled || (self.errors.count > 0)) {
//        self.disconnection = [self.parent disconnectPeripheral:self.peripheral];
//        [self.disconnection waitUntilFinished];
//    }
//    
//    [self updateState:HLPOperationStateDidEnd];
//}
//
//#pragma mark - Peripheral
//
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
//    [self.tick cancel];
//    
//    if (error) {
//        [self.errors addObject:error];
//    }
//}
//
//@end
//
//
//
//
//
//
//
//
//
//
//@interface BLECharacteristicsDiscovery ()
//
//@property CBService *service;
//@property NSArray<CBUUID *> *characteristics;
//@property NSTimeInterval timeout;
//@property HLPTick *tick;
//@property BLEPeripheralDisconnection *disconnection;
//
//@end
//
//
//
//@implementation BLECharacteristicsDiscovery
//
//@dynamic parent;
//@dynamic delegates;
//
//- (instancetype)initWithService:(CBService *)service characteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout {
//    self = super.init;
//    if (self) {
//        self.service = service;
//        self.characteristics = characteristics;
//        self.timeout = timeout;
//    }
//    return self;
//}
//
//- (void)main {
//    [self updateState:HLPOperationStateDidBegin];
//    
//    self.service.peripheral.delegate = self.delegates;
//    [self.service.peripheral discoverCharacteristics:self.characteristics forService:self.service];
//    
//    self.operation = self.tick = [HLPClock.shared tickWithInterval:self.timeout];
//    [self.tick waitUntilFinished];
//    if (self.cancelled) {
//    } else if (!self.tick.cancelled) {
//        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
//        [self.errors addObject:error];
//    } else if (self.errors.count > 0) {
//    } else if (self.service.characteristics.count < self.characteristics.count) {
//        NSError *error = [NSError errorWithDomain:BLEErrorDomain code:BLEErrorLessCharacteristicsDiscovered userInfo:nil];
//        [self.errors addObject:error];
//    } else {
//        for (CBCharacteristic *characteristic in self.service.characteristics) {
//            self.service.characteristicsByUUID[characteristic.UUID] = characteristic;
//        }
//    }
//    
//    if (self.cancelled || (self.errors.count > 0)) {
//        self.disconnection = [self.parent disconnectPeripheral:self.service.peripheral];
//        [self.disconnection waitUntilFinished];
//    }
//    
//    [self updateState:HLPOperationStateDidEnd];
//}
//
//#pragma mark - Peripheral
//
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
//    [self.tick cancel];
//    
//    if (error) {
//        [self.errors addObject:error];
//    }
//}
//
//@end
//
//
//
//
//
//
//
//
//
//
//@interface BLECharacteristicReading ()
//
//@property CBCharacteristic *characteristic;
//@property NSTimeInterval timeout;
//@property HLPTick *tick;
//@property BLEPeripheralDisconnection *disconnection;
//
//@end
//
//
//
//@implementation BLECharacteristicReading
//
//@dynamic parent;
//@dynamic delegates;
//
//- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic timeout:(NSTimeInterval)timeout {
//    self = super.init;
//    if (self) {
//        self.characteristic = characteristic;
//        self.timeout = timeout;
//    }
//    return self;
//}
//
//- (void)main {
//    [self updateState:HLPOperationStateDidBegin];
//    
//    self.characteristic.service.peripheral.delegate = self.delegates;
//    [self.characteristic.service.peripheral readValueForCharacteristic:self.characteristic];
//    
//    self.operation = self.tick = [HLPClock.shared tickWithInterval:self.timeout];
//    [self.tick waitUntilFinished];
//    if (self.cancelled) {
//    } else if (!self.tick.cancelled) {
//        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
//        [self.errors addObject:error];
//    }
//    
//    if (self.cancelled || (self.errors.count > 0)) {
//        self.disconnection = [self.parent disconnectPeripheral:self.characteristic.service.peripheral];
//        [self.disconnection waitUntilFinished];
//    }
//    
//    [self updateState:HLPOperationStateDidEnd];
//}
//
//#pragma mark - Peripheral
//
//- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    [self.tick cancel];
//    
//    if (error) {
//        [self.errors addObject:error];
//    }
//}
//
//@end
//
//
//
//
//
//
//
//
//
//
//@interface BLEL2CAPChannelOpening ()
//
//@property CBPeripheral *peripheral;
//@property CBL2CAPPSM psm;
//@property NSTimeInterval timeout;
//@property CBL2CAPChannel *channel;
//@property HLPTick *tick;
//@property BLEPeripheralDisconnection *disconnection;
//
//@end
//
//
//
//@implementation BLEL2CAPChannelOpening
//
//@dynamic parent;
//@dynamic delegates;
//
//- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral psm:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout {
//    self = super.init;
//    if (self) {
//        self.peripheral = peripheral;
//        self.psm = psm;
//        self.timeout = timeout;
//    }
//    return self;
//}
//
//- (void)main {
//    [self updateState:HLPOperationStateDidBegin];
//    
//    self.peripheral.delegate = self.delegates;
//    [self.peripheral openL2CAPChannel:self.psm];
//    
//    self.operation = self.tick = [HLPClock.shared tickWithInterval:self.timeout];
//    [self.tick waitUntilFinished];
//    if (self.cancelled) {
//    } else if (!self.tick.cancelled) {
//        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
//        [self.errors addObject:error];
//    } else if (self.errors.count > 0) {
//    } else {
//        self.peripheral.channelsByPSM[@(self.channel.PSM)] = self.channel;
//    }
//    
//    if (self.cancelled || (self.errors.count > 0)) {
//        self.disconnection = [self.parent disconnectPeripheral:self.peripheral];
//        [self.disconnection waitUntilFinished];
//    }
//    
//    [self updateState:HLPOperationStateDidEnd];
//}
//
//#pragma mark - Peripheral
//
//- (void)peripheral:(CBPeripheral *)peripheral didOpenL2CAPChannel:(CBL2CAPChannel *)channel error:(NSError *)error {
//    [self.tick cancel];
//    
//    if (error) {
//        [self.errors addObject:error];
//    } else {
//        self.channel = channel;
//    }
//}
//
//@end
//
//
//
//
//
//
//
//
//
//
//@interface BLEL2CAPStreamsOpening ()
//
//@property CBL2CAPChannel *channel;
//@property NSTimeInterval timeout;
//@property HLPStreams *streams;
//@property HLPStreamsOpening *opening;
//@property BLEPeripheralDisconnection *disconnection;
//
//@end
//
//
//
//@implementation BLEL2CAPStreamsOpening
//
//@dynamic parent;
//@dynamic delegates;
//
//- (instancetype)initWithChannel:(CBL2CAPChannel *)channel timeout:(NSTimeInterval)timeout {
//    self = super.init;
//    if (self) {
//        self.channel = channel;
//        self.timeout = timeout;
//    }
//    return self;
//}
//
//- (void)main {
//    [self updateState:HLPOperationStateDidBegin];
//    
//    self.streams = [HLPStreams streamsWithInputStream:self.channel.inputStream outputStream:self.channel.outputStream];
//    
//    self.operation = self.opening = [self.streams openWithTimeout:self.timeout];
//    [self.opening waitUntilFinished];
//    if (self.opening.cancelled) {
//    } else if (self.opening.errors.count > 0) {
//        [self.errors addObjectsFromArray:self.opening.errors];
//    }
//    
//    if (self.cancelled || (self.errors.count > 0)) {
//        self.disconnection = [self.parent disconnectPeripheral:(CBPeripheral *)self.channel.peer];
//        [self.disconnection waitUntilFinished];
//    }
//    
//    [self updateState:HLPOperationStateDidEnd];
//}
//
//@end
//
//
//
//
//
//
//
//
//
//
//@interface BLECentralManager ()
//
//@property NSDictionary<NSString *, id> *options;
//@property CBCentralManager *central;
//@property NSMutableDictionary<NSUUID *, CBPeripheral *> *peripheralsByIdentifier;
//@property NSMutableDictionary<NSString *, CBPeripheral *> *peripheralsByName;
//
//@end
//
//
//
//@implementation BLECentralManager
//
//@dynamic delegates;
//
//- (instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options {
//    self = super.init;
//    if (self) {
//        self.options = options;
//        
//        self.central = [CBCentralManager.alloc initWithDelegate:self.delegates queue:nil options:options];
//        
//        self.peripheralsByIdentifier = NSMutableDictionary.dictionary;
//        self.peripheralsByName = NSMutableDictionary.dictionary;
//    }
//    return self;
//}
//
//- (void)start {
//    [self.states removeAllObjects];
//    [self.errors removeAllObjects];
//    
//    [self.peripheralsByIdentifier removeAllObjects];
//    [self.peripheralsByName removeAllObjects];
//    
//    [self updateState:HLPOperationStateDidBegin];
//}
//
//- (void)cancel {
//    [self.central stopScan];
//    
//    [self updateState:HLPOperationStateDidEnd];
//}
//
//- (BLEPeripheralConnection *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *,id> *)options timeout:(NSTimeInterval)timeout {
//    BLEPeripheralConnection *connection = [BLEPeripheralConnection.alloc initWithPeripheral:peripheral options:options timeout:timeout];
//    [self addOperation:connection];
//    return connection;
//}
//
//- (BLEPeripheralConnection *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *,id> *)options timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
//    BLEPeripheralConnection *connection = [self connectPeripheral:peripheral options:options timeout:timeout];
//    connection.completionBlock = completion;
//    return connection;
//}
//
//- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral {
//    BLEPeripheralDisconnection *disconnection = [BLEPeripheralDisconnection.alloc initWithPeripheral:peripheral];
//    [self addOperation:disconnection];
//    return disconnection;
//}
//
//- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral completion:(HLPVoidBlock)completion {
//    BLEPeripheralDisconnection *disconnection = [self disconnectPeripheral:peripheral];
//    disconnection.completionBlock = completion;
//    return disconnection;
//}
//
//- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout {
//    BLEServicesDiscovery *discovery = [BLEServicesDiscovery.alloc initWithPeripheral:peripheral services:services timeout:timeout];
//    [self addOperation:discovery];
//    return discovery;
//}
//
//- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
//    BLEServicesDiscovery *discovery = [self peripheral:peripheral discoverServices:services timeout:timeout];
//    discovery.completionBlock = completion;
//    return discovery;
//}
//
//- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout {
//    BLECharacteristicsDiscovery *discovery = [BLECharacteristicsDiscovery.alloc initWithService:service characteristics:characteristics timeout:timeout];
//    [self addOperation:discovery];
//    return discovery;
//}
//
//- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
//    BLECharacteristicsDiscovery *discovery = [self service:service discoverCharacteristics:characteristics timeout:timeout];
//    discovery.completionBlock = completion;
//    return discovery;
//}
//
//- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic timeout:(NSTimeInterval)timeout {
//    BLECharacteristicReading *reading = [BLECharacteristicReading.alloc initWithCharacteristic:characteristic timeout:timeout];
//    [self addOperation:reading];
//    return reading;
//}
//
//- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
//    BLECharacteristicReading *reading = [self readCharacteristic:characteristic timeout:timeout];
//    reading.completionBlock = completion;
//    return reading;
//}
//
//- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout {
//    BLEL2CAPChannelOpening *opening = [BLEL2CAPChannelOpening.alloc initWithPeripheral:peripheral psm:psm timeout:timeout];
//    [self addOperation:opening];
//    return opening;
//}
//
//- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
//    BLEL2CAPChannelOpening *opening = [self peripheral:peripheral openL2CAPChannel:psm timeout:timeout];
//    opening.completionBlock = completion;
//    return opening;
//}
//
//- (BLEL2CAPStreamsOpening *)openL2CAPStreams:(CBL2CAPChannel *)channel timeout:(NSTimeInterval)timeout {
//    BLEL2CAPStreamsOpening *opening = [BLEL2CAPStreamsOpening.alloc initWithChannel:channel timeout:timeout];
//    [self addOperation:opening];
//    return opening;
//}
//
//- (BLEL2CAPStreamsOpening *)openL2CAPStreams:(CBL2CAPChannel *)channel timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
//    BLEL2CAPStreamsOpening *opening = [self openL2CAPStreams:channel timeout:timeout];
//    opening.completionBlock = completion;
//    return opening;
//}
//
//#pragma mark - Central manager
//
//- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
//}
//
//- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
//    self.peripheralsByIdentifier[peripheral.identifier] = peripheral;
//    self.peripheralsByName[peripheral.name] = peripheral;
//    
//    peripheral.advertisement = advertisementData;
//    peripheral.rssi = RSSI;
//}
//
//- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
//    [peripheral.connection endWithError:nil];
//}
//
//- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//    [peripheral.disconnection end];
//}
//
//- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//    [peripheral.connection endWithError:error];
//}
//
//@end
//
//
//
//
//
//
//
//
//
//
//@implementation CBPeripheral (BLE)
//
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
//
//- (BLEPeripheralConnection *)connection {
//    return self.weakDictionary[NSStringFromSelector(@selector(connection))];
//}
//
//- (void)setConnection:(BLEPeripheralConnection *)connection {
//    self.weakDictionary[NSStringFromSelector(@selector(connection))] = connection;
//}
//
//- (BLEPeripheralDisconnection *)disconnection {
//    return self.weakDictionary[NSStringFromSelector(@selector(disconnection))];
//}
//
//- (void)setDisconnection:(BLEPeripheralDisconnection *)disconnection {
//    self.weakDictionary[NSStringFromSelector(@selector(disconnection))] = disconnection;
//}
//
//@end
//
//
//
//
//
//
//
//
//
//
//@implementation CBService (BLE)
//
//- (HLPDictionary<CBUUID *, CBCharacteristic *> *)characteristicsByUUID {
//    return self.strongDictionary[NSStringFromSelector(@selector(characteristicsByUUID))];
//}
//
//- (void)setCharacteristicsByUUID:(HLPDictionary<CBUUID *, CBCharacteristic *> *)characteristicsByUUID {
//    self.strongDictionary[NSStringFromSelector(@selector(characteristicsByUUID))] = characteristicsByUUID;
//}
//
//@end






































@interface CBECharacteristicReading ()

@property NSTimeInterval timeout;
@property NSETimer *timer;
@property CBEPeripheralDisconnection *disconnection;

@end



@implementation CBECharacteristicReading

@dynamic parent;

- (instancetype)initWithTimeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    self.parent.reading = self;
    [self.parent.parent.parent.peripheral readValueForCharacteristic:self.parent.characteristic];
    
    self.operation = self.timer = [NSEClock.shared timerWithInterval:self.timeout repeats:1];
    [self.timer waitUntilFinished];
    if (self.timer.isCancelled) {
    } else {
        NSError *error = [NSError errorWithDomain:CBEErrorDomain code:CBEErrorMissingCharacteristics userInfo:nil];
        [self.errors addObject:error];
    }
    
    if (self.isCancelled || (self.errors.count > 0)) {
        self.disconnection = self.parent.parent.parent.disconnect;
        [self.disconnection waitUntilFinished];
    }
    
    [self finish];
}

@end










@interface CBECharacteristic ()

@property CBCharacteristic *characteristic;

@end



@implementation CBECharacteristic

@dynamic parent;

- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic {
    self = super.init;
    if (self) {
        self.characteristic = characteristic;
    }
    return self;
}

- (CBECharacteristicReading *)readWithTimeout:(NSTimeInterval)timeout {
    CBECharacteristicReading *reading = [CBECharacteristicReading.alloc initWithTimeout:timeout];
    [self addOperation:reading];
    return reading;
}

- (CBECharacteristicReading *)readWithTimeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    CBECharacteristicReading *reading = [self readWithTimeout:timeout];
    reading.completionBlock = completion;
    return reading;
}

@end










@interface CBECharacteristicsDiscovery ()

@property NSArray<CBUUID *> *characteristics;
@property NSTimeInterval timeout;
@property NSETimer *timer;
@property CBEPeripheralDisconnection *disconnection;
@property NSMutableArray<CBUUID *> *cachedMissingCharacteristics;
@property NSMutableArray<CBCharacteristic *> *cachedDiscoveredCharacteristics;

@end



@implementation CBECharacteristicsDiscovery

@dynamic parent;

- (instancetype)initWithCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.characteristics = characteristics;
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    self.cachedMissingCharacteristics = self.missingCharacteristics;
    if (self.cachedMissingCharacteristics.count > 0) {
        self.parent.characteristicsDiscovery = self;
        [self.parent.parent.peripheral discoverCharacteristics:self.characteristics forService:self.parent.service];
        
        self.operation = self.timer = [NSEClock.shared timerWithInterval:self.timeout repeats:1];
        [self.timer waitUntilFinished];
        if (self.timer.isCancelled) {
            if (self.isCancelled) {
            } else if (self.errors.count > 0) {
            } else {
                self.cachedDiscoveredCharacteristics = self.discoveredCharacteristics;
                self.cachedMissingCharacteristics = self.missingCharacteristics;
                if (self.cachedMissingCharacteristics.count > 0) {
                    NSError *error = [NSError errorWithDomain:CBEErrorDomain code:CBEErrorMissingCharacteristics userInfo:nil];
                    [self.errors addObject:error];
                } else {
                    for (CBCharacteristic *characteristic in self.cachedDiscoveredCharacteristics) {
                        CBECharacteristic *cbeCharacteristic = [self.parent.characteristicClass.alloc initWithCharacteristic:characteristic];
                        [self.parent addOperation:cbeCharacteristic];
                        
                        self.parent.characteristicsByUUID[characteristic.UUID] = cbeCharacteristic;
                    }
                }
            }
        } else {
            NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
            [self.errors addObject:error];
        }
        
        if (self.isCancelled || (self.errors.count > 0)) {
            self.disconnection = self.parent.parent.disconnect;
            [self.disconnection waitUntilFinished];
        }
    }
    
    [self finish];
}

#pragma mark - Accessors

- (NSMutableArray<CBUUID *> *)missingCharacteristics {
    NSMutableArray<CBUUID *> *missingCharacteristics = self.characteristics.mutableCopy;
    for (CBCharacteristic *characteristic in self.parent.service.characteristics) {
        [missingCharacteristics removeObject:characteristic.UUID];
    }
    return missingCharacteristics;
}

- (NSMutableArray<CBCharacteristic *> *)discoveredCharacteristics {
    NSMutableArray<CBCharacteristic *> *discoveredCharacteristics = NSMutableArray.array;
    for (CBCharacteristic *characteristic in self.parent.service.characteristics) {
        if ([self.cachedMissingCharacteristics containsObject:characteristic.UUID]) {
            [discoveredCharacteristics addObject:characteristic];
        }
    }
    return discoveredCharacteristics;
}

@end










@interface CBEService ()

@property CBService *service;
@property NSMutableDictionary<CBUUID *, CBECharacteristic *> *characteristicsByUUID;

@end



@implementation CBEService

@dynamic parent;

- (instancetype)initWithService:(CBService *)service {
    self = super.init;
    if (self) {
        self.service = service;
        
        self.characteristicClass = CBECharacteristic.class;
        
        self.characteristicsByUUID = NSMutableDictionary.dictionary;
    }
    return self;
}

- (CBECharacteristicsDiscovery *)discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout {
    CBECharacteristicsDiscovery *discovery = [CBECharacteristicsDiscovery.alloc initWithCharacteristics:characteristics timeout:timeout];
    [self addOperation:discovery];
    return discovery;
}

- (CBECharacteristicsDiscovery *)discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    CBECharacteristicsDiscovery *discovery = [self discoverCharacteristics:characteristics timeout:timeout];
    discovery.completionBlock = completion;
    return discovery;
}

@end










@interface CBEL2CAPStreamsOpening ()

@property NSTimeInterval timeout;

@end



@implementation CBEL2CAPStreamsOpening

- (instancetype)initWithTimeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.timeout = timeout;
    }
    return self;
}

@end










@interface CBEL2CAPChannel ()

@property CBL2CAPChannel *channel;

@end



@implementation CBEL2CAPChannel

- (instancetype)initWithChannel:(CBL2CAPChannel *)channel {
    self = super.init;
    if (self) {
        self.channel = channel;
    }
    return self;
}

- (CBEL2CAPStreamsOpening *)openStreamsWithTimeout:(NSTimeInterval)timeout {
    CBEL2CAPStreamsOpening *opening = [CBEL2CAPStreamsOpening.alloc initWithTimeout:timeout];
    [self addOperation:opening];
    return opening;
}

- (CBEL2CAPStreamsOpening *)openStreamsWithTimeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    CBEL2CAPStreamsOpening *opening = [self openStreamsWithTimeout:timeout];
    opening.completionBlock = completion;
    return opening;
}

@end










@interface CBEPeripheralConnection ()

@property NSDictionary<NSString *, id> *options;
@property NSTimeInterval timeout;
@property NSETimer *timer;
@property CBEPeripheralDisconnection *disconnection;

@end



@implementation CBEPeripheralConnection

@dynamic parent;

- (instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.options = options;
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    if (self.parent.peripheral.state == CBPeripheralStateConnected) {
    } else {
        self.parent.connection = self;
        if (self.parent.peripheral.state == CBPeripheralStateConnecting) {
        } else {
            [self.parent.parent.central connectPeripheral:self.parent.peripheral options:self.options];
        }
        
        self.operation = self.timer = [NSEClock.shared timerWithInterval:self.timeout repeats:1];
        [self.timer waitUntilFinished];
        if (self.timer.isCancelled) {
            if (self.isCancelled) {
            } else if (self.errors.count > 0) {
            } else {
                self.parent.parent.connectedPeripheralsByIdentifier[self.parent.peripheral.identifier] = self.parent;
                self.parent.parent.connectedPeripheralsByName[self.parent.peripheral.name] = self.parent;
            }
        } else {
            NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
            [self.errors addObject:error];
        }
        
        if (self.isCancelled || (self.errors.count > 0)) {
            self.disconnection = self.parent.disconnect;
            [self.disconnection waitUntilFinished];
        }
    }
    
    [self finish];
}

@end










@interface CBEPeripheralDisconnection ()

@end



@implementation CBEPeripheralDisconnection

@dynamic parent;

- (void)main {
    if (self.parent.peripheral.state == CBPeripheralStateDisconnected) {
        [self finish];
    } else {
        self.parent.disconnection = self;
        if (self.parent.peripheral.state == CBPeripheralStateDisconnecting) {
        } else {
            [self.parent.parent.central cancelPeripheralConnection:self.parent.peripheral];
        }
    }
}

@end










@interface CBEServicesDiscovery ()

@property NSArray<CBUUID *> *services;
@property NSTimeInterval timeout;
@property NSETimer *timer;
@property CBEPeripheralDisconnection *disconnection;
@property NSMutableArray<CBUUID *> *cachedMissingServices;
@property NSMutableArray<CBService *> *cachedDiscoveredServices;

@end



@implementation CBEServicesDiscovery

@dynamic parent;

- (instancetype)initWithServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.services = services;
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    self.cachedMissingServices = self.missingServices;
    if (self.cachedMissingServices.count > 0) {
        self.parent.servicesDiscovery = self;
        [self.parent.peripheral discoverServices:self.services];
        
        self.operation = self.timer = [NSEClock.shared timerWithInterval:self.timeout repeats:1];
        [self.timer waitUntilFinished];
        if (self.timer.isCancelled) {
            if (self.isCancelled) {
            } else if (self.errors.count > 0) {
            } else {
                self.cachedDiscoveredServices = self.discoveredServices;
                self.cachedMissingServices = self.missingServices;
                if (self.cachedMissingServices.count > 0) {
                    NSError *error = [NSError errorWithDomain:CBEErrorDomain code:CBEErrorMissingServices userInfo:nil];
                    [self.errors addObject:error];
                } else {
                    for (CBService *service in self.cachedDiscoveredServices) {
                        CBEService *cbeService = [self.parent.serviceClass.alloc initWithService:service];
                        [self.parent addOperation:cbeService];
                        
                        self.parent.servicesByUUID[service.UUID] = cbeService;
                    }
                }
            }
        } else {
            NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
            [self.errors addObject:error];
        }
        
        if (self.isCancelled || (self.errors.count > 0)) {
            self.disconnection = self.parent.disconnect;
            [self.disconnection waitUntilFinished];
        }
    }
    
    [self finish];
}

#pragma mark - Accessors

- (NSMutableArray<CBUUID *> *)missingServices {
    NSMutableArray<CBUUID *> *missingServices = self.services.mutableCopy;
    for (CBService *service in self.parent.peripheral.services) {
        [missingServices removeObject:service.UUID];
    }
    return missingServices;
}

- (NSMutableArray<CBService *> *)discoveredServices {
    NSMutableArray<CBService *> *discoveredServices = NSMutableArray.array;
    for (CBService *service in self.parent.peripheral.services) {
        if ([self.cachedMissingServices containsObject:service.UUID]) {
            [discoveredServices addObject:service];
        }
    }
    return discoveredServices;
}

@end










@interface CBEL2CAPChannelOpening ()

@property CBL2CAPPSM psm;
@property NSTimeInterval timeout;
@property NSETimer *timer;
@property CBL2CAPChannel *channel;
@property CBEPeripheralDisconnection *disconnection;

@end



@implementation CBEL2CAPChannelOpening

@dynamic parent;

- (instancetype)initWithPSM:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.psm = psm;
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    self.parent.channelOpening = self;
    [self.parent.peripheral openL2CAPChannel:self.psm];
    
    self.operation = self.timer = [NSEClock.shared timerWithInterval:self.timeout repeats:1];
    [self.timer waitUntilFinished];
    if (self.timer.isCancelled) {
        if (self.isCancelled) {
        } else if (self.errors.count > 0) {
        } else {
            CBEL2CAPChannel *channel = [CBEL2CAPChannel.alloc initWithChannel:self.channel];
            [self.parent addOperation:channel];
            
            self.parent.channelsByPSM[@(self.psm)] = channel;
        }
    } else {
        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
        [self.errors addObject:error];
    }
    
    if (self.isCancelled || (self.errors.count > 0)) {
        self.disconnection = self.parent.disconnect;
        [self.disconnection waitUntilFinished];
    }
    
    [self finish];
}

@end










@interface CBEPeripheral ()

@property CBPeripheral *peripheral;
@property NSMutableDictionary<CBUUID *, CBEService *> *servicesByUUID;
@property NSMutableDictionary<NSNumber *, CBEL2CAPChannel *> *channelsByPSM;
@property NSDictionary<NSString *, id> *advertisement;
@property NSNumber *rssi;

@end



@implementation CBEPeripheral

@dynamic parent;
@dynamic delegates;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
        self.peripheral.delegate = self.delegates;
        
        self.serviceClass = CBEService.class;
        self.channelClass = CBEL2CAPChannel.class;
        
        self.servicesByUUID = NSMutableDictionary.dictionary;
        self.channelsByPSM = NSMutableDictionary.dictionary;
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
    CBEPeripheralDisconnection *disconnection = self.disconnect;
    disconnection.completionBlock = completion;
    return disconnection;
}

- (CBEServicesDiscovery *)discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout {
    CBEServicesDiscovery *discovery = [CBEServicesDiscovery.alloc initWithServices:services timeout:timeout];
    [self addOperation:discovery];
    return discovery;
}

- (CBEServicesDiscovery *)discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    CBEServicesDiscovery *discovery = [self discoverServices:services timeout:timeout];
    discovery.completionBlock = completion;
    return discovery;
}

- (CBEL2CAPChannelOpening *)openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout {
    CBEL2CAPChannelOpening *opening = [CBEL2CAPChannelOpening.alloc initWithPSM:psm timeout:timeout];
    [self addOperation:opening];
    return opening;
}

- (CBEL2CAPChannelOpening *)openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
    CBEL2CAPChannelOpening *opening = [self openL2CAPChannel:psm timeout:timeout];
    opening.completionBlock = completion;
    return opening;
}

#pragma mark - Peripheral

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        [self.servicesDiscovery.errors addObject:error];
    }
    
    [self.servicesDiscovery.timer cancel];
}

- (void)peripheral:(CBPeripheral *)peripheral didOpenL2CAPChannel:(CBL2CAPChannel *)channel error:(NSError *)error {
    if (error) {
        [self.channelOpening.errors addObject:error];
    } else {
        self.channelOpening.channel = channel;
    }
    
    [self.channelOpening.timer cancel];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    CBEService *cbeService = self.servicesByUUID[service.UUID];
    
    if (error) {
        [cbeService.characteristicsDiscovery.errors addObject:error];
    }
    
    [cbeService.characteristicsDiscovery.timer cancel];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    CBECharacteristic *cbeCharacteristic = self.servicesByUUID[characteristic.service.UUID].characteristicsByUUID[characteristic.UUID];
    
    if (error) {
        [cbeCharacteristic.reading.errors addObject:error];
    }
    
    [cbeCharacteristic.reading.timer cancel];
}

@end










const NSEOperationState CBECentralManagerStateDidScanForPeripherals = 2;
const NSEOperationState CBECentralManagerStateDidStopScan = 3;



@interface CBECentralManager ()

@property NSDictionary<NSString *, id> *options;
@property CBCentralManager *central;
@property NSMutableDictionary<NSUUID *, CBEPeripheral *> *peripheralsByIdentifier;
@property NSMutableDictionary<NSString *, CBEPeripheral *> *peripheralsByName;
@property NSMutableDictionary<NSUUID *, CBEPeripheral *> *connectedPeripheralsByIdentifier;
@property NSMutableDictionary<NSString *, CBEPeripheral *> *connectedPeripheralsByName;

@end



@implementation CBECentralManager

@dynamic delegates;

- (instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options {
    self = super.init;
    if (self) {
        self.options = options;
        
        self.peripheralClass = CBEPeripheral.class;
        
        self.central = [CBCentralManager.alloc initWithDelegate:self.delegates queue:nil options:self.options];
        
        self.peripheralsByIdentifier = NSMutableDictionary.dictionary;
        self.peripheralsByName = NSMutableDictionary.dictionary;
        self.connectedPeripheralsByIdentifier = NSMutableDictionary.dictionary;
        self.connectedPeripheralsByName = NSMutableDictionary.dictionary;
    }
    return self;
}

- (void)scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs options:(HLPDictionary<NSString *, id> *)options {
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
    [self.delegates CBECentralManagerDidUpdateStatus:self];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    CBEPeripheral *cbePeripheral = self.peripheralsByIdentifier[peripheral.identifier];
    if (cbePeripheral) {
    } else {
        cbePeripheral = [self.peripheralClass.alloc initWithPeripheral:peripheral];
        [self addOperation:cbePeripheral];
        
        self.peripheralsByIdentifier[peripheral.identifier] = cbePeripheral;
        self.peripheralsByName[peripheral.name] = cbePeripheral;
    }
    
    cbePeripheral.advertisement = advertisementData;
    cbePeripheral.rssi = RSSI;
    
    [self.delegates CBECentralManager:self didDiscoverPeripheral:cbePeripheral];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    CBEPeripheral *cbePeripheral = self.peripheralsByIdentifier[peripheral.identifier];
    [cbePeripheral.connection.timer cancel];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    CBEPeripheral *cbePeripheral = self.connectedPeripheralsByIdentifier[peripheral.identifier];
    [cbePeripheral.disconnection finish];
    
    self.connectedPeripheralsByIdentifier[peripheral.identifier] = nil;
    self.connectedPeripheralsByName[peripheral.name] = nil;
    
    if (error) {
        [cbePeripheral.delegates CBEPeripheral:cbePeripheral didDisconnectWithError:error];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    CBEPeripheral *cbePeripheral = self.peripheralsByIdentifier[peripheral.identifier];
    [cbePeripheral.connection.errors addObject:error];
    [cbePeripheral.connection.timer cancel];
}

@end
