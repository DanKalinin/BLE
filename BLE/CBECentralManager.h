//
//  CBEPeripheral.h
//  CBE
//
//  Created by Dan Kalinin on 5/25/18.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Helpers/Helpers.h>
#import "CBEMain.h"

//@class BLEPeripheralConnection, BLEPeripheralDisconnection, BLEServicesDiscovery, BLECharacteristicsDiscovery, BLECharacteristicReading, BLEL2CAPChannelOpening, BLEL2CAPStreamsOpening, BLECentralManager;
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
//@protocol BLEPeripheralConnectionDelegate <HLPOperationDelegate>
//
//@end
//
//
//
//@interface BLEPeripheralConnection : HLPOperation <BLEPeripheralConnectionDelegate>
//
//@property (readonly) BLECentralManager *parent;
//@property (readonly) HLPArray<BLEPeripheralConnectionDelegate> *delegates;
//@property (readonly) CBPeripheral *peripheral;
//@property (readonly) NSDictionary<NSString *, id> *options;
//@property (readonly) NSTimeInterval timeout;
//@property (readonly) HLPTick *tick;
//@property (readonly) BLEPeripheralDisconnection *disconnection;
//
//- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout;
//- (void)endWithError:(NSError *)error;
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
//@protocol BLEPeripheralDisconnectionDelegate <HLPOperationDelegate>
//
//@optional
//- (void)BLEPeripheralDisconnectionDidUpdateState:(BLEPeripheralDisconnection *)disconnection;
//
//- (void)BLEPeripheralDisconnectionDidBegin:(BLEPeripheralDisconnection *)disconnection;
//- (void)BLEPeripheralDisconnectionDidEnd:(BLEPeripheralDisconnection *)disconnection;
//
//@end
//
//
//
//@interface BLEPeripheralDisconnection : HLPOperation <BLEPeripheralDisconnectionDelegate>
//
//@property (readonly) BLECentralManager *parent;
//@property (readonly) HLPArray<BLEPeripheralDisconnectionDelegate> *delegates;
//@property (readonly) CBPeripheral *peripheral;
//@property (readonly) HLPTick *tick;
//
//- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;
//- (void)end;
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
//@protocol BLEServicesDiscoveryDelegate <HLPOperationDelegate, CBPeripheralDelegate>
//
//@end
//
//
//
//@interface BLEServicesDiscovery : HLPOperation <BLEServicesDiscoveryDelegate>
//
//@property (readonly) BLECentralManager *parent;
//@property (readonly) HLPArray<BLEServicesDiscoveryDelegate> *delegates;
//@property (readonly) CBPeripheral *peripheral;
//@property (readonly) NSArray<CBUUID *> *services;
//@property (readonly) NSTimeInterval timeout;
//@property (readonly) HLPTick *tick;
//@property (readonly) BLEPeripheralDisconnection *disconnection;
//
//- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral services:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout;
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
//@protocol BLECharacteristicsDiscoveryDelegate <HLPOperationDelegate, CBPeripheralDelegate>
//
//@end
//
//
//
//@interface BLECharacteristicsDiscovery : HLPOperation <BLECharacteristicsDiscoveryDelegate>
//
//@property (readonly) BLECentralManager *parent;
//@property (readonly) HLPArray<BLECharacteristicsDiscoveryDelegate> *delegates;
//@property (readonly) CBService *service;
//@property (readonly) NSArray<CBUUID *> *characteristics;
//@property (readonly) NSTimeInterval timeout;
//@property (readonly) HLPTick *tick;
//@property (readonly) BLEPeripheralDisconnection *disconnection;
//
//- (instancetype)initWithService:(CBService *)service characteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout;
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
//@protocol BLECharacteristicReadingDelegate <HLPOperationDelegate, CBPeripheralDelegate>
//
//@end
//
//
//
//@interface BLECharacteristicReading : HLPOperation <BLECharacteristicReadingDelegate>
//
//@property (readonly) BLECentralManager *parent;
//@property (readonly) HLPArray<BLECharacteristicReadingDelegate> *delegates;
//@property (readonly) CBCharacteristic *characteristic;
//@property (readonly) NSTimeInterval timeout;
//@property (readonly) HLPTick *tick;
//@property (readonly) BLEPeripheralDisconnection *disconnection;
//
//- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic timeout:(NSTimeInterval)timeout;
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
//@protocol BLEL2CAPChannelOpeningDelegate <HLPOperationDelegate, CBPeripheralDelegate>
//
//@end
//
//
//
//@interface BLEL2CAPChannelOpening : HLPOperation <BLEL2CAPChannelOpeningDelegate>
//
//@property (readonly) BLECentralManager *parent;
//@property (readonly) HLPArray<BLEL2CAPChannelOpeningDelegate> *delegates;
//@property (readonly) CBPeripheral *peripheral;
//@property (readonly) CBL2CAPPSM psm;
//@property (readonly) NSTimeInterval timeout;
//@property (readonly) CBL2CAPChannel *channel;
//@property (readonly) HLPTick *tick;
//@property (readonly) BLEPeripheralDisconnection *disconnection;
//
//- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral psm:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout;
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
//@protocol BLEL2CAPStreamsOpeningDelegate <HLPOperationDelegate>
//
//@end
//
//
//
//@interface BLEL2CAPStreamsOpening : HLPOperation <BLEL2CAPStreamsOpeningDelegate>
//
//@property (readonly) BLECentralManager *parent;
//@property (readonly) HLPArray<BLEL2CAPStreamsOpeningDelegate> *delegates;
//@property (readonly) CBL2CAPChannel *channel;
//@property (readonly) NSTimeInterval timeout;
//@property (readonly) HLPStreams *streams;
//@property (readonly) HLPStreamsOpening *opening;
//@property (readonly) BLEPeripheralDisconnection *disconnection;
//
//- (instancetype)initWithChannel:(CBL2CAPChannel *)channel timeout:(NSTimeInterval)timeout;
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
//@protocol BLECentralManagerDelegate <BLEPeripheralConnectionDelegate, BLEPeripheralDisconnectionDelegate, BLEServicesDiscoveryDelegate, BLECharacteristicsDiscoveryDelegate, BLECharacteristicReadingDelegate, BLEL2CAPChannelOpeningDelegate, CBCentralManagerDelegate>
//
//@end
//
//
//
//@interface BLECentralManager : HLPOperation <BLECentralManagerDelegate>
//
//@property (readonly) HLPArray<BLECentralManagerDelegate> *delegates;
//@property (readonly) NSDictionary<NSString *, id> *options;
//@property (readonly) CBCentralManager *central;
//@property (readonly) NSMutableDictionary<NSUUID *, CBPeripheral *> *peripheralsByIdentifier;
//@property (readonly) NSMutableDictionary<NSString *, CBPeripheral *> *peripheralsByName;
//
//- (instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options;
//
//- (BLEPeripheralConnection *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout;
//- (BLEPeripheralConnection *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;
//
//- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral;
//- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral completion:(HLPVoidBlock)completion;
//
//- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout;
//- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;
//
//- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout;
//- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;
//
//- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic timeout:(NSTimeInterval)timeout;
//- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;
//
//- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout;
//- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;
//
//- (BLEL2CAPStreamsOpening *)openL2CAPStreams:(CBL2CAPChannel *)channel timeout:(NSTimeInterval)timeout;
//- (BLEL2CAPStreamsOpening *)openL2CAPStreams:(CBL2CAPChannel *)channel timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;
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
//@interface CBPeripheral (BLE)
//
//@property NSDictionary<NSString *, id> *advertisement;
//@property NSNumber *rssi;
//@property HLPDictionary<CBUUID *, CBService *> *servicesByUUID;
//@property BLEPeripheralConnection *connection;
//@property BLEPeripheralDisconnection *disconnection;
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
//@interface CBService (BLE)
//
//@property HLPDictionary<CBUUID *, CBCharacteristic *> *characteristicsByUUID;
//
//@end




















