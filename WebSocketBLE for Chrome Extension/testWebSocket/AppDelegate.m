//
//  AppDelegate.m
//  testWebSocket
//
//  Created by milochen on 12/18/13.
//  Copyright (c) 2013 milochen-macbook. All rights reserved.
//

#import "AppDelegate.h"
//#include "./bluetooth/ProprietaryService.h"
#define TAXEIA_SERVICE_UUID           @"F88DC793-AED2-49DC-B000-5B0E28ED5418"

// Taxeia Proprietary PeripheralToCentral Characteristic
#define P2C_CHARACTERISTIC_UUID    @"282BD0EA-0EEB-4386-8269-F814C99676B9"

// Taxeia Proprietary CentralToPeripheral Characteristic
#define C2P_CHARACTERISTIC_UUID    @"4CEA96E6-2532-4162-929C-47CF47E212F9"

#import "main.h"
#import <IOBluetooth/IOBluetooth.h>

@interface AppDelegate () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (strong, nonatomic) CBCentralManager      *mCentralManager;
@property (strong, nonatomic) CBPeripheral          *mDiscoveredPeripheral;

@property (strong, nonatomic) CBCharacteristic      *mC2pCharacteristic;
@property (strong, nonatomic) CBCharacteristic      *mP2cCharacteristic;

//@property (strong, nonatomic) IBOutlet NSTextField  *label_status;
@property (strong, nonatomic) IBOutlet NSTextField  *mLabelStatus;
@property (strong, nonatomic) IBOutlet NSTextField  *mTextviewResult;

@property (strong, nonatomic) IBOutlet NSButton     *mButtonScan;
@property (strong, nonatomic) IBOutlet NSButton     *mButtonWrite;
@property (weak) IBOutlet NSTextField *mWriteDataField;
- (IBAction)onScanBtnClick:(id)sender;
- (IBAction)onWriteBtnClick:(id)sender;
- (IBAction)clickToRequestGoogleData:(id)sender;
- (IBAction)clickToRequestFacebookData:(id)sender;
- (IBAction)clickToSendGoogleDataToChrome:(id)sender;
- (IBAction)clickToSendFacebookDataToChrome:(id)sender;

@end


@implementation AppDelegate
@synthesize mButtonWrite,mButtonScan, mLabelStatus, mTextviewResult;
@synthesize mWriteDataField;
@synthesize mC2pCharacteristic,mP2cCharacteristic,mCentralManager,mDiscoveredPeripheral;




-(void) sendCommandToBt:(NSString*) cmd {

    if(mDiscoveredPeripheral) {
        //NSString *string_to_send = @"From Central.";
        //NSString *string_to_send = @"yu:88";
        NSString *string_to_send = cmd;
        [self sendCmd:string_to_send];
    }
}



- (IBAction)clickToRequestGoogleData:(id)sender {
    NSLog(@"clickToRequestGoogleData");
    //[self sendCmd:@"google"];
    [[ClassA sharedInstance] sendCommandToBt:@"google"];
}
- (IBAction)clickToRequestFacebookData:(id)sender {
    NSLog(@"clickToRequestFacebookData");
    //[self sendCmd:@"facebook"];
    [[ClassA sharedInstance] sendCommandToBt:@"facebook"];
}

- (IBAction)clickToSendGoogleDataToChrome:(id)sender {
    [[ClassA sharedInstance] sendCommandToChrome:@"GoogleAccount:GooglePassword"];
}

- (IBAction)clickToSendFacebookDataToChrome:(id)sender {
    [[ClassA sharedInstance] sendCommandToChrome:@"我是FacebookAccount:FacebookPassword"];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [self startUpCBCentralManager];
}



- (IBAction)clickToOpenWebsocketServer:(id)sender {
    NSLog(@"clickToOpenWebsocketServer");
}


- (IBAction)clickToCloseWebsocketServer:(id)sender {
    NSLog(@"clickToCloseWebsocketServer");
}

- (IBAction)clickToSendString:(id)sender {
    NSLog(@"clickToSendString");
}




#pragma mark - Bluetooth Status Methods

- (void )startUpCBCentralManager {
    // Start up the CBCentralManager
    mCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    mDiscoveredPeripheral = nil;
}


#pragma mark - Bluetooth GUI event Methods

