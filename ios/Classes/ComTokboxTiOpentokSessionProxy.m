//
//  ComTokboxTiOpentokSessionProxy.m
//  opentok-titanium
//
//  Created by Ankur Oberoi on 3/19/12.
//  Copyright (c) 2012 TokBox, Inc.
//  Please see the LICENSE included with this distribution for details.
//

#import "ComTokboxTiOpentokSessionProxy.h"
#import "ComTokboxTiOpentokStreamProxy.h"
#import "ComTokboxTiOpentokConnectionProxy.h"
#import "ComTokboxTiOpentokPublisherProxy.h"
#import "ComTokboxTiOpentokSubscriberProxy.h"
#import "ComTokboxTiOpentokModule.h"
#import "TiUtils.h"
#import "TiBase.h"
#import <Opentok/OTError.h>

NSString * const kSessionStatusConnected = @"connected";
NSString * const kSessionStatusConnecting = @"connecting";
NSString * const kSessionStatusDisconnected = @"disconnected";
NSString * const kSessionStatusFailed = @"failed";

@implementation ComTokboxTiOpentokSessionProxy

#pragma mark - Helpers

- (void)requireSessionInitializationWithLocation:(NSString *)codeLocation andMessage:(NSString *)message
{
    if (_session == nil) {
        [self throwException:TiExceptionInternalInconsistency 
                   subreason:message
                    location:codeLocation];
    }
}

- (void)requireSessionInitializationWithLocation:(NSString *)codeLocation
{
    [self requireSessionInitializationWithLocation:codeLocation andMessage:@"This session was not properly initialized"];
}

+ (BOOL)validBool:(id)object fallback:(BOOL)fallback
{
    if (![object isKindOfClass:[NSNumber class]]) {
        return fallback;
    } else {
        return [(NSNumber *)object boolValue];
    }
}

+ (NSString *)validString:(id)object
{
    if (![object isKindOfClass:[NSString class]]) {
        return nil;
    } else {
        return (NSString *)object;
    }
}

// TODO: Localization
+ (NSDictionary *)dictionaryForOTError:(OTError *)error
{
    NSString *message;
    switch ([error code]) {
        case OTAuthorizationFailure:
            message = @"An invalid API key or token was provided";
            break;
            
        case OTErrorInvalidSession:
            message = @"An invalid session ID was provided";
            break;
        
        case OTConnectionFailed:
            message = @"There was an error connecting to OpenTok services";
            break;
            
        case OTNoMessagingServer:
            message = @"No messaging server is available for this session";
            break;
        
        case OTConnectionRefused:
            message = @"A socket could not be opened to the messaging server. Check that outbound ports 5560 or 8080 are accessible";
            break;
            
        case OTSessionStateFailed:
            message = @"The connection timed out while attempting to get the session's state";
            break;
        
        case OTP2PSessionMaxParticipants:
            message = @" A peer-to-peer enabled session can only have two participants";
            break;
            
        case OTSessionConnectionTimeout:
            message = @"The connection timed out while attempting to connect to the session";
            break;
            
        case OTSessionInternalError:
            message = @"Thread dispatch failure, out of memory, parse error, etc.";
            break;
            
        case OTConnectionDropped:
            message = @"Connection dropped";
            break;
            
        default:
            message = @"An unknown error occurred";
            break;
    }
    
    return [NSDictionary dictionaryWithObject:message forKey:@"message"];
}

#pragma mark - Initialization


- (id)init
{
    self = [super init];
    if (self) {
        // Initializations
        NSLog(@"[DEBUG] init called on session proxy");
        
        // We would normally alloc/init the backing session here, but since we can't yet access its
        // sessionId we will delay initialization of _session until that property is set.
        _session = nil;
        _streamProxies = nil;
        _connectionProxy = nil;
        _publisherProxy = nil;
        _subscriberProxies = nil;
    }
    return self;
}

#pragma mark - Deallocation

- (void)dealloc
{
    NSLog(@"[DEBUG] dealloc called on session proxy");
    [self destroyBackingSession];
    
}

