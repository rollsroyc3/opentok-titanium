/**
 * Copyright (c) 2012 TokBox, Inc.
 * Please see the LICENSE included with this distribution for details.
 */

#import "ComTokboxTiOpentokPublisherProxy.h"
#import "ComTokboxTiOpentokSessionProxy.h"
#import <Opentok/OTPublisher.h>
#import "Opentok/OTError.h"

NSString * const kPublisherCameraPositionFront = @"cameraFront";
NSString * const kPublisherCameraPositionBack = @"cameraBack";

@implementation ComTokboxTiOpentokPublisherProxy

#pragma mark - Helpers

- (void)requirePublisherInitializationWithLocation:(NSString *)codeLocation andMessage:(NSString *)message {
    if (_publisher == nil) {
        [self throwException:TiExceptionInternalInconsistency
                   subreason:message
                    location:codeLocation];
    }
}

- (void)requirePublisherInitializationWithLocation:(NSString *)codeLocation {
    [self requirePublisherInitializationWithLocation:codeLocation andMessage:@"This publisher was not properly initialized"];
}

// TODO: Localization
+ (NSDictionary *)dictionaryForOTError:(OTError *)error
{
    NSString *message;
    switch ([error code]) {
        case OTSessionConnectionStatusFailed:
            message = @"Thread dispatch failure, out of memory, etc.";
            break;
            
        case OTSessionConnectionStatusNotConnected:
            message = @"Attempting to publish to a disconnected session";
            break;
            
        default:
            message = @"An unknown error occurred";
            break;
    }
    
    return [NSDictionary dictionaryWithObject:message forKey:@"message"];
}

+ (NSString *)captureDevicePositionToString:(AVCaptureDevicePosition)position
{
    switch (position) {
        case AVCaptureDevicePositionBack:
            return kPublisherCameraPositionBack;
            break;
        case AVCaptureDevicePositionFront:
            return kPublisherCameraPositionFront;
            break;
        case AVCaptureDevicePositionUnspecified:
            return kPublisherCameraPositionBack;
            break;
    }
}

#pragma mark - Initialization

// Overriding designated initializer in order to prevent instantiation from javascript land (hopefully)
- (id)initWithSessionProxy:(ComTokboxTiOpentokSessionProxy*)sessionProxy
                      name:(NSString *)name
                     audio:(BOOL)publishAudio 
                     video:(BOOL)publishVideo
{
    
    NSLog(@"[DEBUG] IN initWithSessionProxy METHOD 1");
    
    self = [super init];
    
    NSLog(@"[DEBUG] IN initWithSessionProxy METHOD 2");
    
    if (self) {
        NSLog(@"[DEBUG] IN initWithSessionProxy METHOD 3");
        // unretained, unsafe reference. be careful
        _sessionProxy = sessionProxy;
        NSLog(@"[DEBUG] IN initWithSessionProxy METHOD 4");
        if (name != nil) {
            NSLog(@"[DEBUG] IN initWithSessionProxy METHOD 5");
            _publisher = [[OTPublisher alloc] initWithDelegate:self name:name];
        } else {
            NSLog(@"[DEBUG] IN initWithSessionProxy METHOD 6");
            _publisher = [[OTPublisher alloc] initWithDelegate:self];
        }
        NSLog(@"[DEBUG] IN initWithSessionProxy METHOD 7");
        _publisher.publishAudio = publishAudio;
        _publisher.publishVideo = publishVideo;
        NSLog(@"[DEBUG] IN initWithSessionProxy METHOD 8");
        if (_videoViewProxy != nil) {
            _videoViewProxy = nil;
        }
        NSLog(@"[DEBUG] IN initWithSessionProxy METHOD 9");
    }
    NSLog(@"[DEBUG] IN initWithSessionProxy METHOD 10");
    return self;
}

#pragma mark - Deallocation

- (void)dealloc {
    [_videoViewProxy _invalidate];
    
}

#pragma mark - Obj-C only methods

-(void)_invalidate
{
    _publisher = nil;
    
    [_videoViewProxy _invalidate];
    _videoViewProxy = nil;
}

#pragma mark - Properties

-(id)publishAudio
{
    [self requirePublisherInitializationWithLocation:CODELOCATION];
    return NUMBOOL(_publisher.publishAudio);
}

-(id)publishVideo
{
    [self requirePublisherInitializationWithLocation:CODELOCATION];
    return NUMBOOL(_publisher.publishVideo);
}

-(id)name
{
    [self requirePublisherInitializationWithLocation:CODELOCATION];
    return _publisher.name;
}

-(id)session
{
    [self requirePublisherInitializationWithLocation:CODELOCATION];
    
    // TODO: this could return a dangling pointer
    return _sessionProxy;
}

-(id)cameraPosition
{
    [self requirePublisherInitializationWithLocation:CODELOCATION];
    return [ComTokboxTiOpentokPublisherProxy captureDevicePositionToString:_publisher.cameraPosition];
}

-(void)setCameraPosition:(NSString *)cameraPosition
{
    [self requirePublisherInitializationWithLocation:CODELOCATION];
    if ([cameraPosition isEqualToString:kPublisherCameraPositionBack]) {
        _publisher.cameraPosition = AVCaptureDevicePositionBack;
    } else if ([cameraPosition isEqualToString:kPublisherCameraPositionFront]) {
        _publisher.cameraPosition = AVCaptureDevicePositionFront;
    }
}

-(ComTokboxTiOpentokVideoViewProxy *)view
{
    [self requirePublisherInitializationWithLocation:CODELOCATION];
    
    // TODO: Probably not the best way to return a view, should somehow indicate that createView should
    //       be called first
    if (_videoViewProxy) return _videoViewProxy;
    return nil;
}


#pragma mark - Methods

-(ComTokboxTiOpentokVideoViewProxy *)createView:(id)args
{
    [self requirePublisherInitializationWithLocation:CODELOCATION];
    
    NSLog(@"[DEBUG] creating a video view proxy");
    if (!_videoViewProxy) {
        ENSURE_SINGLE_ARG(args, NSDictionary);
        _videoViewProxy = [[ComTokboxTiOpentokVideoViewProxy alloc] initWithProxy:self andProperties:args];
        NSLog(@"[DEBUG] video view proxy instance created: %@", _videoViewProxy.description);
    }
    // TODO: assign properties to existing videoViewProxy?
    return _videoViewProxy;
}

#pragma mark - Publisher Delegate Protocol

- (void)publisher:(OTPublisher *)publisher didFailWithError:(OTError *)error
{
    if ([self _hasListeners:@"publisherFailed"]) {
        
        NSDictionary *errorObject = [ComTokboxTiOpentokPublisherProxy dictionaryForOTError:error];
        NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:errorObject forKey:@"error"];
        
        [self fireEvent:@"publisherFailed" withObject:eventParameters];
    }
}

- (void)publisherDidStartStreaming:(OTPublisher *)publisher
{
    if ([self _hasListeners:@"publisherStarted"]) {
        [self fireEvent:@"publisherStarted"];
    }
}

- (void)publisherDidStopStreaming:(OTPublisher *)publisher
{
    if ([self _hasListeners:@"publisherStopped"]) {
        [self fireEvent:@"publisherStopped"];
    }
}

#pragma mark - Opentok Object Proxy

- (id) backingOpentokObject
{
    return _publisher;
}

@end
