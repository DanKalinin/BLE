//
//  BLEPeripheral.h
//  BLE
//
//  Created by Dan Kalinin on 5/25/18.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Helpers/Helpers.h>

@class BLEPeripheralOperation, BLEServiceOperation, BLECharacteristicOperation, BLEPeripheralConnection, BLEServicesDiscovery, BLECharacteristicsDiscovery, BLECharacteristicReading, BLECentralManager;










@protocol BLEPeripheralOperationDelegate <HLPOperationDelegate, CBPeripheralDelegate>

@end



@interface BLEPeripheralOperation : HLPOperation <BLEPeripheralOperationDelegate>

@property (readonly) BLECentralManager *parent;
@property (readonly) SurrogateArray<BLEPeripheralOperationDelegate> *delegates;
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

@optional
- (void)BLEPeripheralConnectionDidUpdateState:(BLEPeripheralConnection *)connection;
- (void)BLEPeripheralConnectionDidUpdateProgress:(BLEPeripheralConnection *)connection;

- (void)BLEPeripheralConnectionDidBegin:(BLEPeripheralConnection *)connection;
- (void)BLEPeripheralConnectionDidEnd:(BLEPeripheralConnection *)connection;

@end



@interface BLEPeripheralConnection : BLEPeripheralOperation <BLEPeripheralConnectionDelegate>

@property (readonly) SurrogateArray<BLEPeripheralConnectionDelegate> *delegates;
@property (readonly) NSDictionary<NSString *, id> *options;
@property (readonly) NSTimeInterval timeout;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout;

@end










@protocol BLEServicesDiscoveryDelegate <BLEPeripheralOperationDelegate>

@optional
- (void)BLEServicesDiscoveryDidUpdateState:(BLEServicesDiscovery *)discovery;
- (void)BLEServicesDiscoveryDidUpdateProgress:(BLEServicesDiscovery *)discovery;

- (void)BLEServicesDiscoveryDidBegin:(BLEServicesDiscovery *)discovery;
- (void)BLEServicesDiscoveryDidEnd:(BLEServicesDiscovery *)discovery;

@end



@interface BLEServicesDiscovery : BLEPeripheralOperation <BLEServicesDiscoveryDelegate>

@property (readonly) SurrogateArray<BLEServicesDiscoveryDelegate> *delegates;
@property (readonly) NSArray<CBUUID *> *services;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral services:(NSArray<CBUUID *> *)services;

@end










@protocol BLECharacteristicsDiscoveryDelegate <BLEServiceOperationDelegate>

@optional
- (void)BLECharacteristicsDiscoveryDidUpdateState:(BLECharacteristicsDiscovery *)discovery;
- (void)BLECharacteristicsDiscoveryDidUpdateProgress:(BLECharacteristicsDiscovery *)discovery;

- (void)BLECharacteristicsDiscoveryDidBegin:(BLECharacteristicsDiscovery *)discovery;
- (void)BLECharacteristicsDiscoveryDidEnd:(BLECharacteristicsDiscovery *)discovery;

@end



@interface BLECharacteristicsDiscovery : BLEServiceOperation <BLECharacteristicsDiscoveryDelegate>

@property (readonly) SurrogateArray<BLECharacteristicsDiscoveryDelegate> *delegates;
@property (readonly) NSArray<CBUUID *> *characteristics;

- (instancetype)initWithService:(CBService *)service characteristics:(NSArray<CBUUID *> *)characteristics;

@end










@protocol BLECharacteristicReadingDelegate <BLECharacteristicOperationDelegate>

@optional
- (void)BLECharacteristicReadingDidUpdateState:(BLECharacteristicReading *)reading;
- (void)BLECharacteristicReadingDidUpdateProgress:(BLECharacteristicReading *)reading;

- (void)BLECharacteristicReadingDidBegin:(BLECharacteristicReading *)reading;
- (void)BLECharacteristicReadingDidEnd:(BLECharacteristicReading *)reading;

@end



@interface BLECharacteristicReading : BLECharacteristicOperation

@property (readonly) SurrogateArray<BLECharacteristicReadingDelegate> *delegates;

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

- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services;
- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services completion:(VoidBlock)completion;

- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics;
- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics completion:(VoidBlock)completion;

- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic;
- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic completion:(VoidBlock)completion;

@end