- (void)destroyBackingSession
{
    //RELEASE_TO_NIL(_session);
    //RELEASE_TO_NIL(_streamProxies);
    //RELEASE_TO_NIL(_connectionProxy);
    //RELEASE_TO_NIL(_publisherProxy);
    //RELEASE_TO_NIL(_subscriberProxies);
    RELEASE_TO_NIL(_sessionId);
    RELEASE_TO_NIL(_apiKey);
}

#pragma mark - Objective-C only Methods

-(void)_removeSubscriber:(ComTokboxTiOpentokSubscriberProxy *)subscriberProxy
{
    [_subscriberProxies removeObject:subscriberProxy];
    NSLog(@"[DEBUG] session removing subscriber proxy");
}

-(ComTokboxTiOpentokSubscriberProxy *)_subscriberForStream:(ComTokboxTiOpentokStreamProxy *)streamProxy
{
    ComTokboxTiOpentokSubscriberProxy *matchedSubscriberProxy = nil;
    for (ComTokboxTiOpentokSubscriberProxy *subscriberProxy in _subscriberProxies) {
        if ([[[subscriberProxy stream] streamId] isEqualToString:[streamProxy streamId]]) {
            matchedSubscriberProxy = subscriberProxy;
            break;
        }
    }
    return matchedSubscriberProxy;
}

#pragma mark - Public Properties

- (void)setSessionId:(id)value
{
    NSLog(@"[WARN] setSessionId called");
    // We cannot change the session id once a session has been created, go allocate a new one if needed
    if (_session) {
        // Throw error
        // TODO: no idea if this actually works, exception handling isn't documented well for titanium.
        // http://developer.appcelerator.com/question/130582/how-to-catch-errors
        
        [self throwException:TiExceptionInternalInconsistency 
                   subreason:@"Once a Session has been given a sessionId, it cannot be changed." 
                    location:CODELOCATION];
        return;
    }
    NSLog(@"[WARN] _session is nil");

    ENSURE_STRING(value);
    _sessionId = [value retain];
    NSLog(@"[WARN] set stringSessionId: %@", _sessionId);

    // Will go ahead and create session if API Key also available.
    [self establishSessionIfReady];
}

- (id)sessionId
{
    return _session.sessionId;
}

- (id)apiKey
{
    return _apiKey;
}

- (void)setApiKey:(id)key
{
    ENSURE_STRING(key);
    _apiKey = [key retain];

    // Will go ahead and establish session
    // if sessionId is also known.
    [self establishSessionIfReady];
}

