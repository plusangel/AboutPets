//
//  CatsViewController.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 15/12/11.
//  Copyright (c) 2011 plusangel@gmail.com. All rights reserved.
//

#import "PetsViewController.h"
#import "Pet.h"
#import "PetCell.h"
#import "AppDelegate.h"
#import "WeightPlotViewController.h"
#import "CalendarListViewController.h"
#import "TherapyListViewController.h"
#import "Appointment.h"
#import "PetDetailsViewController.h"
#import "WeightPlotViewController.h"
#import "SettingsViewController.h"
#import "ShowPetDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <EventKitUI/EventKitUI.h>

NSString *const REUSE_ID_TOPSINGLE = @"TopSingleRow";
NSString *const REUSE_ID_OTHER = @"OtherRow";

@interface PetsViewController () <PetDetailsViewControllerDelegate,  NSFetchedResultsControllerDelegate, SettingsViewControllerDelegate, ShowPetDetailsViewControllerDelegate>

@end

@implementation PetsViewController
{
    NSMutableArray *myPetsArray;
    NSMutableArray *arrayOfAppointments;
    
    NSInteger weightUnit;
    NSInteger currencyUnit;
    BOOL helpStatus;
    
    EKEventStore *eventStore;
    dispatch_queue_t queue6;
    
    UIImageView *myPetsHelpAddMessageImageView;
    UIImageView *myPetsHelpEditMessageImageView;
    UIImageView *myTitleImage;
    UIView *headerView;
    UIView *footerView;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    myTitleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home"]];
    self.navigationItem.titleView = myTitleImage;
    
    queue6 = dispatch_queue_create("com.plusangel.queue6", DISPATCH_QUEUE_SERIAL);
    
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptos = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptos];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    myPetsArray = mutableFetchResults;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    weightUnit = [defaults integerForKey:@"weightUnit"];
    currencyUnit = [defaults integerForKey:@"currencyUnit"];
    helpStatus = [defaults boolForKey:@"helpStatus"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showHelp];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Customization methods

- (NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
    NSInteger rowIndex = indexPath.row;
    
    if (rowCount == 1 || rowIndex == 0)
    {
        return REUSE_ID_TOPSINGLE;
    }
    
    return REUSE_ID_OTHER;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
    NSInteger rowIndex = indexPath.row;
    
    if (rowCount == 1 || rowIndex == 0) {
        return 70.0;
    }
    
    return 70.0;
}

