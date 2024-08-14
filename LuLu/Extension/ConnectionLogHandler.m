//
//  ConnectionLogHandler.m
//  LuLu
//
//  Created by Winicius Allan on 12/08/24.
//  Copyright © 2024 Objective-See. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectionLogHandler.h"

extern os_log_t logHandle;

@implementation ConnectionLogHandler

/* Connection log category properties */
NSString* flowUUID = nil;

- (id)init {
    self = [super init];
    
    self.flowUUID = [[NSString alloc] init];
    self.remoteEndpoint = [[NWHostEndpoint alloc] init];
    self.socketFlow = [[NEFilterSocketFlow alloc] init];
    self.direction = -1;
    self.action = 0;
    
    return self;
}

- (void)logDebug:(NSDictionary *)infos {
}

- (void)logError:(NSDictionary *)infos {
}

- (void)logInfo:(NSDictionary *)infos {
    os_log_info(logHandle, "CATEGORY=connection, FLOW_ID=%{public}@, ENDPOINT=%{public}@, DIRECTION=%ld, PROTOCOL=%ld, ACTION=%d", self.flowUUID, self.remoteEndpoint, self.direction, (long)self.socketFlow.direction, self.action);
}

- (void)commitLog {
}

@end
