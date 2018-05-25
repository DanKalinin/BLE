//
//  BLEPeripheral.h
//  BLE
//
//  Created by Dan Kalinin on 5/25/18.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Helpers/Helpers.h>

@class BLEPeripheralConnection, BLECentralManager;










@protocol BLEPeripheralConnectionDelegate <HLPOperationDelegate, CBCentralManagerDelegate>

@end



@interface BLEPeripheralConnection : HLPOperation <BLEPeripheralConnectionDelegate>

@property (readonly) BLECentralManager *parent;
@property (readonly) SurrogateArray<BLEPeripheralConnectionDelegate> *delegates;
@property (readonly) CBPeripheral *peripheral;
@property (readonly) NSDictionary<NSString *, id> *options;
@property (readonly) NSTimeInterval timeout;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options timeout:(NSTimeInterval)timeout;

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

@end