- (UIImage *)backgroundImageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseID = [self reuseIdentifierForRowAtIndexPath:indexPath];
    if ([REUSE_ID_TOPSINGLE isEqualToString:reuseID] == YES)
    {
        UIImage *background = [UIImage imageNamed:@"petCellSingleTop.png"];
        return background;
    } else {
        if (indexPath.row%2 == 0) {
            UIImage *background = [UIImage imageNamed:@"petCellOther1.png"];
            return background;
        } else {
            UIImage *background = [UIImage imageNamed:@"petCellOther2.png"];
            return background;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [myPetsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseID = [self reuseIdentifierForRowAtIndexPath:indexPath];
    
    PetCell *cell = (PetCell *)[tableView dequeueReusableCellWithIdentifier:reuseID];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(PetCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Configure Cell
    Pet *pet = [myPetsArray objectAtIndex:indexPath.row];
    cell.nameLabel.textColor = (pet.sex?[UIColor colorWithRed:249.0/255.0 green:66.0/255.0 blue:95.0/255.0 alpha:1.0]:
                                [UIColor colorWithRed:0.0 green:118.0/255.0 blue:204.0/255.0 alpha:1.0]);
    cell.nameLabel.text = pet.name;
    cell.breedLabel.text = pet.breed;
    if (pet.thumbnail != nil) {
        cell.petImageView.contentMode =  UIViewContentModeScaleToFill;
        cell.petImageView.image = pet.thumbnail;
        cell.petImageView.translatesAutoresizingMaskIntoConstraints = NO;
        cell.petImageView.clipsToBounds = YES;
        cell.petImageView.layer.cornerRadius = cell.petImageView.frame.size.height/2;//5.0f;
    } else {
        cell.petImageView.contentMode = UIViewContentModeScaleAspectFit;
        if (pet.kind == NO) {
            cell.petImageView.image = [UIImage imageNamed:@"cat_avatar.png"];
        } else {
            cell.petImageView.image = [UIImage imageNamed:@"dog_avatar.png"];
        }
    }
    
    CGRect cellRect = [cell frame];
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:cellRect];
    [backgroundView setImage:[self backgroundImageForRowAtIndexPath:indexPath]];
    [cell setBackgroundView:backgroundView];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if (self.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"EditPet" sender:indexPath];
    
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddPet"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        PetDetailsViewController *petDetailsViewController = [[navigationController viewControllers] objectAtIndex:0];
        petDetailsViewController.delegate = self;
        petDetailsViewController.isEditing = NO;
        petDetailsViewController.weightUnit = weightUnit;
        petDetailsViewController.context = self.managedObjectContext;
        
    } else if ([segue.identifier isEqualToString:@"EditPet"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        PetDetailsViewController *petDetailsViewController = [[navigationController viewControllers] objectAtIndex:0];
        petDetailsViewController.delegate = self;
        petDetailsViewController.isEditing = YES;
        petDetailsViewController.weightUnit = weightUnit;
        petDetailsViewController.context = self.managedObjectContext;
        
        NSIndexPath *indexPath = sender;
        Pet *pet = [myPetsArray objectAtIndex:indexPath.row];
        petDetailsViewController.pet = pet;
    } else if ([segue.identifier rangeOfString:@"ShowPet"].location != NSNotFound) {
        UITabBarController *tabBarController = segue.destinationViewController;
        [[tabBarController tabBar] setSelectedImageTintColor:[UIColor colorWithRed:61.0/255.0 green:155.0/255.0 blue:53.0/255.0 alpha:1.0]];
        
        ShowPetDetailsViewController *showPetDetailViewController = [[tabBarController viewControllers] objectAtIndex:0];
        WeightPlotViewController *weightPlotViewController = [[tabBarController viewControllers] objectAtIndex:1];
        CalendarListViewController *calendarListViewController = [[tabBarController viewControllers] objectAtIndex:3];
        TherapyListViewController *therapyViewController = [[tabBarController viewControllers] objectAtIndex:2];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Pet *pet = [myPetsArray objectAtIndex:indexPath.row];
        
        showPetDetailViewController.pet = pet;
        showPetDetailViewController.delegate = self;
        showPetDetailViewController.weightUnit = weightUnit;

        weightPlotViewController.pet = pet;
        weightPlotViewController.weightUnit = weightUnit;
        weightPlotViewController.helpStatus = helpStatus;
        
        calendarListViewController.pet = pet;
        calendarListViewController.helpStatus = helpStatus;
        
        therapyViewController.pet = pet;
        therapyViewController.currencyUnit = currencyUnit;
        therapyViewController.helpStatus = helpStatus;
    } else if ([segue.identifier isEqualToString:@"Settings"]) {
        SettingsViewController *settingsViewController = segue.destinationViewController;
        settingsViewController.delegate = self;
        settingsViewController.weightChoise = weightUnit;
        settingsViewController.currencyChoise = currencyUnit;
        settingsViewController.helpStatus = helpStatus;
    }
}

#pragma mark - IBActions

- (IBAction)accessoryButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath != nil) {
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

#pragma mark - SettingsViewControllerDelegate Methods

- (void)settingsViewController:(SettingsViewController *)controller didChangeWeightUnit:(NSInteger)choise
{
    weightUnit = choise;
    [self.navigationController popToViewController:controller animated:YES];
}

- (void)settingsViewController:(SettingsViewController *)controller didChangeCurrencyUnit:(NSInteger)choise
{
    currencyUnit = choise;
    [self.navigationController popToViewController:controller animated:YES];
}

- (void)settingsViewController:(SettingsViewController *)controller didChangeHelpStatus:(BOOL)status
{
    helpStatus = status;
    [self.navigationController popToViewController:controller animated:YES];
}

#pragma mark - ShowPetDetailsViewControllerDelegate Methods
- (void)showPetDetailsViewController:(ShowPetDetailsViewController *)controller remove:(Pet *)removePet
{
    dispatch_async(queue6, ^{
        [self deleteEventsForRemovedPet:removePet];
        [myPetsArray removeObject:removePet];
        [_managedObjectContext deleteObject:removePet];
        
        NSError *error = nil;
        if (![_managedObjectContext save:&error]) {
            [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText:NSLocalizedString(@"remove pet", @"Error description in removing the pet")];
        }
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

#pragma mark - PetDetailsViewControllerDelegate Methods

- (void)petDetailsViewControllerDidCancel:(PetDetailsViewController *)controller withRemovingDummyPet:(Pet *)dummyPet
{
    if (dummyPet) {
        [_managedObjectContext deleteObject:dummyPet];
        
        NSError *error = nil;
        if (![_managedObjectContext save:&error]) {
            [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText:NSLocalizedString(@"remove pet", @"Error description in removing the pet")];
        }

    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)petDetailsViewController:(PetDetailsViewController *)controller didAddPet:(Pet *)addPet
{
    [myPetsArray addObject:addPet];
    
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText:NSLocalizedString(@"add a new pet", @"Error description in adding a pet")];
    }
    
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)petDetailsViewController:(PetDetailsViewController *)controller didEditPet:(Pet *)editPet
{
    NSUInteger index = [myPetsArray indexOfObject:editPet];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText:NSLocalizedString(@"edit a pet", @"Error description in editing a pet")];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Assistant methods

- (EKEventStore *)eventStore
{
    if (!eventStore) {
        eventStore = [[EKEventStore alloc] init];
        
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (!granted) {
                [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText: NSLocalizedString(@"access calendar", @"Error discription in accessing calendar")];
            }
        }];
    }
    return eventStore;
}

- (void)deleteEventsForRemovedPet:(Pet *)removedPet
{
    NSMutableArray *appointmentsList = [NSMutableArray array];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"appointmentDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pet=%@", removedPet];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    appointmentsList = mutableFetchResults;
    
    if (appointmentsList.count != 0) {
        [appointmentsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *appIdentifier = [(Appointment *)obj appointmentIdentifier];
            NSError *error = nil;
            
            if ([self.eventStore eventWithIdentifier:appIdentifier]) {
                if ([self.eventStore removeEvent:[self.eventStore eventWithIdentifier:appIdentifier] span:EKSpanThisEvent error:&error] == NO) {
                    [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText:NSLocalizedString(@"delete calendar data", @"Error discription for deleting calendar data")];
            
                }
            }
        }];
    }
}

