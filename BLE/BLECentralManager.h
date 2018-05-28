//
//  BLEPeripheral.h
//  BLE
//
//  Created by Dan Kalinin on 5/25/18.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Helpers/Helpers.h>

@class BLEPeripheralOperation, BLEServiceOperation, BLECharacteristicOperation, BLEPeripheralConnection, BLEPeripheralDisconnection, BLEServicesDiscovery, BLECharacteristicsDiscovery, BLECharacteristicReading, BLEL2CAPChannelOpening, BLECentralManager;










@protocol BLEPeripheralOperationDelegate <HLPOperationDelegate, CBPeripheralDelegate>

@end



@interface BLEPeripheralOperation : HLPOperation <BLEPeripheralOperationDelegate>

@property (readonly) BLECentralManager *parent;
@property (readonly) CBPeripheral *peripheral;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

@end










@protocol BLEServiceOperationDelegate <BLEPeripheralOperationDelegate>

@end



@interface BLEServiceOperation : BLEPeripheralOperation <BLEServiceOperationDelegate>

@property (readonly) CBService *service;

- (instancetype)initWithService:(CBService *)service;

@end










@protocol BLECharacteristicOperationDelegate <BLEServiceOperationDelegate>

@end



@interface BLECharacteristicOperation : BLEServiceOperation <BLECharacteristicOperationDelegate>

@property (readonly) CBCharacteristic *characteristic;

- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic;

@end










@protocol BLEPeripheralConnectionDelegate <BLEPeripheralOperationDelegate>

@end



@interface BLEPeripheralConnection : BLEPeripheralOperation <BLEPeripheralConnectionDelegate>

@property (readonly) NSDictionary<NSString *, id> *options;
@property (readonly) NSTimeInterval timeout;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout;

@end










@protocol BLEPeripheralDisconnectionDelegate <BLEPeripheralOperationDelegate>

@end



@interface BLEPeripheralDisconnection : BLEPeripheralOperation <BLEPeripheralDisconnectionDelegate>

@end










@protocol BLEServicesDiscoveryDelegate <BLEPeripheralOperationDelegate>

@end



@interface BLEServicesDiscovery : BLEPeripheralOperation <BLEServicesDiscoveryDelegate>

@property (readonly) NSArray<CBUUID *> *services;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral services:(NSArray<CBUUID *> *)services;

@end










@protocol BLECharacteristicsDiscoveryDelegate <BLEServiceOperationDelegate>

@end



@interface BLECharacteristicsDiscovery : BLEServiceOperation <BLECharacteristicsDiscoveryDelegate>

@property (readonly) NSArray<CBUUID *> *characteristics;

- (instancetype)initWithService:(CBService *)service characteristics:(NSArray<CBUUID *> *)characteristics;

@end










@protocol BLECharacteristicReadingDelegate <BLECharacteristicOperationDelegate>

@end



@interface BLECharacteristicReading : BLECharacteristicOperation

@end










@protocol BLEL2CAPChannelOpeningDelegate <BLEPeripheralOperationDelegate>

@end



@interface BLEL2CAPChannelOpening : BLEPeripheralOperation <BLEL2CAPChannelOpeningDelegate>

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
