/**
 * Copyright (c) 2012 TokBox, Inc.
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import "OTObjectProxy.h"
#import <Opentok/OpenTok.h>
#import "ComTokboxTiOpentokVideoViewProxy.h"

@class ComTokboxTiOpentokSessionProxy, ComTokboxTiOpentokStreamProxy;

@interface ComTokboxTiOpentokSubscriberProxy : TiProxy <OTSubscriberKitDelegate, OTObjectProxy> {

@private
    // Owned
    OTSubscriber *_subscriber;
    ComTokboxTiOpentokVideoViewProxy *_videoViewProxy;
    // Unsafe unretained
    ComTokboxTiOpentokSessionProxy *_sessionProxy;
    ComTokboxTiOpentokStreamProxy *_streamProxy;
}

- (id)initWithSessionProxy:(ComTokboxTiOpentokSessionProxy *)sessionProxy 
                    stream:(ComTokboxTiOpentokStreamProxy *)stream 
                     audio:(BOOL)subscribeToAudio 
                     video:(BOOL)subscribeToVideo;

// Obj-C only Methods
-(void)_invalidate;

// Properties
@property (readonly, weak) ComTokboxTiOpentokSessionProxy *session;
@property (readonly, weak) ComTokboxTiOpentokStreamProxy *stream;
@property (weak, readonly) NSNumber *subscribeToAudio;
@property (weak, readonly) NSNumber *subscribeToVideo;
@property (weak, readonly) ComTokboxTiOpentokVideoViewProxy *view;

// Methods
-(ComTokboxTiOpentokVideoViewProxy *)createView:(id)args;

@end
