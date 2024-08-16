//
//  RuleIdTests.m
//  LuLuTests
//
//  Created by ec2-user on 12/08/2024.
//  Copyright © 2024 Objective-See. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Rule.h"
#import "consts.h"

@interface RuleIdTests : XCTestCase

@end

@implementation RuleIdTests

- (void)testGenerateRuleIdALLOW {
    NSDictionary *info = @{
        KEY_CS_INFO: @{KEY_CS_ID: @"com.apple.stocks"},
        KEY_ENDPOINT_ADDR: VALUE_ANY,
        KEY_ENDPOINT_PORT: VALUE_ANY,
        KEY_TYPE: @RULE_TYPE_USER,
        KEY_ACTION: @RULE_STATE_ALLOW
    };
    
    Rule *rule = [[Rule alloc] init:info];
    
    NSString *generatedID = [rule generateID];
    
    NSString *expectedID = @"com.apple.stocks-any-any-3-1";
    
    XCTAssertEqualObjects(generatedID, expectedID);
}

- (void)testGenerateRuleIdBLOCK {
    NSDictionary *info = @{
        KEY_CS_INFO: @{KEY_CS_ID: @"com.apple.Chess"},
        KEY_ENDPOINT_ADDR: VALUE_ANY,
        KEY_ENDPOINT_PORT: VALUE_ANY,
        KEY_TYPE: @RULE_TYPE_USER,
        KEY_ACTION: @RULE_STATE_BLOCK
    };
    
    Rule *rule = [[Rule alloc] init:info];
    
    NSString *generatedID = [rule generateID];
    
    NSString *expectedID = @"com.apple.Chess-any-any-3-0";
    
    XCTAssertEqualObjects(generatedID, expectedID);
}

- (void)testGenerateRuleIdAPPLE {
    NSDictionary *info = @{
        KEY_CS_INFO: @{KEY_CS_ID: @"com.apple.geod"},
        KEY_ENDPOINT_ADDR: VALUE_ANY,
        KEY_ENDPOINT_PORT: VALUE_ANY,
        KEY_TYPE: @RULE_TYPE_APPLE,
        KEY_ACTION: @RULE_STATE_ALLOW
    };
    
    Rule *rule = [[Rule alloc] init:info];
    
    NSString *generatedID = [rule generateID];
    
    NSString *expectedID = @"com.apple.geod-any-any-1-1";
    
    XCTAssertEqualObjects(generatedID, expectedID);
}

- (void)testGenerateRuleIdADDR {
    NSDictionary *info = @{
        KEY_CS_INFO: @{KEY_CS_ID: @"com.apple.Safari"},
        KEY_ENDPOINT_ADDR: @"open.spotify.com",
        KEY_ENDPOINT_PORT: VALUE_ANY,
        KEY_TYPE: @RULE_TYPE_APPLE,
        KEY_ACTION: @RULE_STATE_ALLOW
    };
    
    Rule *rule = [[Rule alloc] init:info];
    
    NSString *generatedID = [rule generateID];
    
    NSString *expectedID = @"com.apple.Safari-open.spotify.com-any-1-1";
    
    XCTAssertEqualObjects(generatedID, expectedID);
}
@end
