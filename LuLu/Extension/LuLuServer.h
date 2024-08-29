//
//  file: LuLuServer.h
//  project: LuLu (launch daemon)
//  description: handles remote calls to LuLu Server
//
//

#ifndef LuLuServer_h
#define LuLuServer_h

@import OSLog;

@interface LuLuServer : NSObject
{
    
}

/* METHODS*/

- (NSDictionary*) getDefaultRules;

- (void) logNewAccessWithFlowUUID:(NSString*)flowUUID processName:(NSString*)processName;

@end

#endif /* LuLuServer_h*/
