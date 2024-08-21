//
//  ConnectionLogHandler.m
//  LuLu
//
//  Created by Winicius Allan on 12/08/24.
//  Copyright © 2024 Objective-See. All rights reserved.
//

#import "consts.h"

#import <Foundation/Foundation.h>
#import "ConnectionLogHandler.h"

extern os_log_t logHandle;

@implementation ConnectionLogHandler

/* Connection log category properties */

- (id)init {
    self = [super init];
    
    self.flowUUID = [[NSString alloc] init];
    self.remoteEndpoint = [[NWHostEndpoint alloc] init];
    self.socketFlow = [[NEFilterSocketFlow alloc] init];
//    self.direction = -1;
    self.action = 0;
    
    return self;
}

- (void)logDebug {
    os_log_debug(logHandle, "LOGGING DEBUG");
}

- (void)logError {
    os_log_error(logHandle, "LOGGING ERROR");
}

- (void)logInfo {
    os_log_info(logHandle, "CATEGORY=connection, FLOW_ID=%{public}@, ENDPOINT=%{public}@, DIRECTION=%ld, PROTOCOL=%ld, ACTION=%d", self.flowUUID, self.remoteEndpoint, self.socketFlow.direction, (long)self.socketFlow.socketProtocol, (int)self.action);
}

- (void)append:(NSMutableDictionary*)dict {
    self.flowUUID = [dict[@"flowUUID"] stringValue];
    self.remoteEndpoint = dict[@"remoteEndpoint"];
    self.socketFlow = dict[@"socketFlow"];
    self.action = [dict[@"action"] intValue];
}

- (void)commitLog:(LogLevel)level {
    if (level == LOG_INFO) {
        [self logInfo];
    } 
    else if (level == LOG_DEBUG) {
        [self logDebug];
    } 
    else if (level == LOG_ERROR) {
        [self logError];
    }
}

@end
