//
//  BLEPeripheral.h
//  BLE
//
//  Created by Dan Kalinin on 5/25/18.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Helpers/Helpers.h>
#import "BLEMain.h"

@class BLEPeripheralConnection, BLEPeripheralDisconnection, BLEServicesDiscovery, BLECharacteristicsDiscovery, BLECharacteristicReading, BLEL2CAPChannelOpening, BLECentralManager;










@protocol BLEPeripheralConnectionDelegate <HLPOperationDelegate>

@end



@interface BLEPeripheralConnection : HLPOperation <BLEPeripheralConnectionDelegate>

@property (readonly) BLECentralManager *parent;
@property (readonly) CBPeripheral *peripheral;
@property (readonly) NSDictionary<NSString *, id> *options;
@property (readonly) NSTimeInterval timeout;

@property (weak, readonly) HLPTimer *timer;
@property (weak, readonly) BLEPeripheralDisconnection *disconnection;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout;
- (void)endWithError:(NSError *)error;

@end










@protocol BLEPeripheralDisconnectionDelegate <HLPOperationDelegate>

@end



@interface BLEPeripheralDisconnection : HLPOperation <BLEPeripheralDisconnectionDelegate>

@property (readonly) BLECentralManager *parent;
@property (readonly) CBPeripheral *peripheral;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;
- (void)end;

@end










@protocol BLEServicesDiscoveryDelegate <HLPOperationDelegate, CBPeripheralDelegate>

@end



@interface BLEServicesDiscovery : HLPOperation <BLEServicesDiscoveryDelegate>

@property (readonly) SurrogateArray<BLEServicesDiscoveryDelegate> *delegates;
@property (readonly) CBPeripheral *peripheral;
@property (readonly) NSArray<CBUUID *> *services;
@property (readonly) NSTimeInterval timeout;

@property (weak, readonly) HLPTimer *timer;
@property (weak, readonly) BLEPeripheralDisconnection *disconnection;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral services:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout;

@end










@protocol BLECharacteristicsDiscoveryDelegate <HLPOperationDelegate, CBPeripheralDelegate>

@end



@interface BLECharacteristicsDiscovery : HLPOperation <BLECharacteristicsDiscoveryDelegate>

@property (readonly) SurrogateArray<BLECharacteristicsDiscoveryDelegate> *delegates;
@property (readonly) CBService *service;
@property (readonly) NSArray<CBUUID *> *characteristics;

- (instancetype)initWithService:(CBService *)service characteristics:(NSArray<CBUUID *> *)characteristics;

@end










@protocol BLECharacteristicReadingDelegate <HLPOperationDelegate, CBPeripheralDelegate>

@end



@interface BLECharacteristicReading : HLPOperation <BLECharacteristicReadingDelegate>

@property (readonly) SurrogateArray<BLECharacteristicReadingDelegate> *delegates;
@property (readonly) CBCharacteristic *characteristic;

- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic;

@end










@protocol BLEL2CAPChannelOpeningDelegate <HLPOperationDelegate, CBPeripheralDelegate>

@end



@interface BLEL2CAPChannelOpening : HLPOperation <BLEL2CAPChannelOpeningDelegate>

@property (readonly) SurrogateArray<BLEL2CAPChannelOpeningDelegate> *delegates;
@property (readonly) CBPeripheral *peripheral;
@property (readonly) CBL2CAPPSM psm;
@property (readonly) NSTimeInterval timeout;

@property (weak, readonly) HLPTimer *timer;
@property (weak, readonly) BLEPeripheralDisconnection *disconnection;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral psm:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout;

@end










@protocol BLECentralManagerDelegate <BLEPeripheralConnectionDelegate, BLEPeripheralDisconnectionDelegate, BLEServicesDiscoveryDelegate, BLECharacteristicsDiscoveryDelegate, BLECharacteristicReadingDelegate, BLEL2CAPChannelOpeningDelegate, CBCentralManagerDelegate>

@end



@interface BLECentralManager : HLPOperation <BLECentralManagerDelegate>

@property (readonly) SurrogateArray<BLECentralManagerDelegate> *delegates;
@property (readonly) NSDictionary<NSString *, id> *options;
@property (readonly) CBCentralManager *central;
@property (readonly) NSMutableDictionary<NSUUID *, CBPeripheral *> *peripheralsByIdentifier;
@property (readonly) NSMutableDictionary<NSString *, CBPeripheral *> *peripheralsByName;

- (instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options;

- (BLEPeripheralConnection *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout;
- (BLEPeripheralConnection *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout completion:(VoidBlock)completion;

- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral;
- (BLEPeripheralDisconnection *)disconnectPeripheral:(CBPeripheral *)peripheral completion:(VoidBlock)completion;

- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout;
- (BLEServicesDiscovery *)peripheral:(CBPeripheral *)peripheral discoverServices:(NSArray<CBUUID *> *)services timeout:(NSTimeInterval)timeout completion:(VoidBlock)completion;

- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics;
- (BLECharacteristicsDiscovery *)service:(CBService *)service discoverCharacteristics:(NSArray<CBUUID *> *)characteristics completion:(VoidBlock)completion;

- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic;
- (BLECharacteristicReading *)readCharacteristic:(CBCharacteristic *)characteristic completion:(VoidBlock)completion;

- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout;
- (BLEL2CAPChannelOpening *)peripheral:(CBPeripheral *)peripheral openL2CAPChannel:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout completion:(VoidBlock)completion;

@end










@interface CBPeripheral (BLE)

@property NSDictionary<NSString *, id> *advertisement;
@property NSNumber *rssi;
@property BLEPeripheralConnection *connection;
@property BLEPeripheralDisconnection *disconnection;

@end
