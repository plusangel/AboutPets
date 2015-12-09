//
//  AppDelegate.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 15/12/11.
//  Copyright (c) 2011 plusangel@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *errorString;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)presentError:(NSError *)error WithText:(NSString *)text;

@end
