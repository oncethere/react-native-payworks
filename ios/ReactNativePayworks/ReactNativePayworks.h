//
//  PayworksNative.h
//  ReactNativePayworks
//
//  Created by Peace Chen on 1/19/17.
//  Copyright © 2017 OnceThere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mpos.core/mpos-extended.h>

#if __has_include(<React/RCTBridgeModule.h>)
// React Native >= 0.40
#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTBridgeModule.h>
#else
// React Native <= 0.39
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"
#import "RCTBridgeModule.h"
#endif

@interface PayworksNative : NSObject <RCTBridgeModule>

@end
