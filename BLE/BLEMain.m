//
//  BLEMain.m
//  BLE
//
//  Created by Dan Kalinin on 6/11/18.
//

#import "BLEMain.h"

NSErrorDomain const BLEErrorDomain = @"BLE";



@implementation CBPeer (BLE)

- (NSMutableDictionary<NSNumber *, CBL2CAPChannel *> *)channelsByPSM {
    return self.strongDictionary[NSStringFromSelector(@selector(channelsByPSM))];
}

- (void)setChannelsByPSM:(NSMutableDictionary<NSNumber *, CBL2CAPChannel *> *)channelsByPSM {
    self.strongDictionary[NSStringFromSelector(@selector(channelsByPSM))] = channelsByPSM;
}

@end
