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
            errorInPromise()
              .then(r => console.log(`.then(${r})`));
          }}
          title="Unhandled Error in Promise"
        />
        <Button
          onPress={()=> {
            Alert.alert("Not Working");
            rejectionInPromise()
              .then(r => console.log(`.then(${r})`))
              .catch(bugsnag.notify);
          }}
          title="Handled Rejection in Promise (Not Working)"
        />
        <Button
          onPress={()=> {
            Alert.alert("Notified");
            rejectionInPromise()
              .then(r => console.log(`.then(${r})`))
              .catch(e => {
                if (e instanceof Error) {
                  bugsnag.notify(e);
                } else if (typeof e === "string") {
                  bugsnag.notify(new Error(e));
                } else {
                  console.warn("Can't notify bugsnag with type " + typeof e);
                }
              });
          }}
          title="Handled Rejection in Promise"
        />
        <Button
          onPress={()=> {
            Alert.alert("Notified");
            errorInPromise()
              .then(r => console.log(`.then(${r})`))
              .catch(bugsnag.notify);
          }}
          title="Handled Error in Promise"
        />
      </View>
    );
  }
}

function rejectionInPromise() {
  return new Promise((resolve, reject) => {
    reject("test reject");
  });
}

function errorInPromise() {
  return new Promise((resolve, reject) => {
    throw new Error("throw error in Promise");
  });
}