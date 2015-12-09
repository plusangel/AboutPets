//
//  AppDelegate.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 15/12/11.
//  Copyright (c) 2011 plusangel@gmail.com. All rights reserved.
//

#import "AppDelegate.h"
#import "Pet.h"
#import "PetsViewController.h"
#import "SettingsViewController.h"
#import "Appointment.h"
#import "PetDetailsViewController.h"
#import "CalendarListViewController.h"
#import <EventKitUI/EventKitUI.h>

@interface AppDelegate ()
    @property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
    @property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
    @property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

    - (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@implementation AppDelegate
{
    PetsViewController *petsViewController;
    SettingsViewController *settingsViewController;
    UINavigationController *navigationController;
    NSMutableArray *arrayOfAppointments;
    EKEventStore *eventStore;
    dispatch_queue_t queue7;
}

@synthesize window = _window;
@synthesize managedObjectModel=_managedObjectModel, managedObjectContext=_managedObjectContext, persistentStoreCoordinator=_persistentStoreCoordinator;
@synthesize errorString;

+ (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)customizeAppearance
{  
    
    /*
    // UIToolbar
    UIImage *toolGradientImage44 = [[UIImage imageNamed:@"toolBar_44"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UIToolbar appearance] setBackgroundImage:toolGradientImage44 forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault]; 
    
    // UINavigationBar
    UIImage *naviGradientImage44 = [[UIImage imageNamed:@"navigationBar_44"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UINavigationBar appearance] setBackgroundImage:naviGradientImage44 forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor colorWithRed:0.0 green:120.0/255.0 blue:0.0 alpha:1.0], UITextAttributeTextColor, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset, [UIFont fontWithName:@"Avenir-Medium" size:0.0], UITextAttributeFont, nil]];
    
    // UIBarButtonItem
    UIImage *button30 = [[UIImage imageNamed:@"button_textured_30_new"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [[UIBarButtonItem appearance] setBackgroundImage:button30 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *buttonBack30 = [[UIImage imageNamed:@"button_back_textured_30_new"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 6)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack30 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:220.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], UITextAttributeTextColor, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, -1)], UITextAttributeTextShadowOffset, [UIFont fontWithName:@"Avenir-Medium" size:0.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
     
    // UISwitch
    id settingsSwitchAppearance = [UISwitch appearanceWhenContainedIn:[SettingsViewController class], nil];
    
    [settingsSwitchAppearance setOffImage:[UIImage imageNamed:@"stop"]];
    [settingsSwitchAppearance setOnImage:[UIImage imageNamed:@"talk"]];
    [settingsSwitchAppearance setOnTintColor:[UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0]];
    
    // UISegmentedControl
    UIImage *segmentSelected = [[UIImage imageNamed:@"segcontrol_sel"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    UIImage *segmentSelectedBig = [[UIImage imageNamed:@"segcontrol_sel_big"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 16, 10, 16)];
    
    UIImage *segmentUnselected = [[UIImage imageNamed:@"segcontrol_uns"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    UIImage *segmentUnselectedBig = [[UIImage imageNamed:@"segcontrol_uns_big"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 16, 10, 16)];
    
    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"segcontrol_divider"];
    UIImage *segmentSelectedUnselectedBig = [UIImage imageNamed:@"segcontrol_divider_big"];
    
    UIImage *segUnselectedSelected = [UIImage imageNamed:@"segcontrol_divider"];
    UIImage *segUnselectedSelectedBig = [UIImage imageNamed:@"segcontrol_divider_big"];
    
    UIImage *segUnselectedUnselected = [UIImage imageNamed:@"segcontrol_divider"];
    
    [[UISegmentedControl appearance] setBackgroundImage:segmentUnselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected forLeftSegmentState:UIControlStateSelected
                                   rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segUnselectedSelected forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segUnselectedUnselected forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:220.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], UITextAttributeTextColor, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset, [UIFont fontWithName:@"Avenir-Medium" size:0.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
    
    // make an exception for a specific viewController
    id bigSegmentedControlAppearance = [UISegmentedControl appearanceWhenContainedIn:[PetDetailsViewController class], nil];

    [bigSegmentedControlAppearance setBackgroundImage:segmentSelectedBig forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [bigSegmentedControlAppearance setBackgroundImage:segmentUnselectedBig forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [bigSegmentedControlAppearance setDividerImage:segmentSelectedUnselectedBig forLeftSegmentState:UIControlStateSelected
                                 rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [bigSegmentedControlAppearance setDividerImage:segUnselectedSelectedBig forLeftSegmentState:UIControlStateNormal
                                 rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    */
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    queue7 = dispatch_queue_create("com.plusangel.queue7", DISPATCH_QUEUE_SERIAL);
    
    NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaultPrefs" ofType:@"plist"];
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
    
    [self customizeAppearance];
    
    navigationController = (UINavigationController *)self.window.rootViewController;
    petsViewController = [[navigationController viewControllers] objectAtIndex:0];
    
    // Pass the managed object context to the view controller.
    petsViewController.managedObjectContext = [self managedObjectContext];
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self removePetFilesFromDocuments];
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self precheckForDeletedEvents];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

#pragma mark - Handle CoreData errors