- (NSArray *)streams
{
    // Lazily instantiate _streamProxies if it doesn't already exist
    if (_streamProxies == nil) {
        _streamProxies = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    
    // Add a stream proxy for any streams who don't already have one in _streamProxies dictionary
    [_session.streams enumerateKeysAndObjectsUsingBlock:^(id streamId, id stream, BOOL *stop) {
        ComTokboxTiOpentokStreamProxy *streamProxy = [_streamProxies objectForKey:streamId];
        if(streamProxy == nil) {
            streamProxy = [[ComTokboxTiOpentokStreamProxy alloc] initWithStream:(OTStream *)stream sessionProxy:self];
            [_streamProxies setObject:streamProxy forKey:streamId];
        }
    }];
    
    // Return an array of just the stream proxies
    return [_streamProxies allValues];
}

- (NSString *)sessionConnectionStatus
{
    switch (_session.sessionConnectionStatus) {
        case OTSessionConnectionStatusConnected:
            return kSessionStatusConnected;
            break;
        case OTSessionConnectionStatusConnecting:
            return kSessionStatusConnecting;
            break;
        case OTSessionConnectionStatusDisconnecting:
            return kSessionStatusDisconnected;
            break;
        case OTSessionConnectionStatusNotConnected:
            return kSessionStatusDisconnected;
            break;
        case OTSessionConnectionStatusFailed:
            return kSessionStatusFailed;
            break;
    }
}

-(NSNumber *)connectionCount
{
    return 0;
}

-(ComTokboxTiOpentokConnectionProxy *)connection
{
    if (_connectionProxy == nil) {
        _connectionProxy = [[ComTokboxTiOpentokConnectionProxy alloc] initWithConnection:_session.connection];
    }
    
    return _connectionProxy;
}

#pragma mark - Public Methods

- (void)connect:(id)args {
    [self requireSessionInitializationWithLocation:CODELOCATION];
    
    // Validate arguments
    NSArray *argumentArray = (NSArray *)args;
    NSString *apiKey = [TiUtils stringValue:[argumentArray objectAtIndex:0]];
    NSString *token = [TiUtils stringValue:[argumentArray objectAtIndex:1]];
    
    NSLog(@"[DEBUG] session proxy connect called with arguments apiKey: %@, token: %@", apiKey, token)
    
    if (apiKey == nil || token == nil) THROW_INVALID_ARG(@"Must call this method with a valid string 'apiKey' and string 'token'.");
    
    OTError *error = nil;
    
    // Call method on backing session
    [_session connectWithToken:token error:&error];
    
    if (error)
    {
        NSLog(@"[ERROR] session connect failed");
    }
    
    NSLog(@"[DEBUG] session connect called");
    
}

- (void)disconnect:(id)args
{
    // this is a bandaid over some threading issues in the underlying library
    // when disconnect is called from a background thread, there is a data race inside the sessionDisconnectionCleanup
    // around the session state
    ENSURE_UI_THREAD_0_ARGS
    
    [self requireSessionInitializationWithLocation:CODELOCATION];
    
    OTError *error = nil;
    [_session disconnect: &error];
    
    if (error) {
        NSLog(@"[DEBUG] session disconnect error");
    }
    
    NSLog(@"[DEBUG] session disconnect called");
    
    // lets the JS treat the session as reusable even though the underlying library doesn't support this
    NSString *cachedSessionId = _session.sessionId;
    [self destroyBackingSession];
    _session = [[OTSession alloc] initWithApiKey:@"YOUR_API_KEY_HERE" sessionId:cachedSessionId delegate:self];
}

// takes one argument which is a dictionary of options
- (id)publish:(id)args
{
    NSLog(@"[DEBUG] IN PUBLISH METHOD 1");
    NSString *name = nil;
    BOOL publishAudio = YES, publishVideo = YES;
    NSLog(@"[DEBUG] IN PUBLISH METHOD 2");
    
    if (_publisherProxy != nil) {
        NSLog(@"[DEBUG] Publisher already exists, cannot create more than one publisher");
        // TODO: not sure if returning the existing publisher proxy is a good idea
        // Maybe we should also verify that not only does it exist, but that it is publishing?
        // unpublish looks like it does the right thing (makes _publisher = nil). But when a publisher fails
        // or if a publisher stops streaming, _publisher probably still points to a valid object
    } else {
        NSLog(@"[DEBUG] IN PUBLISH METHOD 3");
        // parse options
        id firstArg = [args count] > 0 ? [args objectAtIndex:0] : nil;
        NSLog(@"[DEBUG] IN PUBLISH METHOD 11");
        if (firstArg != nil && [firstArg isKindOfClass:[NSDictionary class]]) {
            NSLog(@"[DEBUG] IN PUBLISH METHOD 4");
            NSDictionary *options = (NSDictionary *)firstArg;
            NSLog(@"[DEBUG] IN PUBLISH METHOD 5");
            name = [ComTokboxTiOpentokSessionProxy validString:[options objectForKey:@"name"]];
            NSLog(@"[DEBUG] IN PUBLISH METHOD 6");
            publishAudio = [ComTokboxTiOpentokSessionProxy validBool:[options objectForKey:@"publishAudio"] fallback:YES];
            NSLog(@"[DEBUG] IN PUBLISH METHOD 7");
            publishVideo = [ComTokboxTiOpentokSessionProxy validBool:[options objectForKey:@"publishVideo"] fallback:YES];
            NSLog(@"[DEBUG] IN PUBLISH METHOD 8");
        }
        
        NSLog(@"[DEBUG] OUTSIDE IF STATEMENT");
        
        // Create a publisher proxy from the backing session
        _publisherProxy = [[ComTokboxTiOpentokPublisherProxy alloc] initWithSessionProxy:self
                                                                                    name:name 
                                                                                   audio:publishAudio 
                                                                                   video:publishVideo];
        NSLog(@"[DEBUG] IN PUBLISH METHOD 9");
        // Begin publishing
        OTError *error = nil;
        [_session publish:[_publisherProxy backingOpentokObject] error:&error];
        if (error) {
            NSLog(@"[ERROR] Error on publish");
        }
        NSLog(@"[DEBUG] session publishing");
    }
    NSLog(@"[DEBUG] IN PUBLISH METHOD 10");
    return _publisherProxy;
}

-(void)unpublish:(id)args
{
    if (_publisherProxy != nil) {
        OTError *error = nil;
        [_session unpublish:[_publisherProxy backingOpentokObject] error:&error];
        
        if (error) {
            NSLog(@"[ERROR] Error on unpublish");
        }
        
        NSLog(@"[DEBUG] session unpublishing");
        [_publisherProxy _invalidate];
        _publisherProxy = nil;
    } else {
        NSLog(@"[DEBUG] There is no publisher to unpublish");
    }
}

- (id)subscribe:(id)args
{
    BOOL subscribeToAudio = YES, subscribeToVideo = YES;
    // TODO: can we do more than one subscriber for the same stream? probably.
    
    if ([args count] < 1) {
        return nil;
    }
    
    // parse args
    id firstArg = [args objectAtIndex:0];
    if (![firstArg isKindOfClass:[ComTokboxTiOpentokStreamProxy class]]) {
        NSLog(@"[DEBUG] Invalid stream proxy given");
        return nil;
    }
    ComTokboxTiOpentokStreamProxy *stream = (ComTokboxTiOpentokStreamProxy *)firstArg;
    
    id secondArg = [args count] > 1 ? [args objectAtIndex:1] : nil;
    if (secondArg != nil && [secondArg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *options = (NSDictionary *)secondArg;
        subscribeToAudio = [ComTokboxTiOpentokSessionProxy validBool:[options objectForKey:@"subscribeToAudio"] fallback:YES];
        subscribeToVideo = [ComTokboxTiOpentokSessionProxy validBool:[options objectForKey:@"subscribeToVideo"] fallback:YES];
    }
    
    // create subscriber proxy
    if (_subscriberProxies == nil) {
        _subscriberProxies = [[NSMutableArray alloc] initWithCapacity:4];
    }
    ComTokboxTiOpentokSubscriberProxy *subscriberProxy = [[ComTokboxTiOpentokSubscriberProxy alloc] initWithSessionProxy:self
                                                                                                             stream:stream
                                                                                                              audio:subscribeToAudio 
                                                                                                              video:subscribeToVideo];
    OTError *error = nil;
    [_session subscribe:[subscriberProxy backingOpentokObject] error:&error];
    if (error) {
        NSLog(@"[ERROR] Error on subscribe");
    }
    [_subscriberProxies addObject:subscriberProxy];
    
    NSLog(@"[DEBUG] session adding subscriber proxy");
    return subscriberProxy;
}

- (void)unsubscribe:(id)args
{
    id firstArg = [args objectAtIndex:0];
    if (![firstArg isKindOfClass:[ComTokboxTiOpentokStreamProxy class]]) {
        NSLog(@"[DEBUG] invalid stream proxy given");
    }
    ComTokboxTiOpentokStreamProxy *streamProxy = (ComTokboxTiOpentokStreamProxy *)firstArg;
    
    ComTokboxTiOpentokSubscriberProxy *subscriberProxy = [self _subscriberForStream:streamProxy];
    OTError *error = nil;
    [_session unsubscribe:[subscriberProxy backingOpentokObject] error:&error];
    if (error) {
        NSLog(@"[ERROR] Error on unsubscribe");
    }
    NSLog(@"[DEBUG] session unpublishing");
    
    // TODO: invalidation
    //[subscriberProxy _invalidate];
    [_subscriberProxies removeObject:subscriberProxy];
}

##pragma mark - Private Methods

- (void)establishSessionIfReady
{
    if (!_sessionId) {
        NSLog(@"[WARN] Delaying session creation because sessionId not yet known");
        return;
    }

    if (!_apiKey) {
        NSLog(@"[WARN] Delaying session creation because apiKey not yet known");
        return;
    }

    NSLog(@"[WARN] Proceeding with session creation");
    _session = [[OTSession alloc] initWithApiKey:_apiKey sessionId:_sessionId delegate:self];
    NSLog(@"[WARN] called initWithApiKey");
    
    // TODO: remove this hack in the next release of the OpenTok iOS SDK 2.2
    NSLog(@"[WARN] called the retain thing");
    
    NSLog(@"[DEBUG] session initialized with id: %@", _sessionId);
}

#pragma mark - Session Delegate Protocol

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"[DEBUG] session connected");
    if ([self _hasListeners:@"sessionConnected"]) {
        [self fireEvent:@"sessionConnected"];
    }
}


