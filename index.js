var PayworksNative = require('react-native').NativeModules.PayworksNative;

module.exports = {
  transaction: PayworksNative.transaction,
  submitSignature: PayworksNative.submitSignature
};
