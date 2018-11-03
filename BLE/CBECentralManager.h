//
//  CBECentralManager.h
//  CoreBluetoothExt
//
//  Created by Dan Kalinin on 5/25/18.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Helpers/Helpers.h>
#import "CBEMain.h"

@class CBECharacteristicReading;
@class CBECharacteristic;

@class CBECharacteristicsDiscovery;
@class CBEService;

@class CBEL2CAPStreamsOpening;
@class CBEL2CAPChannel;

@class CBEAdvertisement;
@class CBEPeripheralDidDisconnectInfo;
@class CBEPeripheralConnection;
@class CBEPeripheralDisconnection;
@class CBEServicesDiscovery;
@class CBEL2CAPChannelOpening;
@class CBEPeripheral;

@class CBECentralManagerDidDiscoverPeripheralInfo;
@class CBECentralManager;










@protocol CBECharacteristicReadingDelegate <NSEOperationDelegate>

@end



@interface CBECharacteristicReading : NSEOperation <CBECharacteristicReadingDelegate>

@property (readonly) CBECharacteristic *parent;
@property (readonly) NSTimeInterval timeout;
@property (readonly) NSETimer *timer;
@property (readonly) CBEPeripheralDisconnection *disconnection;

- (instancetype)initWithTimeout:(NSTimeInterval)timeout;

@end










@protocol CBECharacteristicDelegate <CBECharacteristicReadingDelegate>

@end



@interface CBECharacteristic : NSEOperation <CBECharacteristicDelegate>

@property (weak) CBECharacteristicReading *reading;

@property (readonly) CBEService *parent;
@property (readonly) CBCharacteristic *characteristic;

- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic;

- (CBECharacteristicReading *)readWithTimeout:(NSTimeInterval)timeout;
- (CBECharacteristicReading *)readWithTimeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

@end










@protocol CBECharacteristicsDiscoveryDelegate <NSEOperationDelegate>

@end



@interface CBECharacteristicsDiscovery : NSEOperation <CBECharacteristicsDiscoveryDelegate>

@property (readonly) CBEService *parent;
@property (readonly) NSArray<CBUUID *> *characteristics;
@property (readonly) NSTimeInterval timeout;
@property (readonly) NSETimer *timer;
@property (readonly) CBEPeripheralDisconnection *disconnection;
@property (readonly) NSMutableArray<CBUUID *> *missingCharacteristics;
@property (readonly) NSMutableArray<CBUUID *> *cachedMissingCharacteristics;
@property (readonly) NSMutableArray<CBCharacteristic *> *discoveredCharacteristics;
@property (readonly) NSMutableArray<CBCharacteristic *> *cachedDiscoveredCharacteristics;

- (instancetype)initWithCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout;

@end










@protocol CBEServiceDelegate <CBECharacteristicsDiscoveryDelegate>

@end



@interface CBEService : NSEOperation <CBEServiceDelegate>

@property Class characteristicClass;

@property (weak) CBECharacteristicsDiscovery *characteristicsDiscovery;

@property (readonly) CBEPeripheral *parent;
@property (readonly) CBService *service;
@property (readonly) NSMutableDictionary<CBUUID *, CBECharacteristic *> *characteristicsByUUID;

- (instancetype)initWithService:(CBService *)service;

- (CBECharacteristicsDiscovery *)discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout;
- (CBECharacteristicsDiscovery *)discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

@end










@protocol CBEL2CAPStreamsOpeningDelegate <NSEOperationDelegate>

@end



@interface CBEL2CAPStreamsOpening : NSEOperation <CBEL2CAPStreamsOpeningDelegate>

@property (readonly) CBEL2CAPChannel *parent;
@property (readonly) NSTimeInterval timeout;
@property (readonly) NSEStreamsOpening *opening;
@property (readonly) CBEPeripheralDisconnection *disconnection;

- (instancetype)initWithTimeout:(NSTimeInterval)timeout;

@end










@protocol CBEL2CAPChannelDelegate <CBEL2CAPStreamsOpeningDelegate>

@end



@interface CBEL2CAPChannel : NSEOperation <CBEL2CAPChannelDelegate>

@property (readonly) CBEPeripheral *parent;
@property (readonly) CBL2CAPChannel *channel;
@property (readonly) NSEStreams *streams;

- (instancetype)initWithChannel:(CBL2CAPChannel *)channel;

- (CBEL2CAPStreamsOpening *)openStreamsWithTimeout:(NSTimeInterval)timeout;
- (CBEL2CAPStreamsOpening *)openStreamsWithTimeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

@end










@interface CBEAdvertisement : HLPObject

@property (readonly) NSString *localName;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end










@interface CBEPeripheralDidDisconnectInfo : HLPObject

@property (readonly) NSError *error;

- (instancetype)initWithError:(NSError *)error;

@end










@protocol CBEPeripheralConnectionDelegate <NSEOperationDelegate>

@end



@interface CBEPeripheralConnection : NSEOperation <CBEPeripheralConnectionDelegate>

@property (readonly) CBEPeripheral *parent;
@property (readonly) NSDictionary *options;
@property (readonly) NSTimeInterval timeout;
@property (readonly) NSETimer *timer;
@property (readonly) CBEPeripheralDisconnection *disconnection;

- (instancetype)initWithOptions:(NSDictionary *)options timeout:(NSTimeInterval)timeout;

@end