- (void)sessionDidDisconnect:(OTSession*)session
{
    NSLog(@"[DEBUG] session disconnected");
    if ([self _hasListeners:@"sessionDisconnected"]) {
        [self fireEvent:@"sessionDisconnected"];
    }
}


- (void)session:(OTSession*)session didFailWithError:(OTError*)error
{
    NSLog(@"[DEBUG] session failed with error: %@", [error description]);
    NSDictionary *errorObject = [ComTokboxTiOpentokSessionProxy dictionaryForOTError:error];
    NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:errorObject forKey:@"error"];
    
    if ([self _hasListeners:@"sessionFailed"]) {
        NSLog(@"[DEBUG] session failed event firing");
        [self fireEvent:@"sessionFailed" withObject:eventParameters];
    }
}


- (void)session:(OTSession*)session streamCreated:(OTStream *)stream
{
    NSLog(@"[DEBUG] session recieved stream");
    if ([self _hasListeners:@"streamCreated"]) {
        
        // Create a stream proxy object
        ComTokboxTiOpentokStreamProxy *streamProxy = [[ComTokboxTiOpentokStreamProxy alloc] initWithStream:stream sessionProxy:self];
        
        NSLog(@"[DEBUG] stream proxy created for streamId %@", streamProxy.streamId);
        
        // Manage the _streamProxies dictionary
        [_streamProxies setObject:streamProxy forKey:streamProxy.streamId];
        
        // Put the stream proxy object in the event parameters
        NSDictionary *eventProperties = [NSDictionary dictionaryWithObject:streamProxy forKey:@"stream"];
        
        // Clean up
        
        // fire event
        [self fireEvent:@"streamCreated" withObject:eventProperties];
        
        NSLog(@"[DEBUG] streamCreated event fired with object %@", eventProperties.description);
    }
}


