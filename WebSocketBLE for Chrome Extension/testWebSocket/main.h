//
//  main.h
//  testWebSocket
//
//  Created by Milo Chen on 12/24/13.
//  Copyright (c) 2013 milochen-macbook. All rights reserved.
//

#ifndef testWebSocket_main_h
#define testWebSocket_main_h

@class ClassA;
@interface ClassA:NSObject {}
-(void)startFunction;

-(void) sendCommandToChrome:(NSString*)cmd ;
-(void) sendCommandToBt:(NSString*)cmd;
-(void) recvCommandFromChrome:(NSString*) cmd ;
-(void) recvCommandFromBt:(NSString*) cmd ;

+(ClassA*) sharedInstance ;
+(void) callByC;
+(void)callByCWithStr:(NSString*) str ;
@end



#endif
