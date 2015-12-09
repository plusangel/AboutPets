//
//  SettingsViewController.h
//  myPets
//
//  Created by Agathangelos Plastropoulos on 6/7/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

@class SettingsViewController;

@protocol SettingsViewControllerDelegate <NSObject>
- (void)settingsViewController:(SettingsViewController *)controller didChangeWeightUnit:(NSInteger)choise;
- (void)settingsViewController:(SettingsViewController *)controller didChangeCurrencyUnit:(NSInteger)choise;
- (void)settingsViewController:(SettingsViewController *)controller didChangeHelpStatus:(BOOL)status;
@end

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) id <SettingsViewControllerDelegate> delegate;
@property (assign, nonatomic) NSInteger weightChoise;
@property (assign, nonatomic) NSInteger currencyChoise;
@property (assign, nonatomic) BOOL helpStatus;

@end