- (IBAction)onScanBtnClick:(id)sender {
    NSLog(@"call OnButtonScan");
    if(!mDiscoveredPeripheral){
        
        [self scan];
        
        //_label_status.text = @"Scanning Peripheral...";
        //[_label_status setString:@"Scanning Peripheral..."];
        [mLabelStatus setStringValue:@"Scanning Peripheral..."];
        NSLog(@"BT_Scanning Peripheral...");
        
        
    } else {
        [self.mCentralManager cancelPeripheralConnection:mDiscoveredPeripheral];
        
        //_label_status.text = @"Disconnecting Peripheral...";
        
        //[_label_status setString:@"Disconnecting Peripheral..."];
        NSLog(@"BT_Disconnecting Peripheral...");
    }
    
}



- (IBAction)onWriteBtnClick:(id)sender {
    NSLog(@"call OnButtonWrite");
//    [[ClassA sharedInstance] sendCommandToBt:@"From Central. "];
    NSString * writeString = @"From Centeral";
    
    writeString = [mWriteDataField stringValue];
    [[ClassA sharedInstance] sendCommandToBt:writeString];
    /*
    if(mDiscoveredPeripheral) {
        //NSString *string_to_send = @"From Central.";
        NSString *string_to_send = @"yu:88";
        [self sendCmd:string_to_send];
    }
     */
}

-(void) sendCmd:(NSString*) cmd {
    NSString * string_to_send = cmd;
    
    const int BLEBLUETOOTH_SEND_BUFFER_MAX = 20;
    /*
    if(mDiscoveredPeripheral) {
        NSData  *data_to_send = [cmd dataUsingEncoding:NSUTF8StringEncoding];
        [mDiscoveredPeripheral writeValue:data_to_send forCharacteristic:mC2pCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
     */
    
    NSData *sendData = [string_to_send dataUsingEncoding:NSUTF8StringEncoding];
    
    if([sendData length] <= BLEBLUETOOTH_SEND_BUFFER_MAX){
        
        [mDiscoveredPeripheral writeValue:sendData forCharacteristic:mC2pCharacteristic type:CBCharacteristicWriteWithResponse];
    }else{
        int len = [sendData length];
        int remainder = [sendData length] % BLEBLUETOOTH_SEND_BUFFER_MAX;
        int loop=0;
        NSRange range;
        do {
            range = NSMakeRange(BLEBLUETOOTH_SEND_BUFFER_MAX*loop, BLEBLUETOOTH_SEND_BUFFER_MAX);
            UInt8 buf[range.length];
            memset(buf, 0, range.length);
            [sendData getBytes:buf range:range];
            NSData *result = [[NSData alloc] initWithBytes:buf length:sizeof(buf)];
            NSLog(@"write vaule: %@", result);
            [mDiscoveredPeripheral writeValue:result forCharacteristic:mC2pCharacteristic type:CBCharacteristicWriteWithResponse];
            loop++;
        } while ((len-=BLEBLUETOOTH_SEND_BUFFER_MAX) > BLEBLUETOOTH_SEND_BUFFER_MAX);
        
        range = NSMakeRange(BLEBLUETOOTH_SEND_BUFFER_MAX*loop, remainder);
        UInt8 buf[range.length];
        memset(buf, 0, range.length);
        [sendData getBytes:buf range:range];
        NSData *result = [[NSData alloc] initWithBytes:buf length:sizeof(buf)];
        NSLog(@"write vaule: %@", result);
        [mDiscoveredPeripheral writeValue:result forCharacteristic:mC2pCharacteristic type:CBCharacteristicWriteWithResponse];
        
    }

}






#pragma mark - Central Methods


/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    NSLog(@"scan");
    [self.mCentralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TAXEIA_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@NO }];
    
    NSLog(@"Scanning started");
}


/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
        NSLog(@"centralManagerDidUpdateState");
    NSMutableString* nsmstring=[NSMutableString stringWithString:@"BleState:"];
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            [nsmstring appendString:@"Unknown\n"];
            break;
        case CBCentralManagerStateUnsupported:
            [nsmstring appendString:@"Unsupported\n"];
            break;
        case CBCentralManagerStateUnauthorized:
            [nsmstring appendString:@"Unauthorized\n"];
            break;
        case CBCentralManagerStateResetting:
            [nsmstring appendString:@"Resetting\n"];
            break;
        case CBCentralManagerStatePoweredOff:
            [nsmstring appendString:@"PoweredOff\n"];
            break;
        case CBCentralManagerStatePoweredOn:
            [nsmstring appendString:@"PoweredOn\n"];
            break;
        default:
            [nsmstring appendString:@"none\n"];
            break;
    }
    NSLog(@"%@",nsmstring);
    
}

