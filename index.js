//
//  ReactNativePayworks
//
//  Created by Peace Chen on 2/27/2018.
//  Copyright OnceThere. All rights reserved.
//

var PayworksNative = require('react-native').NativeModules.PayworksNative;

module.exports = {
  transaction: PayworksNative.transaction,
  submitSignature: PayworksNative.submitSignature,
  cancelSignature: PayworksNative.cancelSignature,
  abortTransaction: PayworksNative.abortTransaction,
  disconnect: PayworksNative.disconnect,
};
