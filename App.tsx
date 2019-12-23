import React, { Component } from 'react';
import { Text, View, Button } from 'react-native';

export default class MyApp extends Component {
  render() {
    return (
      <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
        <Button title="JS CRASH" onPress={()=> {throw new Error("JS Error")}}></Button>
        <Button title="NATIVE CRASH" onPress={()=> {console.error("error")}}></Button>
      </View>
    );
  }
}