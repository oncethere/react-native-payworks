var PayworksNative = require('react-native').NativeModules.PayworksNative;

module.exports = {
  transaction: PayworksNative.transaction,
  submitSignature: PayworksNative.submitSignature,
  cancelSignature: PayworksNative.cancelSignature,
  abortTransaction: PayworksNative.abortTransaction,
  disconnect: PayworksNative.disconnect,
};
