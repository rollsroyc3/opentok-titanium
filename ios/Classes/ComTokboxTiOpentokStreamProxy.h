//
//  ComTokboxTiOpentokStreamProxy.h
//  opentok-titanium
//
//  Created by Ankur Oberoi on 3/21/12.
//  Copyright (c) 2012 TokBox, Inc.
//  Please see the LICENSE included with this distribution for details.
//

#import "TiProxy.h"
#import "OTObjectProxy.h"
#import <Opentok/OTStream.h>

@class ComTokboxTiOpentokSessionProxy;
@class ComTokboxTiOpentokConnectionProxy;

@interface ComTokboxTiOpentokStreamProxy : TiProxy <OTObjectProxy> {
    
@private
    // Owned
    OTStream *_stream;
    ComTokboxTiOpentokConnectionProxy *_connectionProxy;
    // Unsafe unretained
    ComTokboxTiOpentokSessionProxy *_sessionProxy;
}

- (id)initWithStream:(OTStream *)existingStream sessionProxy:(ComTokboxTiOpentokSessionProxy *)sessionProxy;

// Properties
@property (weak, readonly) ComTokboxTiOpentokConnectionProxy *connection;
@property (weak, readonly) NSDate *creationTime;
@property (weak, readonly) NSNumber *hasAudio;
@property (weak, readonly) NSNumber *hasVideo;
@property (weak, readonly) NSString *name;
@property (weak, readonly) ComTokboxTiOpentokSessionProxy *session;
@property (weak, readonly) NSString *streamId;
@property (weak, readonly) NSString *type;

@end
