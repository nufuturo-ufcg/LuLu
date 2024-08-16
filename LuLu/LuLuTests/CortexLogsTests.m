//
//  CortexLogsTests.m
//  LuLuTests
//
//  Created by ec2-user on 16/08/2024.
//  Copyright © 2024 Objective-See. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface CortexLogsTests : XCTestCase

@end

@implementation CortexLogsTests

// Método auxiliar para simular o mapeamento do CSV para JSON
- (NSDictionary *)mapCSVLineToJSON:(NSString *)csvLine {
    NSArray *fields = [csvLine componentsSeparatedByString:@"\t"];

    // Exemplo de mapeamento.
    NSString *key = fields[0];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *path = fields[1];
    NSString *name = fields[2];
    NSString *endpointAddr = fields[4];
    NSString *endpointPort = fields[6];

    return @{
        key: @[
            @{
                @"key": key,
                @"uuid": uuid,
                @"path": path,
                @"name": name,
                @"endpointAddr": endpointAddr,
                @"endpointPort": endpointPort,
                @"isEndpointAddrRegex": @"0",
                @"type": @"1",
                @"scope": @"0",
                @"action": @"1",
                @"csInfo": @{
                    @"signatureIdentifier": @""
                }
            }
        ]
    };
}

// Teste para validar o mapeamento da chave 'key'
- (void)testKeyMapping {
    NSString *csvLine = @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\t/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\tQuickTime Player\t64465\t142.250.218.74\toptimizationguide-pa.googleapis.com\t443\t1\tTRUE";

    NSDictionary *json = [self mapCSVLineToJSON:csvLine];
    NSString *expectedKey = @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player";
    
    XCTAssertTrue([json objectForKey:expectedKey] != nil, @"Key should be mapped correctly.");
}

// Teste para validar o mapeamento de UUID
- (void)testUUIDMapping {
    NSString *csvLine = @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\t/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\tQuickTime Player\t64465\t142.250.218.74\toptimizationguide-pa.googleapis.com\t443\t1\tTRUE";

    NSDictionary *json = [self mapCSVLineToJSON:csvLine];
    NSString *key = @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player";
    NSString *uuid = json[key][0][@"uuid"];
    
    NSUUID *testUUID = [[NSUUID alloc] initWithUUIDString:uuid];
    XCTAssertNotNil(testUUID, @"UUID should be valid and correctly formatted.");
}

// Teste para validar o mapeamento de endereço IP e porta
- (void)testEndpointMapping {
    NSString *csvLine = @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\t/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\tQuickTime Player\t64465\t142.250.218.74\toptimizationguide-pa.googleapis.com\t443\t1\tTRUE";

    NSDictionary *json = [self mapCSVLineToJSON:csvLine];
    NSString *key = @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player";

    NSString *expectedAddr = @"142.250.218.74";
    NSString *expectedPort = @"443";
    
    XCTAssertEqualObjects(json[key][0][@"endpointAddr"], expectedAddr, @"Endpoint address should be mapped correctly.");
    XCTAssertEqualObjects(json[key][0][@"endpointPort"], expectedPort, @"Endpoint port should be mapped correctly.");
}

// Teste para validar a presença do campo 'csInfo'
- (void)testCsInfoMapping {
    NSString *csvLine = @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\t/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\tQuickTime Player\t64465\t142.250.218.74\toptimizationguide-pa.googleapis.com\t443\t1\tTRUE";

    NSDictionary *json = [self mapCSVLineToJSON:csvLine];
    NSString *key = @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player";
    NSDictionary *csInfo = json[key][0][@"csInfo"];

    XCTAssertNotNil(csInfo, @"csInfo should be present in the JSON.");
    XCTAssertEqualObjects(csInfo[@"signatureIdentifier"], @"", @"signatureIdentifier should be correctly mapped.");
}

// Teste para validar que todos os atributos obrigatórios estão presentes
- (void)testMandatoryAttributes {
    NSString *csvLine = @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\t/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\tQuickTime Player\t64465\t142.250.218.74\toptimizationguide-pa.googleapis.com\t443\t1\tTRUE";

    NSDictionary *json = [self mapCSVLineToJSON:csvLine];
    NSString *key = @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player";

    NSDictionary *entry = json[key][0];
    NSArray *mandatoryKeys = @[@"key", @"uuid", @"path", @"name", @"endpointAddr", @"endpointPort", @"isEndpointAddrRegex", @"type", @"scope", @"action", @"csInfo"];
    
    for (NSString *mandKey in mandatoryKeys) {
        XCTAssertNotNil(entry[mandKey], @"Mandatory attribute %@ should be present in the JSON.", mandKey);
    }
}

@end
