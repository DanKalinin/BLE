//
//  BLEPeripheral.h
//  BLE
//
//  Created by Dan Kalinin on 5/25/18.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Helpers/Helpers.h>

@class BLEPeripheralConnection, BLEPeripheralDisconnection, BLEServicesDiscovery, BLECharacteristicsDiscovery, BLECharacteristicReading, BLEL2CAPChannelOpening, BLECentralManager;










@protocol BLEPeripheralConnectionDelegate <HLPOperationDelegate>

@end



@interface BLEPeripheralConnection : HLPOperation <BLEPeripheralConnectionDelegate>

@property (readonly) BLECentralManager *parent;
@property (readonly) CBPeripheral *peripheral;
@property (readonly) NSDictionary<NSString *, id> *options;
@property (readonly) NSTimeInterval timeout;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout;
- (void)endWithError:(NSError *)error;

@end










@protocol BLEPeripheralDisconnectionDelegate <HLPOperationDelegate>

@end



@interface BLEPeripheralDisconnection : HLPOperation <BLEPeripheralDisconnectionDelegate>

@property (readonly) BLECentralManager *parent;
@property (readonly) CBPeripheral *peripheral;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

@end










@protocol BLEServicesDiscoveryDelegate <HLPOperationDelegate>

@end



@interface BLEServicesDiscovery : HLPOperation <BLEServicesDiscoveryDelegate>

@property (readonly) CBPeripheral *peripheral;
@property (readonly) NSArray<CBUUID *> *services;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral services:(NSArray<CBUUID *> *)services;

@end










@protocol BLECharacteristicsDiscoveryDelegate <HLPOperationDelegate>

@end



@interface BLECharacteristicsDiscovery : HLPOperation <BLECharacteristicsDiscoveryDelegate>

@property (readonly) CBService *service;
@property (readonly) NSArray<CBUUID *> *characteristics;

- (instancetype)initWithService:(CBService *)service characteristics:(NSArray<CBUUID *> *)characteristics;

@end










@protocol BLECharacteristicReadingDelegate <HLPOperationDelegate>

@end



@interface BLECharacteristicReading : HLPOperation

@property (readonly) CBCharacteristic *characteristic;

- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic;

@end










@protocol BLEL2CAPChannelOpeningDelegate <HLPOperationDelegate>

@end



@interface BLEL2CAPChannelOpening : HLPOperation <BLEL2CAPChannelOpeningDelegate>

@property (readonly) CBPeripheral *peripheral;
@property (readonly) CBL2CAPPSM psm;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral psm:(CBL2CAPPSM)psm;

@end










@protocol BLECentralManagerDelegate <HLPOperationDelegate, CBCentralManagerDelegate>

@end



@interface BLECentralManager : HLPOperation <BLECentralManagerDelegate>

@property (readonly) SurrogateArray<BLECentralManagerDelegate> *delegates;
@property (readonly) NSDictionary<NSString *, id> *options;
@property (readonly) CBCentralManager *manager;
@property (readonly) NSMutableDictionary<NSUUID *, CBPeripheral *> *peripheralsByIdentifier;
@property (readonly) NSMutableDictionary<NSString *, CBPeripheral *> *peripheralsByName;

- (instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options;

- (BLEPeripheralConnection *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout;
- (BLEPeripheralConnection *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout completion:(VoidBlock)completion;

- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral;
- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral completion:(VoidBlock)completion;

- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services;
- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services completion:(VoidBlock)completion;

- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics;
- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics completion:(VoidBlock)completion;

- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic;
- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic completion:(VoidBlock)completion;

- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm;
- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm completion:(VoidBlock)completion;

@end










@interface CBPeripheral (BLE)

@property NSDictionary<NSString *, id> *advertisement;
@property NSNumber *rssi;
@property BLEPeripheralConnection *connection;

@end