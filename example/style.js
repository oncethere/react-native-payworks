/**
 * Copyright OnceThere
 */

import { StyleSheet } from 'react-native';

export default StyleSheet.create( {
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
	button: {
		borderWidth: 0.5,
		borderRadius: 8,
    backgroundColor: 'blue',
		padding: 10,
	},
  buttonDisabled: {
    backgroundColor: 'grey',
  },
  buttonText: {
    color: 'white',
  },
  signature: {
    width: 200,
    height: 150, // Height needed; Default: 200px
  }
})
