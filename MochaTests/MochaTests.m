//
//  MochaTests.m
//  MochaTests
//
//  Created by Adam Fedor on 2/19/15.
//  Copyright (c) 2015 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "Mocha.h"

@interface MochaTests : XCTestCase

@end

@implementation MochaTests
{
    Mocha *runtime;
    NSURL *testScriptURL;
}

- (void)setUp {
    [super setUp];
    testScriptURL = [[NSBundle bundleForClass: [self class]] URLForResource:@"Tests" withExtension:@""];
    runtime = [[Mocha alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark Simple Scripts
- (void)testCallFunctionWithName_WithSimpleAdd
{
    [runtime evalString: @"function add() { return 1 + 1}"];
    
    id result = [runtime callFunctionWithName: @"add"];
    XCTAssertTrue([result isEqualTo: @(2)], @"Adding doesnt work");
}

- (void)testCallFunctionWithName_WithSimpleAddMultipleTimes
{
    [runtime evalString: @"function add() { return 1 + 1}"];
    
    id result;
    for (NSInteger i = 0; i < 1000; i++) {
        result = [runtime callFunctionWithName: @"add"];
    }
    XCTAssertTrue([result isEqualTo: @(2)], @"Adding multiple doesnt work");
}

- (void)testCallFunctionWithName_WithObjectFunction
{
    [runtime evalString: @"function myfunc() { var dict = NSMutableDictionary.dictionary(); \
     dict.setObject_forKey_(\"foobar\", \"string\"); return 2;}"];
    
    id result = [runtime callFunctionWithName: @"myfunc"];
    XCTAssertTrue([result isEqualTo: @(2)], @"Myfunc doesnt work");
}

- (void)testCallFunctionWithName_WithObjectFunctionMultipleTimes
{
    [runtime evalString: @"function myfunc() { var dict = NSMutableDictionary.dictionary(); \
     dict.setObject_forKey_(\"foobar\", \"string\"); return 2;}"];
    
    id result;
    for (NSInteger i = 0; i < 1000; i++) {
        result = [runtime callFunctionWithName: @"myfunc"];
    }
    XCTAssertTrue([result isEqualTo: @(2)], @"Myfunc multiple doesnt work");
}

- (void)testCallFunctionWithName_WithIdenticalProperties_CanChangeEachPropertySeperately
{
    [runtime evalString: @"function myfunc() { \
     var dict1 = NSMutableDictionary.dictionary(); \
     var dict2 = NSMutableDictionary.dictionary(); \
     dict1.setObject_forKey_(\"foobar\", \"string\"); \
     print(\"dict1 is \" + dict1); \
     print(\"dict2 is \" + dict2); \
     return dict2.count;}"];
    
    id result = [runtime callFunctionWithName: @"myfunc"];
    XCTAssertTrue([result isEqualTo: @(0)], @"Setting mutable dictionary doesnt work");
}

#pragma mark Stored Scripts

- (void)testUsingCoreGraphicsScript_ShouldRun {
    NSURL *URL = [testScriptURL URLByAppendingPathComponent: @"CoreGraphics.js"];
    NSError *error = nil;
    NSString *testScript = [NSString stringWithContentsOfURL:URL usedEncoding:NULL error:&error];
    
    XCTAssertNotNil(testScript, @"Error loading test script: %@", error);
    
    [runtime evalString:testScript];
    
    NSArray *result = [runtime callFunctionWithName:@"main"];
    XCTAssertTrue([result[0] boolValue], @"%@", result[1]);
    result = nil;
}

#pragma mark Memory Allocation
- (void)test_10_UsingMemoryAllocationScript_ShouldRun {
    NSURL *URL = [testScriptURL URLByAppendingPathComponent: @"JSMemoryAllocation.js"];
    NSError *error = nil;
    NSString *testScript = [NSString stringWithContentsOfURL:URL usedEncoding:NULL error:&error];
    
    XCTAssertNotNil(testScript, @"Error loading test script: %@", error);
    
    [runtime evalString:testScript];
    
    NSArray *result = [runtime callFunctionWithName:@"main" withArgumentsInArray: @[@(10)]];
    XCTAssertTrue([result[0] boolValue], @"%@", result[1]);
}

- (void)test_11_UsingMemoryAllocationScript_ShouldRun {
    NSURL *URL = [testScriptURL URLByAppendingPathComponent: @"MemoryAllocation.js"];
    NSError *error = nil;
    NSString *testScript = [NSString stringWithContentsOfURL:URL usedEncoding:NULL error:&error];
    
    XCTAssertNotNil(testScript, @"Error loading test script: %@", error);
    
    [runtime evalString:testScript];
    
    NSArray *result = [runtime callFunctionWithName:@"main" withArgumentsInArray: @[@(10)]];
    XCTAssertTrue([result[0] boolValue], @"%@", result[1]);
}

- (void)test_12_UsingJSMemoryAllocationScript_WithMoreIterations_ShouldRunFast {
    NSURL *URL = [testScriptURL URLByAppendingPathComponent: @"JSMemoryAllocation.js"];
    NSError *error = nil;
    NSString *testScript = [NSString stringWithContentsOfURL:URL usedEncoding:NULL error:&error];
    
    XCTAssertNotNil(testScript, @"Error loading test script: %@", error);
    
    [runtime evalString:testScript];
    
    __block NSArray *result;
    [self measureBlock:^{
        result = [runtime callFunctionWithName:@"main" withArgumentsInArray: @[@(5000)]];
    }];
    XCTAssertTrue([result[0] boolValue], @"%@", result[1]);
}

- (void)test_13_UsingMemoryAllocationScript_WithMoreIterations_ShouldRunFast {
    NSURL *URL = [testScriptURL URLByAppendingPathComponent: @"MemoryAllocation.js"];
    NSError *error = nil;
    NSString *testScript = [NSString stringWithContentsOfURL:URL usedEncoding:NULL error:&error];
    
    XCTAssertNotNil(testScript, @"Error loading test script: %@", error);
    
    [runtime evalString:testScript];
    
    __block NSArray *result;
    [self measureBlock:^{
        result = [runtime callFunctionWithName:@"main" withArgumentsInArray: @[@(500)]];
    }];
    XCTAssertTrue([result[0] boolValue], @"%@", result[1]);
}

#pragma mark Garbage Collection
/* Takes ~.7 sec on a 2011 Mini  */
- (void)test_14_UsingJSMemoryAllocationScript_WithHugeNumberOfIterations_ShouldNotCrash {
    NSURL *URL = [testScriptURL URLByAppendingPathComponent: @"JSMemoryAllocation.js"];
    NSError *error = nil;
    NSString *testScript = [NSString stringWithContentsOfURL:URL usedEncoding:NULL error:&error];
    
    XCTAssertNotNil(testScript, @"Error loading test script: %@", error);
    
    [runtime evalString:testScript];
    
    NSArray *result;
    result = [runtime callFunctionWithName:@"main" withArgumentsInArray: @[@(100000)]];
    XCTAssertTrue([result[0] boolValue], @"%@", result[1]);
}

/* Unfortunately this will just crash if it doesn't work. Takes ~70 sec on a 2011 Mini  */
- (void)test_15_UsingMemoryAllocationScript_WithHugeNumberOfIterations_ShouldNotCrash {
    NSURL *URL = [testScriptURL URLByAppendingPathComponent: @"MemoryAllocation.js"];
    NSError *error = nil;
    NSString *testScript = [NSString stringWithContentsOfURL:URL usedEncoding:NULL error:&error];
    
    XCTAssertNotNil(testScript, @"Error loading test script: %@", error);
    
    [runtime evalString:testScript];
    
    NSArray *result;
    result = [runtime callFunctionWithName:@"main" withArgumentsInArray: @[@(100000)]];
    XCTAssertTrue([result[0] boolValue], @"%@", result[1]);
}

/* Unfortunately this will just crash if it doesn't work. Takes ~10 sec on a 2011 Mini  */
- (void)test_15_UsingGarbageCollect2Script_WithHugeNumberOfIterations_ShouldNotCrash {
    NSURL *URL = [testScriptURL URLByAppendingPathComponent: @"GarbageCollect2.js"];
    NSError *error = nil;
    NSString *testScript = [NSString stringWithContentsOfURL:URL usedEncoding:NULL error:&error];
    
    XCTAssertNotNil(testScript, @"Error loading test script: %@", error);
    [runtime evalString:testScript];
    
    XCTAssertTrue(1, @"GarbageCollect2 Test did not run");
}

@end
