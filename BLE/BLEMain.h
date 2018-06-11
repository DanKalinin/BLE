//
//  BLEMain.h
//  BLE
//
//  Created by Dan Kalinin on 6/11/18.
//

#import <Foundation/Foundation.h>

extern NSErrorDomain const BLEErrorDomain;

NS_ERROR_ENUM(BLEErrorDomain) {
    BLEErrorUnknown,
    BLEErrorLessServicesDiscovered,
    BLEErrorLessCharacteristicsDiscovered
};