- (void)presentError:(NSError *)error
                    WithText:(NSString *)text
{
    NSMutableString *localErrorString = [[NSMutableString alloc] init];
    
    [localErrorString appendFormat:@"%@ %@: %@", NSLocalizedString(@"Failed to", @"Failed String"), text, [error localizedDescription]];
    
    NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    //if(detailedErrors != nil && [detailedErrors count] > 0) {
    if(detailedErrors == nil) {
        for(NSError* detailedError in detailedErrors) {
            [localErrorString appendFormat:@"- %@: %@", NSLocalizedString(@"Detail", @"Detail string"), [detailedError userInfo]];
        }
    } else {
        [localErrorString appendFormat:@"- %@", [error userInfo]];
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Failed to", @"Fail String"), text]
                                                        message:NSLocalizedString(@"Please send a report to the developer.", @"Message to send a report to the developer.") 
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel String")
                                              otherButtonTitles:NSLocalizedString(@"Send Report", @"Sent report button title"), nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Failed to", @"Fail report title"), text]
                                                        message:NSLocalizedString(@"The application has to quit now.", @"Application has to quit String")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel String")
                                              otherButtonTitles:nil];
        [alert show];

    }
    self.errorString = localErrorString;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"Send Report"]) {  
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        NSArray *toRecipients = [NSArray arrayWithObject:@"support@rebelcatdev.com"];
        [picker setToRecipients:toRecipients];
        [picker setSubject:NSLocalizedString(@"Error Report", @"Subject of error report email") ];
        [picker setMessageBody:[NSString stringWithFormat:@"%@:<br><br><FONT FACE=%@> %@ </FONT>", 
                                NSLocalizedString(@"The application crashed with the following error", @"The error report email body of email"), @"courier", errorString]
                        isHTML:YES];
        
        [navigationController presentViewController:picker animated:YES completion:nil];
    } else if ([title isEqualToString:@"Cancel"]) {
        abort();
    }
}

#pragma mark - MFMailComposeViewControllerDelegate 

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [navigationController dismissViewControllerAnimated:YES completion:nil];
    NSMutableString *messageString = [[NSMutableString alloc] init];
    
    if (result == MFMailComposeResultSent) {
        [messageString appendFormat:@"Thanks! "];
        [messageString appendFormat:NSLocalizedString(@"The application has to quit now.", @"Application hato to quit String")];
        UIAlertView *abortAlert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:messageString
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        [abortAlert show];
    }
}

#pragma mark - Core Data stack

- (void)saveContext {
    NSError *error;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            [self presentError:error WithText:NSLocalizedString(@"save application's data", @"Core Data error message")];
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"myCats" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"myCats.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        [self presentError:error WithText:NSLocalizedString(@"add persistent store for core data", @"Persistent store error message")];
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
 
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Assistant methods

- (void)removePetFilesFromDocuments
{
    NSError *error;
    
    // get the documents folder of your sandbox
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *dirFiles;
    if ((dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error]) == nil) {
        [self presentError:error WithText:NSLocalizedString(@"access the sandbox", @"Access sandbox error message")];
    };
    
    // find the files with the extensions you want
    NSArray *pdfFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.pdf'"]];
    NSArray *pngFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"]];
    
    
    // loop on arrays and delete every file corresponds to specific filename
    for (NSString *fileName in pdfFiles) {
        if (![[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:fileName] error:&error]) {
            [self presentError:error WithText:NSLocalizedString(@"delete pdf files from sandbox", @"Delete pdf files error message")];
        }
    }
    for (NSString *fileName in pngFiles) {
        if (![[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:fileName] error:&error]) {
            [self presentError:error WithText:NSLocalizedString(@"delete png files from sandbox", @"Delete png files error message")];
        }
    }
}

- (EKEventStore *)eventStore
{
    if (!eventStore) {
        eventStore = [[EKEventStore alloc] init];
        
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (!granted) {
                [[AppDelegate appDelegate] presentError:error WithText: NSLocalizedString(@"access calendar", @"Error discription in accessing calendar")];
            }
        }];
    }
    return eventStore;
}


- (void)precheckForDeletedEvents
{
    NSMutableArray *myPetsArray;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    myPetsArray = mutableFetchResults;
    
    dispatch_async(queue7, ^{
        if (myPetsArray.count != 0) {
            [myPetsArray enumerateObjectsUsingBlock:^(id pobj, NSUInteger pidx, BOOL *pstop) {
                Pet *p = (Pet *)pobj;
                
                NSSet *appointmentsSet = [p appointment];
                
                arrayOfAppointments = [[NSMutableArray alloc] initWithArray:[appointmentsSet allObjects]];
                
                [arrayOfAppointments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString *appIdentifier = [(Appointment *)obj appointmentIdentifier];
                    
                    EKEvent *eventToEdit = [self.eventStore eventWithIdentifier:appIdentifier];
                    if (eventToEdit == nil) {
                        [p.managedObjectContext deleteObject:obj];
                        
                        NSError *error = nil;
                        if (![p.managedObjectContext save:&error]) {
                            [[AppDelegate appDelegate] presentError:error WithText:NSLocalizedString(@"save calendar data", @"Error discription for save calendar data")];
                        }
                    } else {
                        if ([eventToEdit.startDate compare:[(Appointment *)obj appointmentDate]] != NSOrderedSame) {
                            [(Appointment *)obj setAppointmentDate:eventToEdit.startDate];
                            
                            NSError *error = nil;
                            if (![p.managedObjectContext save:&error]) {
                                [[AppDelegate appDelegate] presentError:error WithText:NSLocalizedString(@"save calendar data", @"Error discription for save calendar data")];
                            }
                        }
                    }
                }];
            }];
        }
    });
}

@end
