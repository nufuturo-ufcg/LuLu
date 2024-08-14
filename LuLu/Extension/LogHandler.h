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

@interface LogHandler : NSObject
{
    
}

/* PROPERTIES */

/* METHODS */

-(void)logDebug:(NSDictionary*)infos;

-(void)logInfo:(NSDictionary*)infos;

-(void)logError:(NSDictionary*)infos;

// -(void)commitLog:(bool)partial(NSDictionary*)infos;
    

#endif /* LogHandler_h */
