/**
 * Copyright (c) 2012 TokBox, Inc.
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import "OTObjectProxy.h"
#import <Opentok/OTConnection.h>

@interface ComTokboxTiOpentokConnectionProxy : TiProxy <OTObjectProxy> {

@private
    OTConnection *_connection;    
}

- (id)initWithConnection:(OTConnection *)existingConnection;

// Properties
@property (weak, readonly) NSString *connectionId;
@property (weak, readonly) NSDate *creationTime;

@end
