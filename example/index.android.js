//
//  ReactNativePayworks
//
//  Copyright OnceThere. All rights reserved.
//  Created by Peace Chen on 2/27/2018.
//

/**
 * React Native integration Demo using PayworksNative library
 *
 * The Android implementation is untested and needs work
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
import ReactNativePayworks from 'react-native-payworks';
import styles from './style';

class ReactNativePayworks extends Component {
  constructor(props) {
    super(props);

    this.state = {
      details: [],
      processing: false,
      showSignature: false
    };

    this.payNowClick = this.payNowClick.bind(this);
  }

  componentWillMount() {
    this.payworksEventSub = NativeAppEventEmitter.addListener(
      'PayworksTransactionEvent',
      (data) => {
        if (data.details) {
          let details = [];
          for (let i=0; i<data.details.length; i++) {
            details.push(
              <Text style={styles.instructions} key={i}>
                {data.details[i]}
              </Text>
            );
          }
          this.setState({details});
        }
        else if (data.action) {
          //ToDo: signature
          console.log("PayworksNative action:" + JSON.stringify(data.action));
        }
      }
    );
  }

  componentWillUnmount() {
    this.payworksEventSub.remove();
  }

  payNowClick() {
    if(this.state.processing) {
      return;
    }
    this.setState({ processing: true });
    ReactNativePayworks.transaction({
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
        <TouchableHighlight
          style={[styles.button, buttonStyle]}
          onPress={this.payNowClick}
          underlayColor="#f1f1f1">
          <Text style={styles.buttonText}>Pay Now</Text>
        </TouchableHighlight>

        {this.renderSignature(this.state.showSignature)}
      </View>
    );
  }

  renderSignature(showSig) {
    if (showSig) {
      return (
        <Text>ToDo: Android signature pad</Text>
      )
    }
  }

}

AppRegistry.registerComponent('ReactNativePayworks', () => ReactNativePayworks);
