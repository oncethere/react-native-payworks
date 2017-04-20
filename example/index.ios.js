/**
 * React Native integration Demo using PayworksNative library
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TouchableHighlight,
  NativeAppEventEmitter
} from 'react-native';
import styles from './style';
import ReactNativePayworks from 'react-native-payworks';
import Sketch from 'react-native-sketch';

class RNPDemo extends Component {
  constructor(props) {
    super(props);

    this.state = {
      details: [],
      processing: false,
      encodedSignature: null,
      showSignature: false
    };

    this.onSave = this.onSave.bind(this);
    this.onUpdate = this.onUpdate.bind(this);
    this.payNowClick = this.payNowClick.bind(this);
    this.cancelTransaction = this.cancelTransaction.bind(this);
  }

  componentWillMount() {
    this.payworksEventSub = NativeAppEventEmitter.addListener(
      'PayworksTransactionEvent',
      (data) => {
        if (data.details && data.details.information) {
          let details = [];
          for (let i=0; i<data.details.information.length; i++) {
            details.push(
              <Text style={styles.instructions} key={i}>
                {data.details.information[i]}
              </Text>
            );
          }
          this.setState({details});
        }
        else if (data.action && data.action === "MPTransactionActionCustomerSignature") {
          console.log("PayworksNative action:" + JSON.stringify(data.action));
          this.setState( {showSignature: true} );
        }
      }
    );
  }

  componentWillUnmount() {
    this.payworksEventSub.remove();
  }

  onSave() {  //Sketch
    if (!this.state.encodedSignature) {
      return;
    }
    this.sketch.saveImage(this.state.encodedSignature)
      .then((data) => {
        console.log(data);
        this.sketch.clear();
        ReactNativePayworks.submitSignature(data.path);
        this.setState( {showSignature: false} );
      })
      .catch((error) => console.log(error));
  }

  onUpdate(base64Image) { // Sketch
    this.setState({ encodedSignature: base64Image });
  }

  payNowClick() {
    if(this.state.processing) {
      return;
    }
    this.setState({ processing: true });
    ReactNativePayworks.transaction({
      providerMode: 2, // Test
      merchantIdentifier: "ff4487b8-f820-4204-a304-4fb96dc94016",
      merchantSecretKey: "5Hchy5Ws6Dn5xUiqJH7Q1VoPdIT3FTw9",
      chargeWithAmount: 10,
      currency: 22,
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
        this.setState({ processing: false });
        console.log("PayworksNative transaction:" + JSON.stringify(transaction));
      });
  }

  cancelTransaction() {
    if(!this.state.processing) {
      return;
    }
    ReactNativePayworks.abortTransaction().then(
      (response) =>{
        this.setState({ processing: false });
        console.log("PayworksNative transaction cancel status " + JSON.stringify(response));
      });
  }

  render() {
    let buttonStyle = this.state.processing? styles.buttonDisabled : null;
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          React Native Payworks Integration Demo
        </Text>
        <View>
          {this.state.details}
        </View>
        { !this.state.processing ?
          <TouchableHighlight
            style={[styles.button, buttonStyle]}
            onPress={this.payNowClick}
            underlayColor="#f1f1f1">
            <Text style={styles.buttonText}>Pay Now</Text>
          </TouchableHighlight>
          :
          <TouchableHighlight
            style={[styles.button, buttonStyle]}
            onPress={this.cancelTransaction}
            underlayColor="#f1f1f1">
            <Text style={styles.buttonText}>Cancel Transaction</Text>
          </TouchableHighlight>
        }

        {this.renderSignature(this.state.showSignature)}
      </View>
    );
  }

  renderSignature(showSig) {
    if (showSig) {
      return (
        <View>
          <Sketch
            fillColor="#f5f5f5"
            strokeColor="#111111"
            strokeThickness={2}
            onUpdate={this.onUpdate}
            ref={(sketch) => { this.sketch = sketch; }}
            style={styles.signature}
          />

          <TouchableHighlight
            style={[styles.button]}
            onPress={this.onSave}
            underlayColor="#f1f1f1">
            <Text style={styles.buttonText}>Save Signature</Text>
          </TouchableHighlight>
        </View>
      )
    }
  }

}

AppRegistry.registerComponent('RNPDemo', () => RNPDemo);
