//
//  LogHandler.h
//  LuLu
//
//  Created by Winicius Allan on 09/08/24.
//  Copyright © 2024 Objective-See. All rights reserved.
//

#ifndef LogHandler_h
#define LogHandler_h

@import OSLog;
@import Foundation;

typedef NS_ENUM(NSUInteger, LogLevel) {
    LOG_INFO,
    LOG_DEBUG,
    LOG_ERROR
};

@protocol LogHandler <NSObject>

/* METHODS */

-(void)logDebug;

-(void)logInfo;

-(void)logError;

-(void)commitLog:(LogLevel)level;
    
@end

#endif
