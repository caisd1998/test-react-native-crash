import React, { Component } from 'react';
import { View, Button } from 'react-native';
import { Client } from 'bugsnag-react-native';
const bugsnag = new Client("b0166c69090102f6b952a327feaff3de");

export default class MyApp extends Component {
  render() {
    return (
      <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
        <Button
          onPress={()=> {
            throw new Error('This is a test javascript crash!');
          }}
          title="JS CRASH"
        />
        <Button
          onPress={()=> {
            bugsnag.notify(new Error("Test error"));
          }}
          title="Notify bugsnag"
        />
      </View>
    );
  }
}