/**
 * Copyright (c) 2012 TokBox, Inc.
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import "OTObjectProxy.h"
#import <Opentok/OpenTok.h>
#import "ComTokboxTiOpentokVideoViewProxy.h"

extern NSString * const kPublisherCameraPositionFront;
extern NSString * const kPublisherCameraPositionBack;

@class ComTokboxTiOpentokSessionProxy;

@interface ComTokboxTiOpentokPublisherProxy : TiProxy <OTPublisherDelegate, OTObjectProxy> {

@private
    // Owned
    OTPublisher *_publisher;
    ComTokboxTiOpentokVideoViewProxy *_videoViewProxy;
    // Unsafe unretained
    ComTokboxTiOpentokSessionProxy *_sessionProxy;
}

- (id)initWithSessionProxy:(ComTokboxTiOpentokSessionProxy *)sessionProxy 
                      name:(NSString *)name 
                     audio:(BOOL)publishAudio 
                     video:(BOOL)publishVideo;

// Obj-C only Methods
-(void)_invalidate;

// Properties
@property (weak, readonly) NSNumber *publishAudio;
@property (weak, readonly) NSNumber *publishVideo;
@property (weak, readonly) NSString *name;
@property (weak, readonly) ComTokboxTiOpentokSessionProxy *session;
@property (nonatomic, weak) NSString *cameraPosition;
@property (weak, readonly) ComTokboxTiOpentokVideoViewProxy *view;

// Methods
-(ComTokboxTiOpentokVideoViewProxy *)createView:(id)args;

@end
