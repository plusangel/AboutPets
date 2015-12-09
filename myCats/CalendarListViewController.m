//
//  CalendarListViewController.m
//  myPets
//
//  Created by angelos plastropoulos on 2/2/13.
//  Copyright (c) 2013 plusangel@gmail.com. All rights reserved.
//

#import "CalendarListViewController.h"
#import "AppDelegate.h"
#import "Pet.h"
#import "Appointment.h"
#import "CalendarCell.h"
#import <EventKitUI/EventKitUI.h>

@interface CalendarListViewController () <UITableViewDelegate, UITableViewDataSource, EKEventEditViewDelegate>
    @property (weak, nonatomic) IBOutlet UITableView *calendarListTableView;
@end

@implementation CalendarListViewController
{
    EKEventStore *eventStore;
    NSMutableArray *appointmentsList;
    UIView *headerView;
    UIView *footerView;
    UIImageView *calendarHelpMessageAddImageView;
    UIImageView *calendarHelpMessageEditImageView;
    NSManagedObjectContext *context;
    dispatch_queue_t queue2;
    NSDateFormatter *dateFormatter;
}
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.calendarListTableView deselectRowAtIndexPath:self.calendarListTableView.indexPathForSelectedRow animated:NO];
    [self.calendarListTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIBarButtonItem *addEvent = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                              target:self action:@selector(addAppointment)];
    
    [[[self tabBarController] navigationItem] setRightBarButtonItem:addEvent animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[[self tabBarController] navigationItem] setRightBarButtonItem:nil animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    
    queue2 = dispatch_queue_create("com.plusangel.queue2", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue2, ^{
        
        appointmentsList = [NSMutableArray array];
        
        // Create the request for the therapy
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        context = self.pet.managedObjectContext;
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:context];
        [request setEntity:entity];
        
        // Set the sort descriptor
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"appointmentDate" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
        
        // Fetch therapy of the selected pet
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pet=%@", self.pet];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
        
        appointmentsList = mutableFetchResults;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.calendarListTableView reloadData];
            [self showHelp];
        });
    });
    
    UIEdgeInsets inset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.calendarListTableView.contentInset = inset;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - EKEventStore initialization

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return appointmentsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseID = @"my";
    
    CalendarCell *eventCell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    
    [self configureCell:eventCell atIndexPath:indexPath];
    
    return eventCell;
}

- (void)configureCell:(CalendarCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [[appointmentsList objectAtIndex:indexPath.row] appointmentIdentifier];
    
    EKEvent *event = [self.eventStore eventWithIdentifier:cellIdentifier];
    
    cell.appointmentTitleLabel.text = event.title;
    cell.appointmentDate.text = [dateFormatter stringFromDate:event.startDate];
    
    NSInteger difference = [self daysBetweenDate:event.startDate andDate:[NSDate date]];
    
    if (difference <= 0) {
        cell.calendarIconImageView.image = [UIImage imageNamed:@"calendarOrange"];
        //cell.backgroundView = [[CustomCalendarCell alloc] initWithColorMode:4];
    } else {
        cell.calendarIconImageView.image = [UIImage imageNamed:@"calendarBlue"];
        //cell.backgroundView = [[CustomCalendarCell alloc] initWithColorMode:1];
    }
}

// Override to support editing the table view.

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSError *error = nil;
        [context deleteObject:[appointmentsList objectAtIndex:indexPath.row]];
        
        Appointment *deleteAppointment = [appointmentsList objectAtIndex:indexPath.row];
        EKEvent *deleteEvent = [self.eventStore eventWithIdentifier:deleteAppointment.appointmentIdentifier];
        [self.eventStore removeEvent:deleteEvent span:EKSpanThisEvent error:&error];
        
        [appointmentsList removeObjectAtIndex:indexPath.row];
        
        if (![context save:&error]) {
            [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText: NSLocalizedString(@"save calendar data", @"Error discription for save calendar data")];
        }
        
        [self.calendarListTableView reloadData];
        [self showHelp];
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EKEventEditViewController *editEvent = [[EKEventEditViewController alloc] init];
    editEvent.eventStore = self.eventStore;
    
    Appointment *editAppointment = [appointmentsList objectAtIndex:indexPath.row];
    editEvent.event = [self.eventStore eventWithIdentifier:editAppointment.appointmentIdentifier];
    
    editEvent.editViewDelegate = self;
    [self presentViewController:editEvent animated:YES completion:nil];
}

