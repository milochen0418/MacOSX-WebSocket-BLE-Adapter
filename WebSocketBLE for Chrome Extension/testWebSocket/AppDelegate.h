//
//  AppDelegate.h
//  testWebSocket
//
//  Created by milochen on 12/18/13.
//  Copyright (c) 2013 milochen-macbook. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

-(void) sendCommandToBt:(NSString*) cmd ;


@end
