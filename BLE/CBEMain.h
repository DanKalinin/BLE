//
//  CBEMain.h
//  CBE
//
//  Created by Dan Kalinin on 6/11/18.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Helpers/Helpers.h>

extern NSErrorDomain const CBEErrorDomain;

NS_ERROR_ENUM(CBEErrorDomain) {
    CBEErrorUnknown,
    CBEErrorLessServicesDiscovered,
    CBEErrorLessCharacteristicsDiscovered
};