@class CBEPeripheralConnection;
@class CBEPeripheralDisconnection;
@class CBEPeripheral;
@class CBECentralManager;










@protocol CBEPeripheralConnectionDelegate <NSEOperationDelegate>

@end



@interface CBEPeripheralConnection : NSEOperation <CBEPeripheralConnectionDelegate>

@property (readonly) CBEPeripheral *parent;
@property (readonly) NSDictionary<NSString *, id> *options;
@property (readonly) NSTimeInterval timeout;
@property (readonly) NSETimer *timer;
@property (readonly) CBEPeripheralDisconnection *disconnection;

- (instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout;

@end










@protocol CBEPeripheralDisconnectionDelegate <NSEOperationDelegate>

@end



@interface CBEPeripheralDisconnection : NSEOperation <CBEPeripheralDisconnectionDelegate>

@property (readonly) CBEPeripheral *parent;

@end










@protocol CBEPeripheralDelegate <CBEPeripheralConnectionDelegate, CBEPeripheralDisconnectionDelegate, CBPeripheralDelegate>

@end



@interface CBEPeripheral : NSEOperation <CBEPeripheralDelegate>

@property (weak) CBEPeripheralConnection *connection;
@property (weak) CBEPeripheralDisconnection *disconnection;

@property (readonly) CBECentralManager *parent;
@property (readonly) HLPArray<CBEPeripheralDelegate> *delegates;
@property (readonly) CBPeripheral *peripheral;
@property (readonly) NSMutableDictionary<CBUUID *, CBService *> *servicesByUUID;
@property (readonly) NSMutableDictionary<NSNumber *, CBL2CAPChannel *> *channelsByPSM;
@property (readonly) NSDictionary<NSString *, id> *advertisement;
@property (readonly) NSNumber *rssi;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

- (CBEPeripheralConnection *)connectWithOptions:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout;
- (CBEPeripheralConnection *)connectWithOptions:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

- (CBEPeripheralDisconnection *)disconnect;
- (CBEPeripheralDisconnection *)disconnectWithCompletion:(HLPVoidBlock)completion;

@end










extern const NSEOperationState CBECentralManagerStateDidScanForPeripherals;
extern const NSEOperationState CBECentralManagerStateDidStopScan;



@protocol CBECentralManagerDelegate <CBEPeripheralDelegate, CBCentralManagerDelegate>

@end



@interface CBECentralManager<PeripheralClass> : NSEOperation <CBECentralManagerDelegate>

@property Class peripheralClass;

@property (readonly) HLPArray<CBECentralManagerDelegate> *delegates;
@property (readonly) NSDictionary<NSString *, id> *options;
@property (readonly) CBCentralManager *central;
@property (readonly) NSMutableDictionary<NSUUID *, PeripheralClass> *peripheralsByIdentifier;
@property (readonly) NSMutableDictionary<NSString *, PeripheralClass> *peripheralsByName;

- (instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options;

- (void)scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs options:(NSDictionary<NSString *, id> *)options;
- (void)stopScan;

//- (BLEPeripheralConnection *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout;
//- (BLEPeripheralConnection *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;
//
//- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral;
//- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral completion:(HLPVoidBlock)completion;
//
//- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout;
//- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;
//
//- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout;
//- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;
//
//- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic timeout:(NSTimeInterval)timeout;
//- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;
//
//- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout;
//- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;
//
//- (BLEL2CAPStreamsOpening *)openL2CAPStreams:(CBL2CAPChannel *)channel timeout:(NSTimeInterval)timeout;
//- (BLEL2CAPStreamsOpening *)openL2CAPStreams:(CBL2CAPChannel *)channel timeout:(NSTimeInterval)timeout completion:(HLPVoidBlock)completion;

@end
