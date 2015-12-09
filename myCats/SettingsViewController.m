//
//  SettingsViewController.m
//  myPets
//
//  Created by Agathangelos Plastropoulos on 6/7/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface SettingsViewController ()
    @property (weak, nonatomic) IBOutlet UISwitch *helpSwitch;
    @property (weak, nonatomic) IBOutlet UISegmentedControl *unitsSegmentedControl;
    @property (weak, nonatomic) IBOutlet UISegmentedControl *currencySegmentedControl;
    @property (weak, nonatomic) IBOutlet UIImageView *helpImageView;
@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    [self.unitsSegmentedControl setTitle:NSLocalizedString(@"Metric", @"Metic string for segmentedControl")  forSegmentAtIndex:0];
    [self.unitsSegmentedControl setTitle:NSLocalizedString(@"Imperial", @"Imperial string for segmentedControl")  forSegmentAtIndex:1];
    
    self.unitsSegmentedControl.selectedSegmentIndex = self.weightChoise;
    self.currencySegmentedControl.selectedSegmentIndex = self.currencyChoise;
    
    self.helpSwitch.on = self.helpStatus;
    
    NSString *locale = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    
    if ([locale isEqualToString:@"el"]) {
        self.helpImageView.image = [UIImage imageNamed:@"settingsHelpMessageEl.png"];
    } else {
        self.helpImageView.image = [UIImage imageNamed:@"settingsHelpMessage.png"];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:self.weightChoise forKey:@"weightUnit"];
    [defaults setInteger:self.currencyChoise forKey:@"currencyUnit"];
    [defaults setBool:self.helpStatus forKey:@"helpStatus"];
    [defaults synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[[self view] setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:250.0f/255.0f blue:234.0f/255.0f alpha:1.0f]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)setMassUnitValue:(id)sender
{
    UISegmentedControl *aSegmentedControl = sender;
    self.weightChoise = aSegmentedControl.selectedSegmentIndex;
    [self.delegate settingsViewController:self didChangeWeightUnit:self.weightChoise];
}

- (IBAction)setCurrencyUnitValue:(id)sender
{
    UISegmentedControl *aSegmentControl = sender;
    self.currencyChoise = aSegmentControl.selectedSegmentIndex;
    [self.delegate settingsViewController:self didChangeCurrencyUnit:self.currencyChoise];
}

- (IBAction)setHelpStatusValue:(id)sender
{
    UISwitch *aSwitch = sender;
    self.helpStatus = aSwitch.on;
    [self.delegate settingsViewController:self didChangeHelpStatus:self.helpStatus];
}

@end