@protocol CBEPeripheralDisconnectionDelegate <NSEOperationDelegate>

@optional
- (void)CBEPeripheralDisconnectionDidUpdateState:(CBEPeripheralDisconnection *)disconnection;
- (void)CBEPeripheralDisconnectionDidStart:(CBEPeripheralDisconnection *)disconnection;
- (void)CBEPeripheralDisconnectionDidFinish:(CBEPeripheralDisconnection *)disconnection;

@end



@interface CBEPeripheralDisconnection : NSEOperation <CBEPeripheralDisconnectionDelegate>

@property (readonly) CBEPeripheral *parent;
@property (readonly) HLPArray<CBEPeripheralDisconnectionDelegate> *delegates;

@end










@protocol CBEServicesDiscoveryDelegate <NSEOperationDelegate>

@end



@interface CBEServicesDiscovery : NSEOperation <CBEServicesDiscoveryDelegate>

@property (readonly) CBEPeripheral *parent;
@property (readonly) NSArray<CBUUID *> *services;
@property (readonly) NSTimeInterval timeout;
@property (readonly) NSETimer *timer;
@property (readonly) CBEPeripheralDisconnection *disconnection;
@property (readonly) NSMutableArray<CBUUID *> *missingServices;
@property (readonly) NSMutableArray<CBUUID *> *cachedMissingServices;
@property (readonly) NSMutableArray<CBService *> *discoveredServices;
@property (readonly) NSMutableArray<CBService *> *cachedDiscoveredServices;

- (instancetype)initWithServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout;

@end










@protocol CBEL2CAPChannelOpeningDelegate <NSEOperationDelegate>

@end



@interface CBEL2CAPChannelOpening : NSEOperation <CBEL2CAPChannelOpeningDelegate>

@property (readonly) CBEPeripheral *parent;
@property (readonly) CBL2CAPPSM psm;
@property (readonly) NSTimeInterval timeout;
@property (readonly) NSETimer *timer;
@property (readonly) CBL2CAPChannel *channel;
@property (readonly) CBEPeripheralDisconnection *disconnection;

- (instancetype)initWithPSM:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout;

@end










@protocol CBEPeripheralDelegate <CBEServiceDelegate, CBEPeripheralConnectionDelegate, CBEPeripheralDisconnectionDelegate, CBEServicesDiscoveryDelegate, CBEL2CAPChannelOpeningDelegate, CBPeripheralDelegate>

@optional
- (void)CBEPeripheralDidDisconnect:(CBEPeripheral *)peripheral;

@end



@interface CBEPeripheral : NSEOperation <CBEPeripheralDelegate>

@property Class serviceClass;
@property Class channelClass;

@property (weak) CBEPeripheralConnection *connection;
@property (weak) CBEPeripheralDisconnection *disconnection;
@property (weak) CBEServicesDiscovery *servicesDiscovery;
@property (weak) CBEL2CAPChannelOpening *channelOpening;

@property (readonly) CBECentralManager *parent;
@property (readonly) HLPArray<CBEPeripheralDelegate> *delegates;
@property (readonly) CBPeripheral *peripheral;
@property (readonly) NSMutableDictionary<CBUUID *, CBEService *> *servicesByUUID;
@property (readonly) NSMutableDictionary<NSNumber *, CBEL2CAPChannel *> *channelsByPSM;
@property (readonly) CBEAdvertisement *advertisement;
@property (readonly) NSNumber *rssi;
@property (readonly) CBEPeripheralDidDisconnectInfo *didDisconnectInfo;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

- (CBEPeripheralConnection *)connectWithOptions:(NSDictionary *)options timeout:(NSTimeInterval)timeout;
- (CBEPeripheralConnection *)connectWithOptions:(NSDictionary *)options timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

- (CBEPeripheralDisconnection *)disconnect;
- (CBEPeripheralDisconnection *)disconnectWithCompletion:(HLPVoidBlock)completion;

- (CBEServicesDiscovery *)discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout;
- (CBEServicesDiscovery *)discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

- (CBEL2CAPChannelOpening *)openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout;
- (CBEL2CAPChannelOpening *)openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

@end










@interface CBECentralManagerDidDiscoverPeripheralInfo : HLPObject

@property (readonly) CBEPeripheral *peripheral;

- (instancetype)initWithPeripheral:(CBEPeripheral *)peripheral;

@end










@protocol CBECentralManagerDelegate <CBEPeripheralDelegate, CBCentralManagerDelegate>

@optional
- (void)CBECentralManagerDidUpdateStatus:(CBECentralManager *)central;
- (void)CBECentralManagerDidDiscoverPeripheral:(CBECentralManager *)central;

@end



@interface CBECentralManager : NSEOperation <CBECentralManagerDelegate>

@property Class peripheralClass;

@property (readonly) HLPArray<CBECentralManagerDelegate> *delegates;
@property (readonly) NSDictionary *options;
@property (readonly) CBCentralManager *central;
@property (readonly) NSMutableDictionary<NSUUID *, CBEPeripheral *> *peripheralsByIdentifier;
@property (readonly) NSMutableDictionary<NSString *, CBEPeripheral *> *peripheralsByName;
@property (readonly) CBECentralManagerDidDiscoverPeripheralInfo *didDiscoverPeripheralInfo;

- (instancetype)initWithOptions:(NSDictionary *)options;

- (void)scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs options:(NSDictionary *)options;
- (void)stopScan;

@end