#pragma mark - Calendar Methods

- (void)addAppointment
{
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    event.calendar = self.eventStore.defaultCalendarForNewEvents;
    
    event.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Appointment for", @"String for Appointment"), self.pet.name];
    event.location = NSLocalizedString(@"veterinarian", @"veterinarian String for Appointment");
    
    NSError *error = nil;
    [self.eventStore saveEvent:event span:EKSpanThisEvent commit:NO error:&error];
    
    EKEventEditViewController *editEvent = [[EKEventEditViewController alloc] init];
    editEvent.eventStore = self.eventStore;
    editEvent.event = event;
    editEvent.editViewDelegate = self;
    
    [self presentViewController:editEvent animated:YES completion:nil];
}

#pragma mark - EKEditEventControllerDelegate Methods

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    dispatch_async(queue2, ^{
        NSError *error = nil;
        EKEvent *thisEvent = controller.event;
        
        switch (action) {
            case EKEventEditViewActionSaved: {
                // edit existing appointment
                __block BOOL exists = NO;
                [appointmentsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    Appointment *app = (Appointment *)obj;
                    if ([app.appointmentIdentifier isEqualToString:thisEvent.eventIdentifier]) {
                        exists = YES;
                        Appointment *editApp = [appointmentsList objectAtIndex:idx];
                        editApp.appointmentDate = thisEvent.startDate;
                        *stop = YES;
                    }
                }];
                // add new appointment
                if (!exists) {
                    Appointment *newAppointment = [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:context];
                    newAppointment.pet = self.pet;
                    newAppointment.appointmentIdentifier = thisEvent.eventIdentifier;
                    newAppointment.appointmentDate = thisEvent.startDate;
                    [appointmentsList addObject:newAppointment];
                }
                
                if (![self.eventStore commit:&error]) {
                    [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText: NSLocalizedString(@"save calendar", @"Error discription for save calendar")];
                };
                
                break;
            }
            case EKEventEditViewActionCanceled: {
                [self.eventStore reset];
                break;
            }
            case EKEventEditViewActionDeleted: {
                // delete apointment
                [self.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
                [appointmentsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    Appointment *app = (Appointment *)obj;
                    if ([app.appointmentIdentifier isEqualToString:thisEvent.eventIdentifier]) {
                        [appointmentsList removeObjectAtIndex:idx];
                        [context deleteObject:app];
                        *stop = YES;
                    }
                }];
                break;
            }
            default:
                break;
        }
        
        // sort appointment list
        NSArray *sortedArray;
        sortedArray = [appointmentsList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDate *first = [(Appointment *)obj1 appointmentDate];
            NSDate *second = [(Appointment *)obj2 appointmentDate];
            return [second compare:first];
        }];
        
        appointmentsList = [(NSArray *)sortedArray mutableCopy];
        //self.pet.lastAppointment = [[self.appointmentsList objectAtIndex:0] appointmentDate];
        
        
        if (![context save:&error]) {
            [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText: NSLocalizedString(@"save calendar data", @"Error discription for save calendar data")];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.calendarListTableView reloadData];
            [self showHelp];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

#pragma mark - Assistant Methods

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
    
    if (self.helpStatus == YES) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 120.0)];
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 120.0)];
        
        if ([appointmentsList count] == 0) {
            calendarHelpMessageAddImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self localizeHelpMessages:@"calendarHelpMessageAdd.png" forLanguage:locale]]];
            [headerView addSubview:calendarHelpMessageAddImageView];
            self.calendarListTableView.tableHeaderView = headerView;
        } else if (self.calendarListTableView.tableHeaderView) {
            self.calendarListTableView.tableHeaderView = nil;
        }
        
        if ([appointmentsList count] == 1 || [appointmentsList count] == 2) {
            calendarHelpMessageEditImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self localizeHelpMessages:@"calendarHelpMessageEdit.png" forLanguage:locale]]];
            [footerView addSubview:calendarHelpMessageEditImageView];
            self.calendarListTableView.tableFooterView = footerView;
        } else if (self.calendarListTableView.tableFooterView) {
            self.calendarListTableView.tableFooterView = nil;
        }
    } else {
        if (self.calendarListTableView.tableHeaderView) {
            self.calendarListTableView.tableHeaderView = nil;
        }
        if (self.calendarListTableView.tableFooterView) {
            self.calendarListTableView.tableFooterView = nil;
        }
    }
}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

@end
