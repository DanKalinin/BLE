//
//  BLEMain.h
//  BLE
//
//  Created by Dan Kalinin on 6/11/18.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Helpers/Helpers.h>

extern NSErrorDomain const BLEErrorDomain;

NS_ERROR_ENUM(BLEErrorDomain) {
    BLEErrorUnknown,
    BLEErrorLessServicesDiscovered,
    BLEErrorLessCharacteristicsDiscovered
};



@interface CBPeer (BLE)

@property NSMutableDictionary<NSNumber *, CBL2CAPChannel *> *channelsByPSM;

@end
