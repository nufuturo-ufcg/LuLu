//
//  CortexLogsTestsII.m
//  LuLuTests
//
//  Created by ec2-user on 16/08/2024.
//  Copyright © 2024 Objective-See. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface CortexLogsTestsII : XCTestCase

@end

@implementation CortexLogsTestsII

// Método auxiliar para simular o mapeamento do CSV para JSON
- (NSDictionary *)mapCSVLineToJSON:(NSString *)csvLine {
    NSArray *fields = [csvLine componentsSeparatedByString:@"\t"];

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

// Teste para verificar se a chave está sendo mapeada corretamente no JSON
- (void)testKeyMappingWithCSV:(NSString *)csvLine expectedJSON:(NSDictionary *)expectedJSON {
    NSDictionary *json = [self mapCSVLineToJSON:csvLine];
    NSString *expectedKey = expectedJSON.allKeys.firstObject;
    
    XCTAssertTrue([json objectForKey:expectedKey] != nil, @"Key should be mapped correctly.");
}

// Teste para verificar se o UUID gerado no mapeamento é válido
- (void)testUUIDMappingWithCSV:(NSString *)csvLine expectedJSON:(NSDictionary *)expectedJSON {
    NSDictionary *json = [self mapCSVLineToJSON:csvLine];
    NSString *key = expectedJSON.allKeys.firstObject;
    NSString *uuid = json[key][0][@"uuid"];
    
    NSUUID *testUUID = [[NSUUID alloc] initWithUUIDString:uuid];
    XCTAssertNotNil(testUUID, @"UUID should be valid and correctly formatted.");
}

// Teste para verificar se o endereço IP e a porta estão sendo mapeados corretamente
- (void)testEndpointMappingWithCSV:(NSString *)csvLine expectedJSON:(NSDictionary *)expectedJSON {
    NSDictionary *json = [self mapCSVLineToJSON:csvLine];
    NSString *key = expectedJSON.allKeys.firstObject;

    NSString *expectedAddr = expectedJSON[key][0][@"endpointAddr"];
    NSString *expectedPort = expectedJSON[key][0][@"endpointPort"];
    
    XCTAssertEqualObjects(json[key][0][@"endpointAddr"], expectedAddr, @"Endpoint address should be mapped correctly.");
    XCTAssertEqualObjects(json[key][0][@"endpointPort"], expectedPort, @"Endpoint port should be mapped correctly.");
}

// Teste para verificar se o campo csInfo está presente e mapeado corretamente
- (void)testCsInfoMappingWithCSV:(NSString *)csvLine expectedJSON:(NSDictionary *)expectedJSON {
    NSDictionary *json = [self mapCSVLineToJSON:csvLine];
    NSString *key = expectedJSON.allKeys.firstObject;
    NSDictionary *csInfo = json[key][0][@"csInfo"];

    XCTAssertNotNil(csInfo, @"csInfo should be present in the JSON.");
    XCTAssertEqualObjects(csInfo[@"signatureIdentifier"], expectedJSON[key][0][@"csInfo"][@"signatureIdentifier"], @"signatureIdentifier should be correctly mapped.");
}

// Teste para verificar se todos os atributos obrigatórios estão presentes no JSON
- (void)testMandatoryAttributesWithCSV:(NSString *)csvLine expectedJSON:(NSDictionary *)expectedJSON {
    NSDictionary *json = [self mapCSVLineToJSON:csvLine];
    NSString *key = expectedJSON.allKeys.firstObject;

    NSDictionary *entry = json[key][0];
    NSArray *mandatoryKeys = @[@"key", @"uuid", @"path", @"name", @"endpointAddr", @"endpointPort", @"isEndpointAddrRegex", @"type", @"scope", @"action", @"csInfo"];
    
    for (NSString *mandKey in mandatoryKeys) {
        XCTAssertNotNil(entry[mandKey], @"Mandatory attribute %@ should be present in the JSON.", mandKey);
    }
}

// Teste integrado para usar as funções acima
- (void)testMapping {
    NSString *csvLine = @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\t/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\tQuickTime Player\t64465\t142.250.218.74\toptimizationguide-pa.googleapis.com\t443\t1\tTRUE";

    NSDictionary *expectedJSON = @{
        @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player": @[
            @{
                @"key": @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player",
                @"uuid": @"550e8400-e29b-41d4-a716-446655440000", // Este UUID é apenas um placeholder
                @"path": @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player",
                @"name": @"QuickTime Player",
                @"endpointAddr": @"142.250.218.74",
                @"endpointPort": @"443",
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

    // Chama os testes com as funções acima
    [self testKeyMappingWithCSV:csvLine expectedJSON:expectedJSON];
    [self testUUIDMappingWithCSV:csvLine expectedJSON:expectedJSON];
    [self testEndpointMappingWithCSV:csvLine expectedJSON:expectedJSON];
    [self testCsInfoMappingWithCSV:csvLine expectedJSON:expectedJSON];
    [self testMandatoryAttributesWithCSV:csvLine expectedJSON:expectedJSON];
}

- (NSDictionary *)mapCSVLinesToJSON:(NSArray<NSString *> *)csvLines {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    for (NSString *csvLine in csvLines) {
        NSDictionary *mappedLine = [self mapCSVLineToJSON:csvLine];
        NSString *key = mappedLine.allKeys.firstObject;

        if (result[key]) {
            NSMutableArray *existingValues = [result[key] mutableCopy];
            [existingValues addObjectsFromArray:mappedLine[key]];
            result[key] = [existingValues copy];
        } else {
            result[key] = mappedLine[key];
        }
    }

    return [result copy];
}

- (void)validateMappingWithCSVLines:(NSArray<NSString *> *)csvLines expectedJSON:(NSDictionary *)expectedJSON {
    NSDictionary *json = [self mapCSVLinesToJSON:csvLines];

    for (NSString *key in expectedJSON) {
        XCTAssertNotNil(json[key], @"Key %@ should be present in the JSON.", key);

        NSArray *expectedEntries = expectedJSON[key];
        NSArray *actualEntries = json[key];

        XCTAssertEqual(expectedEntries.count, actualEntries.count, @"Number of entries for key %@ should match.", key);

        for (NSUInteger i = 0; i < expectedEntries.count; i++) {
            NSDictionary *expectedEntry = expectedEntries[i];
            NSDictionary *actualEntry = actualEntries[i];

            for (NSString *field in expectedEntry) {
                if ([field isEqualToString:@"uuid"]) {
                    NSUUID *testUUID = [[NSUUID alloc] initWithUUIDString:actualEntry[field]];
                    XCTAssertNotNil(testUUID, @"UUID should be valid and correctly formatted.");
                } else {
                    XCTAssertEqualObjects(expectedEntry[field], actualEntry[field], @"Field %@ for key %@ should match.", field, key);
                }
            }
        }
    }
}

- (void)testMultipleCSVLinesMapping {
    NSArray<NSString *> *csvLines = @[
        @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\t/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player\tQuickTime Player\t64465\t142.250.218.74\toptimizationguide-pa.googleapis.com\t443\t1\tTRUE",
        @"/Applications/Safari.app/Contents/MacOS/Safari\t/Applications/Safari.app/Contents/MacOS/Safari\tSafari\t64467\t142.250.218.74\tapple.com\t443\t1\tTRUE"
    ];

    NSDictionary *expectedJSON = @{
        @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player": @[
            @{
                @"key": @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player",
                @"uuid": @"<UUID1>",
                @"path": @"/System/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player",
                @"name": @"QuickTime Player",
                @"endpointAddr": @"142.250.218.74",
                @"endpointPort": @"443",
                @"isEndpointAddrRegex": @"0",
                @"type": @"1",
                @"scope": @"0",
                @"action": @"1",
                @"csInfo": @{
                    @"signatureIdentifier": @""
                }
            }
        ],
        @"/Applications/Safari.app/Contents/MacOS/Safari": @[
            @{
                @"key": @"/Applications/Safari.app/Contents/MacOS/Safari",
                @"uuid": @"<UUID2>", 
                @"path": @"/Applications/Safari.app/Contents/MacOS/Safari",
                @"name": @"Safari",
                @"endpointAddr": @"142.250.218.74",
                @"endpointPort": @"443",
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

    [self validateMappingWithCSVLines:csvLines expectedJSON:expectedJSON];
}

@end
