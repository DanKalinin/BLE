//
//  BLEPeripheral.h
//  BLE
//
//  Created by Dan Kalinin on 5/25/18.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Helpers/Helpers.h>

@class BLEPeripheralOperation, BLEPeripheralConnection, BLEPeripheralServicesDiscovery, BLEPeripheralCharacteristicsDiscovery, BLECentralManager;










@protocol BLEPeripheralOperationDelegate <HLPOperationDelegate, CBPeripheralDelegate>

@optional
- (void)BLEPeripheralOperationDidUpdateState:(BLEPeripheralOperation *)operation;
- (void)BLEPeripheralOperationDidUpdateProgress:(BLEPeripheralOperation *)operation;

- (void)BLEPeripheralOperationDidBegin:(BLEPeripheralOperation *)operation;
- (void)BLEPeripheralOperationDidEnd:(BLEPeripheralOperation *)operation;

@end



@interface BLEPeripheralOperation : HLPOperation

@property (readonly) BLECentralManager *parent;
@property (readonly) SurrogateArray<BLEPeripheralOperationDelegate> *delegates;
@property (readonly) CBPeripheral *peripheral;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

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










@protocol BLEPeripheralServicesDiscoveryDelegate <BLEPeripheralOperationDelegate>

@optional
- (void)BLEPeripheralServicesDiscoveryDidUpdateState:(BLEPeripheralServicesDiscovery *)discovery;
- (void)BLEPeripheralServicesDiscoveryDidUpdateProgress:(BLEPeripheralServicesDiscovery *)discovery;

- (void)BLEPeripheralServicesDiscoveryDidBegin:(BLEPeripheralServicesDiscovery *)discovery;
- (void)BLEPeripheralServicesDiscoveryDidEnd:(BLEPeripheralServicesDiscovery *)discovery;

@end



@interface BLEPeripheralServicesDiscovery : BLEPeripheralOperation <BLEPeripheralServicesDiscoveryDelegate>

@property (readonly) SurrogateArray<BLEPeripheralServicesDiscoveryDelegate> *delegates;
@property (readonly) NSArray<CBUUID *> *services;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral services:(NSArray<CBUUID *> *)services;

@end










@protocol BLEPeripheralCharacteristicsDiscoveryDelegate <BLEPeripheralOperationDelegate>

@optional
- (void)BLEPeripheralCharacteristicsDiscoveryDidUpdateState:(BLEPeripheralCharacteristicsDiscovery *)discovery;
- (void)BLEPeripheralCharacteristicsDiscoveryDidUpdateProgress:(BLEPeripheralCharacteristicsDiscovery *)discovery;

- (void)BLEPeripheralCharacteristicsDiscoveryDidBegin:(BLEPeripheralCharacteristicsDiscovery *)discovery;
- (void)BLEPeripheralCharacteristicsDiscoveryDidEnd:(BLEPeripheralCharacteristicsDiscovery *)discovery;

@end



@interface BLEPeripheralCharacteristicsDiscovery : BLEPeripheralOperation <BLEPeripheralCharacteristicsDiscoveryDelegate>

@property (readonly) SurrogateArray<BLEPeripheralCharacteristicsDiscoveryDelegate> *delegates;
@property (readonly) CBService *service;
@property (readonly) NSArray<CBUUID *> *characteristics;

- (instancetype)initWithService:(CBService *)service characteristics:(NSArray<CBUUID *> *)characteristics;

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

- (BLEPeripheralServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services;
- (BLEPeripheralServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services completion:(VoidBlock)completion;

- (BLEPeripheralCharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics;
- (BLEPeripheralCharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics completion:(VoidBlock)completion;

@end
