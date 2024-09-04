//
//  file: RemoteRulesController.m
//  project: LuLu (launch daemon)
//  description: handles remote calls to LuLu Server
// 
//

#import "consts.h"

#import "Rule.h"
#import "Rules.h"
#import "Process.h"
#import "utilities.h"
#import "Preferences.h"
#import "RemoteRulesController.h"

//log handle
extern os_log_t logHandle;

@implementation RemoteRulesController

//
-(NSDictionary*)getDefaultRules {
    
    //defining the url to make the request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/default-user-rules", LULU_SERVER_URL]];
    
    //blocking the space for the response
    __block NSDictionary *result = nil;

    //request
    NSMutableURLRequest *request = nil;
    
    //wait semaphore
    dispatch_semaphore_t semaphore = 0;

    //init wait semaphore
    semaphore = dispatch_semaphore_create(0);
    
    //alloc/init request
    request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    //set method type
    [request setHTTPMethod:@"GET"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error)
    {
        os_log_debug(logHandle, "got response %lu", (long)((NSHTTPURLResponse *)response).statusCode);
        //sanity check(s)
        if ([self sanityChecksWithData:data error:error statusCode:(long)((NSHTTPURLResponse *)response).statusCode])
        {
            //serialize response into NSData obj
            // wrap since we are serializing JSON
            @try
            {
                //serialized
                result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
            }
            //error converting
            @catch (NSException *exception)
            {
                //err msg
                os_log_error(logHandle, "ERROR: converting response %{public}@ to JSON threw %{public}@", data, exception);
            }
        }
        //error making request
        else
        {
            //err msg
            os_log_error(logHandle, "ERROR: failed to get default rules from LuLuServer (%{public}@, %{public}@)", error, response);
        }
        
        //trigger
        dispatch_semaphore_signal(semaphore);
        
    }] resume];
    
    //wait for request to complete
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    

    return result;
}

// prepares data of an access without rule to log on remote server
- (void) logNotMatchedAccessWithFlowUUID:(NSString*)flowUUID processName:(NSString*)processName {
    os_log_info(logHandle, "Sending message to server: access of uuid: %{public}@, and name: %{public}@", flowUUID, processName);


    //error var
    NSError* error = nil;

    //item data
    NSMutableDictionary* itemData = nil;

    //post data
    // ->JSON'd items
    NSData* postData = nil;

    //init
    itemData = [NSMutableDictionary dictionary];

    //set item path
    itemData[@"flowUUID"] = flowUUID;
    
    //set hash
    itemData[@"processName"] = processName;

    @try
    {
        //convert items
        postData = [NSJSONSerialization dataWithJSONObject:itemData options:kNilOptions error:&error];

        if(nil == postData)
        {
            //err msg
            os_log_error(logHandle, "ERROR: failed to convert parameters %{public}@, to JSON (error: %{public}@)", itemData, error);
            
            return;
        }
        
    }

    @catch(NSException *exception)
    {
        //err msg
        os_log_error(logHandle, "ERROR: failed to convert parameters %{public}@, to JSON (error: %{public}@)", itemData, error);
        
        return;
    }
    
    //send data to the server
    [self postNotMatchedAccess:postData];
    
}


//connects to remote server and sends the information about the not-matched access
- (void) postNotMatchedAccess:(NSData*)postData {
    //endpoint url    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/new-access", LULU_SERVER_URL]];
    
    // //request
    // NSMutableURLRequest *request = nil;

    //alloc/init request
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];

    //add POST data
    [request setHTTPBody:postData];

    //set method type
    [request setHTTPMethod:@"POST"];

    // Set Content-Type header for JSON data
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    //send request
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error)
    {
        //dbg msg
        os_log_debug(logHandle, "got response %lu", (long)((NSHTTPURLResponse *)response).statusCode);
        
        //sanity check(s)
        if ([self sanityChecksWithData:data error:error statusCode:(long)((NSHTTPURLResponse *)response).statusCode])
        {
            os_log_info(logHandle, "logged new access sucessfully to LuLu Server");
        }
        //error making request
        else
        {
            //err msg
            os_log_error(logHandle, "ERROR: failed to log access to LuLu Server (%{public}@, %{public}@)", error, response);
        }      
        
    }] resume];
}

//verifies if response was received correctly
- (BOOL) sanityChecksWithData:(NSData*)data error:(NSError*)error statusCode:(long)statusCode {
    return ((nil != data) &&
            (nil == error) &&
            (200 == statusCode));
}

@end
