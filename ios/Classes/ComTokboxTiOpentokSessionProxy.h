//
//  ComTokboxTiOpentokSessionProxy.h
//  opentok-titanium
//
//  Created by Ankur Oberoi on 3/19/12.
//  Copyright (c) 2012 TokBox, Inc.
//  Please see the LICENSE included with this distribution for details.
//

#import "TiProxy.h"
#import "OTObjectProxy.h"
#import <Opentok/OTSession.h>

extern NSString * const kSessionStatusConnected;
extern NSString * const kSessionStatusConnecting;
extern NSString * const kSessionStatusDisconnected;
extern NSString * const kSessionStatusFailed;

@class ComTokboxTiOpentokConnectionProxy, 
       ComTokboxTiOpentokPublisherProxy, 
       ComTokboxTiOpentokSubscriberProxy;

@interface ComTokboxTiOpentokSessionProxy : TiProxy <OTSessionDelegate, OTObjectProxy> {

// Owning strong references
@private
    OTSession *_session;
    NSMutableDictionary *_streamProxies;
    ComTokboxTiOpentokConnectionProxy *_connectionProxy;
    ComTokboxTiOpentokPublisherProxy *_publisherProxy;
    NSMutableArray *_subscriberProxies;
    NSString *_apiKey;
    NSString *_sessionId;
    
}

// Obj-C only Methods
-(void)_removeSubscriber:(ComTokboxTiOpentokSubscriberProxy *)subscriberProxy;

// Properties
@property (weak, readonly) NSArray *streams;
@property (weak, readonly) NSString *sessionConnectionStatus;
@property (weak, readonly) NSNumber *connectionCount;
@property (weak, readonly) ComTokboxTiOpentokConnectionProxy *connection;

// Methods
- (void)connect:(id)args;
- (void)disconnect:(id)args;
- (id)publish:(id)args;
- (void)unpublish:(id)args;
- (id)subscribe:(id)args;
- (void)unsubscribe:(id)args;
- (id)apiKey;
- (void)setApiKey(id)key;
- (id)sessionId;
- (void)setSessionId(id)value;
// TODO add signaling methods


@end
