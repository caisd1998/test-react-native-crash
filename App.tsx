import React, { Component } from 'react';
import { View, Button } from 'react-native';

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
            console.log("TODO");
          }}
          title="NATIVE CRASH"
        />
      </View>
    );
  }
}