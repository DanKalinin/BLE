//
//  BLEPeripheral.h
//  BLE
//
//  Created by Dan Kalinin on 5/25/18.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Helpers/Helpers.h>

@class BLEPeripheralConnection, BLEPeripheralServicesDiscovery, BLECentralManager;










@protocol BLEPeripheralConnectionDelegate <HLPOperationDelegate, CBCentralManagerDelegate>

@optional
- (void)BLEPeripheralConnectionDidUpdateState:(BLEPeripheralConnection *)connection;
- (void)BLEPeripheralConnectionDidUpdateProgress:(BLEPeripheralConnection *)connection;

- (void)BLEPeripheralConnectionDidBegin:(BLEPeripheralConnection *)connection;
- (void)BLEPeripheralConnectionDidEnd:(BLEPeripheralConnection *)connection;

@end



@interface BLEPeripheralConnection : HLPOperation <BLEPeripheralConnectionDelegate>

@property (readonly) BLECentralManager *parent;
@property (readonly) SurrogateArray<BLEPeripheralConnectionDelegate> *delegates;
@property (readonly) CBPeripheral *peripheral;
@property (readonly) NSDictionary<NSString *, id> *options;
@property (readonly) NSTimeInterval timeout;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout;

@end










@protocol BLEPeripheralServicesDiscoveryDelegate <HLPOperationDelegate, CBPeripheralDelegate>

@optional
- (void)BLEPeripheralServicesDiscoveryDidUpdateState:(BLEPeripheralServicesDiscovery *)discovery;
- (void)BLEPeripheralServicesDiscoveryDidUpdateProgress:(BLEPeripheralServicesDiscovery *)discovery;

- (void)BLEPeripheralServicesDiscoveryDidBegin:(BLEPeripheralServicesDiscovery *)discovery;
- (void)BLEPeripheralServicesDiscoveryDidEnd:(BLEPeripheralServicesDiscovery *)discovery;

@end



@interface BLEPeripheralServicesDiscovery : HLPOperation <BLEPeripheralServicesDiscoveryDelegate>

@property (readonly) SurrogateArray<BLEPeripheralServicesDiscoveryDelegate> *delegates;
@property (readonly) CBPeripheral *peripheral;
@property (readonly) NSArray<CBUUID *> *services;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral services:(NSArray<CBUUID *> *)services;

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

@end
