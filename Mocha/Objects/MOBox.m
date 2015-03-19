//
//  MOBox.m
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOBox.h"
#import "MochaRuntime_Private.h"

@implementation MOBox
{
  BOOL objectIsProtected;
}

@synthesize representedObject=_representedObject;
@synthesize JSObject=_JSObject;
@synthesize runtime=_runtime;
@synthesize lastAccessDate=_lastAccessDate;

- (instancetype)init
{
  if ((self = [super init]) == nil)
    return nil;
  _lastAccessDate = [NSDate date];
  return self;
}

- (void)dealloc
{
  if (objectIsProtected)
    [self unprotectObject];
}

- (JSObjectRef)JSObject
{
  self.lastAccessDate = [NSDate date];
  return _JSObject;
}

- (void)protectObject
{
  NSAssert(objectIsProtected == NO, @"Trying to protect an MOBox object that is already protected");
  if ( self.runtime.context ) {
    JSValueProtect(self.runtime.context, _JSObject);
    objectIsProtected = YES;
  }
}

- (void)unprotectObject
{
  NSAssert(objectIsProtected, @"Trying to un-protect an MOBox object that is not protected");
  if ( self.runtime.context ) {
    objectIsProtected = NO;
    JSValueUnprotect(self.runtime.context, _JSObject);
  }
}

@end