- (NSString *)localizeHelpMessages:(NSString *)message forLanguage:(NSString *)locale
{
    if ([locale isEqualToString:@"el"])
        return [NSString stringWithFormat:@"%@%@.png", [message stringByDeletingPathExtension], @"El"];
    else
        return message;
}

- (void)showHelp
{
    NSString *locale = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
   
    if (helpStatus == YES) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 120.0)];
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 120.0)];
        
        if ([myPetsArray count] == 0) {
            myPetsHelpAddMessageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self localizeHelpMessages:@"myPetsHelpMessageAdd.png" forLanguage:locale]]];
            [headerView addSubview:myPetsHelpAddMessageImageView];
            self.tableView.tableHeaderView = headerView;
        } else if (self.tableView.tableHeaderView) {
            self.tableView.tableHeaderView = nil;
        }
        
        if ([myPetsArray count] == 1 || [myPetsArray count] == 2) {
            myPetsHelpEditMessageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self localizeHelpMessages:@"myPetsHelpMessageEdit.png" forLanguage:locale]]];
            [footerView addSubview:myPetsHelpEditMessageImageView];
            self.tableView.tableFooterView = footerView;
        } else if (self.tableView.tableFooterView) {
            self.tableView.tableFooterView = nil;
        }
    } else {
        if (self.tableView.tableHeaderView) {
            self.tableView.tableHeaderView = nil;
        }
        if (self.tableView.tableFooterView) {
            self.tableView.tableFooterView = nil;
        }
    }
}

@end
