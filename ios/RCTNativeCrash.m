//
//  RCTNativeCrash.m
//  MyApp
//
//  Created by Samuel Cai on 2020/1/8.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "RCTNativeCrash.h"

@implementation RCTNativeCrash

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(tryCrash) {
  NSString *name = @"Native Crash";
  NSString *message = @"Try Crash";
  @throw [[NSException alloc] initWithName:name reason:message userInfo:nil];
}

@end
