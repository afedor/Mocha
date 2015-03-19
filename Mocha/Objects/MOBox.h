//
//  MOBox.h
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>


@class Mocha;


/*!
 * @class MOBox
 * @abstract A boxed Objective-C object
 */
@interface MOBox : NSObject

/*!
 * @property representedObject
 * @abstract The boxed Objective-C object
 * 
 * @result An object
 */
@property (strong) id representedObject;

/*!
 * @property JSObject
 * @abstract The JSObject representation of the box
 * 
 * @result A JSObjectRef value
 */
@property (nonatomic) JSObjectRef JSObject;

/*!
 * @property runtime
 * @abstract The runtime for the object
 * 
 * @result A Mocha object
 */
@property (weak) Mocha *runtime;

/*!
 * @property lastAccessDate
 * @abstract The last time the JSObject was accessed
 *
 * @result A date
 */
@property NSDate *lastAccessDate;

/*! Protects the JSObject from being garbage collected by the JS runtime. */
- (void) protectObject;

/*! Un-protects the JSObject so that it can be garbage collected by the JS runtime. */
- (void) unprotectObject;

@end
