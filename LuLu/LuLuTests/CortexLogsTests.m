//
//  File: CortexLogsTests.m
//  Project: App Firewall (nufuturo.lulu)
//  Description: Validates rule structure created from cortex logs
//
//  Created by com.nufuturo.lulu
//  Copyright © 2024 Objective-See. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface CortexLogsTests : XCTestCase

@end

@implementation CortexLogsTests


- (NSDictionary *)mapCSVLineToJSON:(NSString *)csvLine {
    NSArray *fields = [csvLine componentsSeparatedByString:@","];
    NSString *key = fields[0];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *path = fields[0];
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

- (NSDictionary *)mapCSVLineToJSON:(NSString *)csvLine withHeaders:(NSArray<NSString *> *)headers {
    NSArray *fields = [csvLine componentsSeparatedByString:@","];
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    for (NSUInteger i = 0; i < headers.count; i++) {
        NSString *key = headers[i];
        NSString *value = (i < fields.count) ? fields[i] : @"";
        json[key] = value;
    }
    
    return [json copy];
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

- (NSArray<NSString *> *)readCSVFromFilePath:(NSString *)filePath {
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        XCTFail(@"Failed to read CSV file: %@", error.localizedDescription);
        return nil;
    }

    NSArray *rows = [fileContents componentsSeparatedByString:@"\n"];
    return rows;
}

- (id)readJSONFromFilePath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        id resultData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error == nil) {
            return resultData;
        } else {
            XCTFail(@"Failed to parse JSON file: %@", error.localizedDescription);
        }
    } else {
        XCTFail(@"JSON file does not exist at path: %@", filePath);
    }
    
    return nil;
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

            NSString *actualUUID = actualEntry[@"uuid"];
            NSUUID *testUUID = [[NSUUID alloc] initWithUUIDString:actualUUID];
            XCTAssertNotNil(testUUID, @"UUID should be valid and correctly formatted.");
            
            for (NSString *field in expectedEntry) {
                if (![field isEqualToString:@"uuid"]) {
                    XCTAssertEqualObjects(expectedEntry[field], actualEntry[field], @"Field %@ for key %@ should match.", field, key);
                }
            }
        }
    }
}

- (void)testMultipleCSVLinesMapping {
    
    NSString *csvFilePath = @"/Users/ec2-user/Documents/Nufuturo/LuLu/LuLu/LuLuTests/Sample-data/100-sample-cortex-logs.csv";
    NSString *jsonFilePath = @"/Users/ec2-user/Documents/Nufuturo/LuLu/LuLu/LuLuTests/Sample-data/100-sample-rules.json";

    NSArray<NSString *> *csvLines = [self readCSVFromFilePath:csvFilePath];
    NSDictionary *expectedJSON = [self readJSONFromFilePath:jsonFilePath];

    if (csvLines && expectedJSON) {
        [self validateMappingWithCSVLines:csvLines expectedJSON:expectedJSON];
    }
}

@end

