# React Native Payworks Integration

This is a React Native library that wraps the [Payworks](http://www.payworks.mpymnt.com/) native library for interfacing with Miura hardware readers.

The initial release supports iOS and Stripe only.  Android support is TBD.  Pull requests are welcome.

## Usage

* `npm install react-native-payworks --save`
* `react-native link`
* Import the module in a RN app:
`import ReactNativePayworks from 'react-native-payworks';`
* Platform-specific dependencies are listed under the Example section.

## API

All available methods are promise-based:

* `transaction(paramObj)` -- Initiate a charge on the card reader. Upon completion of a transaction, the promise resolves with a _status_ key.  The _transaction_ method accepts an object as the first parameter containing the following fields:
 * _providerMode_: [MPProviderMode](http://www.payworks.mpymnt.com/node/272): LIVE=1, TEST=2, MOCK=3, JUNGLE=4, LIVE_FIXED=5, TEST_FIXED=6.
 * _merchantIdentifier_: Payworks-generated merchant ID.
 * _merchantSecretKey_: Payworks-generated merchant secret key.
 * _chargeWithAmount_: Amount to charge.
 * _currency_: Currency to use for the charge (22 indicates USD).
 * _optionals_: Additional data to pass to Payworks such as applicationFee. Refer to the [Payworks Transactions with Stripe documentation](http://www.payworks.mpymnt.com/node/268) for details.

* `submitSignature(image)` -- Send a captured signature when a _PayworksTransactionEvent_ event contains the _action_ key with value _MPTransactionActionCustomerSignature_.  The _image_ parameter is anything supported by [RCTConvert](https://github.com/facebook/react-native/blob/master/React/Base/RCTConvert.m).

* `cancelSignature()` -- [Abort the transaction](http://www.payworks.mpymnt.com/node/100).

#### Events
Events are emitted by NativeAppEventEmitter under the name `PayworksTransactionEvent`. During the transaction, the response payload contains a _details_ key.  If an action is required (e.g. signature), the _action_ key will be populated.

#### Example code snippet
```Javascript
import ReactNativePayworks from 'react-native-payworks';
import { NativeAppEventEmitter } from 'react-native';

// Initiate a transaction on the card reader.
ReactNativePayworks.transaction({
  merchantIdentifier: "myMerchantId",
  merchantSecretKey: "myMerchantKey",
  chargeWithAmount: 10,
  currency: 22, //USD
  optionals: {
    subject: "My purchase",
    customIdentifier: "purchase_id_123",
    applicationFee: 0.99,
    metadata: {
      customField1: "test1",
      customField2: "test2",
    }
  }
}).then(
  (transaction) =>{
    console.log("PayworksNative transaction completed:" + JSON.stringify(transaction));
  });

componentWillMount() {
  // Listen for events from the card reader.
  this.payworksEventSub = NativeAppEventEmitter.addListener(
    'PayworksTransactionEvent',
    (data) => {
      if (data.details) {
        console.log("PayworksNative ongoing transaction details: " + JSON.stringify(data.details));
      }
      else if (data.action && data.action === "MPTransactionActionCustomerSignature") {
        console.log("Capture signature now.");
        ReactNativePayworks.submitSignature(capturedSignatureImage); // you supply capturedSignatureImage
      }
    }
  );
}

componentWillUnmount() {
  this.payworksEventSub.remove();
}
```

## Example
The `example/` directory has a sample project using the ReactNativePayworks library.

* Install npm dependencies ```npm install```
* Install React Native CLI globally ```sudo npm install -g react-native-cli```
* ```react-native link```

#### iOS dependencies
* Xcode
* Install Cocoapods ```sudo gem install cocoapods```
* Install pods ```cd example/ios && pod install && cd ../..```
* Open `example/ios/RNPDemo.xcworkspace` in Xcode.
* Add the necessary protocols to the Xcode project ([Payworks instructions](http://www.payworks.mpymnt.com/node/101)).
* Build and run on a real iOS device (card reader should be paired with the iDevice).


#### Android Dependencies
* ...

## ToDo
* Payworks iOS library is built without Bitcode, requiring the RN app to be built without it.
* Android support
* Tests
