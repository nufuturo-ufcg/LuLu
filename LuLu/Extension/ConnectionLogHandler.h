//
//  ConnectionLogHandler.h
//  Extension
//
//  Created by Winicius Allan on 14/08/24.
//  Copyright © 2024 Objective-See. All rights reserved.
//

#import "LogHandler.h"

#ifndef ConnectionLogHandler_h
#define ConnectionLogHandler_h

@import OSLog;
@import Foundation;
@import NetworkExtension;

@interface ConnectionLogHandler : NSObject <LogHandler>
{
    
}

/* PROPERTIES */

@property(nonatomic, retain)NSString* flowUUID;

@property(nonatomic, retain)NWHostEndpoint* remoteEndpoint;

@property(nonatomic, retain)NEFilterSocketFlow* socketFlow;

@property(nonatomic, assign)long direction;

@property(nonatomic, assign)int action;

@end

#endif /* ConnectionLogHandler_h */
