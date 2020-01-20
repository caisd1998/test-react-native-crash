import React, { Component } from 'react';
import { View, Button, Alert } from 'react-native';
import { Client } from 'bugsnag-react-native';

import {NativeModules} from "react-native";

const NativeCrash = NativeModules.NativeCrash;
const bugsnag = new Client("6053f051594a528183b9619ed88779d5");

export default class MyApp extends Component {
  render() {
    return (
      <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
        <Button
          onPress={()=> {
            throw new Error('This is a test javascript crash!');
          }}
          title="Javascript Crash"
        />
        <Button
          onPress={()=> {
            NativeCrash.tryCrash();
          }}
          title="Native Crash"
        />
        <Button
          onPress={()=> {
            bugsnag.notify(new Error("Test handled error"));
            Alert.alert("Notified");
          }}
          title="Notify Bugsnag Handled Error"
        />
        <Button
          onPress={()=> {
            Alert.alert("Notified");
            rejectionInPromise()
              .then(r => console.log(`.then(${r})`));
          }}
          title="Unhandled Rejection in Promise"
        />
        <Button
          onPress={()=> {
            Alert.alert("Notified");
            rejectionInPromise()
              .then(r => console.log(`.then(${r})`))
              .catch(bugsnag.notify);
          }}
          title="Handled Rejection in Promise"
        />
        <Button
          onPress={()=> {
            Alert.alert("Notified");
            NativeCrash.findEvents()
              .then(r => console.log(`.then(${r})`));
          }}
          title="Unhandled Rejection in Native Module"
        />
      </View>
    );
  }
}

function rejectionInPromise() {
  return new Promise((resolve, reject) => {
    // For debugging purposes and selective error catching, it is useful to make reason an instanceof Error
    // Also Bugsnag can't handle other type of reason
    reject(new Error("test reject"));
  });
}