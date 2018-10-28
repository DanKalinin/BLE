//
//  CBECentralManager.m
//  CoreBluetoothExt
//
//  Created by Dan Kalinin on 5/25/18.
//

#import "CBECentralManager.h"










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
    self.operation = self.timer = [NSEClock.shared timerWithInterval:self.timeout repeats:1];
    
    self.parent.reading = self;
    [self.parent.parent.parent.peripheral readValueForCharacteristic:self.parent.characteristic];
    
    [self.timer waitUntilFinished];
    if (self.timer.isCancelled) {
    } else {
        self.error = [NSError errorWithDomain:CBEErrorDomain code:CBEErrorMissingCharacteristics userInfo:nil];
    }
    
    if (self.isCancelled || self.error) {
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
        self.operation = self.timer = [NSEClock.shared timerWithInterval:self.timeout repeats:1];
        
        self.parent.characteristicsDiscovery = self;
        [self.parent.parent.peripheral discoverCharacteristics:self.characteristics forService:self.parent.service];
        
        [self.timer waitUntilFinished];
        if (self.timer.isCancelled) {
            if (self.isCancelled) {
            } else if (self.error) {
            } else {
                self.cachedDiscoveredCharacteristics = self.discoveredCharacteristics;
                self.cachedMissingCharacteristics = self.missingCharacteristics;
                if (self.cachedMissingCharacteristics.count > 0) {
                    self.error = [NSError errorWithDomain:CBEErrorDomain code:CBEErrorMissingCharacteristics userInfo:nil];
                } else {
                    for (CBCharacteristic *characteristic in self.cachedDiscoveredCharacteristics) {
                        CBECharacteristic *cbeCharacteristic = [self.parent.characteristicClass.alloc initWithCharacteristic:characteristic];
                        [cbeCharacteristic.delegates addObject:self.parent.delegates];
                        
                        self.parent.characteristicsByUUID[characteristic.UUID] = cbeCharacteristic;
                    }
                }
            }
        } else {
            self.error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
        }
        
        if (self.isCancelled || self.error) {
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
@property NSEStreamsOpening *opening;
@property CBEPeripheralDisconnection *disconnection;

@end



@implementation CBEL2CAPStreamsOpening

@dynamic parent;

- (instancetype)initWithTimeout:(NSTimeInterval)timeout {
    self = super.init;
    if (self) {
        self.timeout = timeout;
    }
    return self;
}

- (void)main {
    self.operation = self.opening = [self.parent.streams openWithTimeout:self.timeout];
    [self.opening waitUntilFinished];
    if (self.opening.isCancelled) {
    } else if (self.opening.error) {
        self.error = self.opening.error;
    }
    
    if (self.isCancelled || self.error) {
        self.disconnection = self.parent.parent.disconnect;
        [self.disconnection waitUntilFinished];
    }
    
    [self finish];
}

@end










@interface CBEL2CAPChannel ()

@property CBL2CAPChannel *channel;
@property NSEStreams *streams;

@end



@implementation CBEL2CAPChannel

@dynamic parent;

- (instancetype)initWithChannel:(CBL2CAPChannel *)channel {
    self = super.init;
    if (self) {
        self.channel = channel;
        
        self.streams = [NSEStreams streamsWithInputStream:self.channel.inputStream outputStream:self.channel.outputStream];
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










@interface CBEAdvertisement ()

@property NSString *localName;

@end



@implementation CBEAdvertisement

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = super.init;
    if (self) {
        self.localName = dictionary[CBAdvertisementDataLocalNameKey];
    }
    return self;
}

@end










@interface CBEPeripheralDidDisconnectInfo ()

@property NSError *error;

@end



@implementation CBEPeripheralDidDisconnectInfo

- (instancetype)initWithError:(NSError *)error {
    self = super.init;
    if (self) {
        self.error = error;
    }
    return self;
}

@end










@interface CBEPeripheralConnection ()

@property NSDictionary *options;
@property NSTimeInterval timeout;
@property NSETimer *timer;
@property CBEPeripheralDisconnection *disconnection;

@end



@implementation CBEPeripheralConnection

@dynamic parent;

- (instancetype)initWithOptions:(NSDictionary *)options timeout:(NSTimeInterval)timeout {
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
        self.operation = self.timer = [NSEClock.shared timerWithInterval:self.timeout repeats:1];
        
        self.parent.connection = self;
        if (self.parent.peripheral.state == CBPeripheralStateConnecting) {
        } else {
            [self.parent.parent.central connectPeripheral:self.parent.peripheral options:self.options];
        }
        
        [self.timer waitUntilFinished];
        if (self.timer.isCancelled) {
        } else {
            self.error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
        }
        
        if (self.isCancelled || self.error) {
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
@dynamic delegates;

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

#pragma mark - Helpers

- (void)updateState:(NSEOperationState)state {
    [super updateState:state];
    
    [self.delegates CBEPeripheralDisconnectionDidUpdateState:self];
    if (state == NSEOperationStateDidStart) {
        [self.delegates CBEPeripheralDisconnectionDidStart:self];
    } else if (state == NSEOperationStateDidFinish) {
        [self.delegates CBEPeripheralDisconnectionDidFinish:self];
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
        self.operation = self.timer = [NSEClock.shared timerWithInterval:self.timeout repeats:1];
        
        self.parent.servicesDiscovery = self;
        [self.parent.peripheral discoverServices:self.services];
        
        [self.timer waitUntilFinished];
        if (self.timer.isCancelled) {
            if (self.isCancelled) {
            } else if (self.error) {
            } else {
                self.cachedDiscoveredServices = self.discoveredServices;
                self.cachedMissingServices = self.missingServices;
                if (self.cachedMissingServices.count > 0) {
                    self.error = [NSError errorWithDomain:CBEErrorDomain code:CBEErrorMissingServices userInfo:nil];
                } else {
                    for (CBService *service in self.cachedDiscoveredServices) {
                        CBEService *cbeService = [self.parent.serviceClass.alloc initWithService:service];
                        [cbeService.delegates addObject:self.parent.delegates];
                        
                        self.parent.servicesByUUID[service.UUID] = cbeService;
                    }
                }
            }
        } else {
            self.error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
        }
        
        if (self.isCancelled || self.error) {
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
    self.operation = self.timer = [NSEClock.shared timerWithInterval:self.timeout repeats:1];
    
    self.parent.channelOpening = self;
    [self.parent.peripheral openL2CAPChannel:self.psm];
    
    [self.timer waitUntilFinished];
    if (self.timer.isCancelled) {
        if (self.isCancelled) {
        } else if (self.error) {
        } else {
            CBEL2CAPChannel *channel = [CBEL2CAPChannel.alloc initWithChannel:self.channel];
            [channel.delegates addObject:self.parent.delegates];
            
            self.parent.channelsByPSM[@(self.psm)] = channel;
        }
    } else {
        self.error = [NSError errorWithDomain:CBErrorDomain code:CBErrorConnectionTimeout userInfo:nil];
    }
    
    if (self.isCancelled || self.error) {
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
@property CBEAdvertisement *advertisement;
@property NSNumber *rssi;
@property CBEPeripheralDidDisconnectInfo *didDisconnectInfo;

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

- (CBEPeripheralConnection *)connectWithOptions:(NSDictionary *)options timeout:(NSTimeInterval)timeout {
    CBEPeripheralConnection *connection = [CBEPeripheralConnection.alloc initWithOptions:options timeout:timeout];
    [self addOperation:connection];
    return connection;
}

- (CBEPeripheralConnection *)connectWithOptions:(NSDictionary *)options timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion {
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
    self.servicesDiscovery.error = error;
    [self.servicesDiscovery.timer cancel];
}

- (void)peripheral:(CBPeripheral *)peripheral didOpenL2CAPChannel:(CBL2CAPChannel *)channel error:(NSError *)error {
    self.channelOpening.channel = channel;
    self.channelOpening.error = error;
    [self.channelOpening.timer cancel];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    CBEService *cbeService = self.servicesByUUID[service.UUID];
    cbeService.characteristicsDiscovery.error = error;
    [cbeService.characteristicsDiscovery.timer cancel];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    CBECharacteristic *cbeCharacteristic = self.servicesByUUID[characteristic.service.UUID].characteristicsByUUID[characteristic.UUID];
    cbeCharacteristic.reading.error = error;
    [cbeCharacteristic.reading.timer cancel];
}

@end










@interface CBECentralManagerDidDiscoverPeripheralInfo ()

@property CBEPeripheral *peripheral;

@end



@implementation CBECentralManagerDidDiscoverPeripheralInfo

- (instancetype)initWithPeripheral:(CBEPeripheral *)peripheral {
    self = super.init;
    if (self) {
        self.peripheral = peripheral;
    }
    return self;
}

@end










@interface CBECentralManager ()

@property NSDictionary *options;
@property CBCentralManager *central;
@property NSMutableDictionary<NSUUID *, CBEPeripheral *> *peripheralsByIdentifier;
@property NSMutableDictionary<NSString *, CBEPeripheral *> *peripheralsByName;
@property CBECentralManagerDidDiscoverPeripheralInfo *didDiscoverPeripheralInfo;

@end



@implementation CBECentralManager

@dynamic delegates;

- (instancetype)initWithOptions:(NSDictionary *)options {
    self = super.init;
    if (self) {
        self.options = options;
        
        self.peripheralClass = CBEPeripheral.class;
        
        self.central = [CBCentralManager.alloc initWithDelegate:self.delegates queue:nil options:self.options];
        
        self.peripheralsByIdentifier = NSMutableDictionary.dictionary;
        self.peripheralsByName = NSMutableDictionary.dictionary;
    }
    return self;
}

- (void)scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs options:(HLPDictionary<NSString *, id> *)options {
    [self.peripheralsByIdentifier removeAllObjects];
    [self.peripheralsByName removeAllObjects];
    
    [self.central scanForPeripheralsWithServices:serviceUUIDs options:options];
}

- (void)stopScan {
    [self.central stopScan];
}

#pragma mark - Central manager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self.delegates CBECentralManagerDidUpdateStatus:self];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    CBEPeripheral *cbePeripheral = self.peripheralsByIdentifier[peripheral.identifier];
    if (cbePeripheral) {
    } else {
        cbePeripheral = [self.peripheralClass.alloc initWithPeripheral:peripheral];
        [cbePeripheral.delegates addObject:self.delegates];
        
        self.peripheralsByIdentifier[peripheral.identifier] = cbePeripheral;
        self.peripheralsByName[peripheral.name] = cbePeripheral;
    }
    
    cbePeripheral.advertisement = [CBEAdvertisement.alloc initWithDictionary:advertisementData];
    cbePeripheral.rssi = RSSI;
    
    self.didDiscoverPeripheralInfo = [CBECentralManagerDidDiscoverPeripheralInfo.alloc initWithPeripheral:cbePeripheral];
    [self.delegates CBECentralManagerDidDiscoverPeripheral:self];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    CBEPeripheral *cbePeripheral = self.peripheralsByIdentifier[peripheral.identifier];
    [cbePeripheral.connection.timer cancel];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    CBEPeripheral *cbePeripheral = self.peripheralsByIdentifier[peripheral.identifier];
    if (error) {
        cbePeripheral.didDisconnectInfo = [CBEPeripheralDidDisconnectInfo.alloc initWithError:error];
        [cbePeripheral.delegates CBEPeripheralDidDisconnect:cbePeripheral];
    } else {
        [cbePeripheral.disconnection finish];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    CBEPeripheral *cbePeripheral = self.peripheralsByIdentifier[peripheral.identifier];
    cbePeripheral.connection.error = error;
    [cbePeripheral.connection.timer cancel];
}

@end