- (void)session:(OTSession*)session streamDestroyed:(OTStream *)stream
{
    NSLog(@"[DEBUG] session dropped stream");
    if ([self _hasListeners:@"streamDestroyed"]) {
        
        // Find and remove the stream proxy in _streamProxies
        ComTokboxTiOpentokStreamProxy *deadStreamProxy = [_streamProxies objectForKey:stream.streamId];
        [_streamProxies removeObjectForKey:deadStreamProxy.streamId];
        
        // If the stream proxy is not found, create one for the event properties
        if (deadStreamProxy == nil) {
            NSLog(@"[DEBUG] Could not find stream proxy during drop, initializing new one here");
            deadStreamProxy = [[ComTokboxTiOpentokStreamProxy alloc] initWithStream:stream sessionProxy:self];
        }
        
        // put the stream proxy object in the event parameters
        NSDictionary *eventProperties = [NSDictionary dictionaryWithObject:deadStreamProxy forKey:@"stream"];
        
        // fire event
        [self fireEvent:@"streamDestroyed" withObject:eventProperties];
    }
}

#pragma mark - Opentok Object Proxy

- (id) backingOpentokObject
{
    return _session;
}

#pragma mark - TiProxy

-(void)_listenerAdded:(NSString*)type count:(int)count
{
    NSLog(@"[DEBUG] Session Listener of type %@ added", type);
    //[super _listenerAdded:type count:count];
}

-(void)_listenerRemoved:(NSString*)type count:(int)count
{
    NSLog(@"[DEBUG] Session Listener of type %@ removed", type);
    //[super _listenerRemoved:type count:count];
}

@end