/** This callback comes whenever a peripheral that is advertising the TAXEIA_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"didDiscoverPeripheral");
    /*
     // Reject any where the value is above reasonable range
     if (RSSI.integerValue > -15) {
     return;
     }
     
     // Reject if the signal strength is too low to be close enough (Close is around -22dB)
     if (RSSI.integerValue < -35) {
     return;
     }
     */
    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    
    // comment by milo
    // Stop scanning
    [self.mCentralManager stopScan];
    NSLog(@"Scanning stopped");
    //NSLog(@"Scanning is still go");
    
    // Ok, it's in range - have we already seen it?
    if (self.mDiscoveredPeripheral != peripheral) {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.mDiscoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.mCentralManager connectPeripheral:peripheral options:nil];
        
        //_label_status.text = @"Connecting...";
        //[_label_status setString:@"Connecting..."];
        NSLog(@"BT_Connecting...");
        
        
        
    }
}

/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral");
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
}

/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didConnectPeripheral");
    NSLog(@"Peripheral Connected");
    
    //_label_status.text = @"Peripheral Connected";
//    [_label_status setString:@"Peripheral Connected" ];
    NSLog(@"BT_Peripheral Connected");
//    [_button_scan setTitle:@"Disconnect" forState:UIControlStateNormal];
    [mButtonScan setTitle:@"Disconnect"];
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TAXEIA_SERVICE_UUID]]];
    
}


/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didDisconnectPeripheral");
    NSLog(@"Peripheral Disconnected");
    
    //_label_status.text = @"Peripheral Disconnected";
//    [_label_status setString:@"Peripheral Disconnected"];
    NSLog(@"BT_Peripheral Disconnected");
    
    //[_button_scan setTitle:@"Scan" forState:UIControlStateNormal];
    [mButtonScan setTitle:@"Scan"];
    
    self.mDiscoveredPeripheral = nil;
    self.mP2cCharacteristic = nil;
    self.mC2pCharacteristic = nil;
    
}

#pragma mark - Peripheral Delegate

/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{

    NSLog(@"didDiscoverServices");
    
    if (error) {
        
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }
    
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        
        // We are only interested in our proprietary service
        if([service.UUID isEqual:[CBUUID UUIDWithString:TAXEIA_SERVICE_UUID]]) {
            
            NSArray *characteristicArray = [NSArray arrayWithObjects:[CBUUID UUIDWithString:P2C_CHARACTERISTIC_UUID],
                                            [CBUUID UUIDWithString:C2P_CHARACTERISTIC_UUID],
                                            nil];
            
            [peripheral discoverCharacteristics:characteristicArray forService:service];
            
            break;
        }
    }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // If this characteristic is P2C, then we can subscribe to it.
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:P2C_CHARACTERISTIC_UUID]]) {
            
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            mP2cCharacteristic = characteristic;
        }
        
        // If this characteristic is C2P, save it for further use.
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:C2P_CHARACTERISTIC_UUID]]) {
            
            mC2pCharacteristic = characteristic;
        }
        
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didUpdateValueForCharacteristic");
    
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    // We are only interested in P2C characteristic.
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:P2C_CHARACTERISTIC_UUID]]) {
        // Show the data we are notified.
        
        NSData *receivedData = characteristic.value;
        
        NSLog(@"%d bytes received.", [receivedData length]);
        
        //NSString *buf;
        //buf = [[NSString alloc] initWithFormat:@"%d bytes received", [receivedData length]];
        
        //_label_status.text = buf;
//        [_label_status setString:buf];
        //NSLog(@"%@", buf);
        
        NSString *result = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        
        //_textview_result.text = result;
        
        [mTextviewResult setStringValue:result];
        //[self recvCommandFromBt:result];
    }
    
}

-(void) recvCommandFromBt:(NSString*)cmdStr {
//    cmdStr = [NSString stringWithFormat:@"[login]%@", cmdStr];
    //by pass command when peripheral is iPhone
    [[ClassA sharedInstance] recvCommandFromBt:cmdStr];
    //[[ClassA sharedInstance] sendCommandToChrome:cmdStr];
    
}



/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:P2C_CHARACTERISTIC_UUID]]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.mCentralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error didWriteValueForCharacteristic: %@", error.localizedDescription);
    }
    
}
@end
