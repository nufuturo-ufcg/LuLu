//
//  file: RemoteRulesController.h
//  project: LuLu (launch daemon)
//  description: handles remote calls to LuLu Server
//
//

#ifndef RemoteRulesController_h
#define RemoteRulesController_h

@import OSLog;

@interface RemoteRulesController : NSObject
{
    
}

/* METHODS*/

- (NSDictionary*) getDefaultRules;

- (void) logNotMatchedAccessWithFlowUUID:(NSString*)flowUUID processName:(NSString*)processName;

@end

#endif /* RemoteRulesController_h*/
