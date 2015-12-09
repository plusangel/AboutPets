//
//  TherapyViewController.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 26/3/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import "TherapyListViewController.h"
#import "Pet.h"
#import "Therapy.h"
#import "TherapyCell.h"
#import "AppDelegate.h"
#import "TherapyDetailsViewController.h"

@interface TherapyListViewController () <DetailsTherapyViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>
    @property (weak, nonatomic) IBOutlet UITableView *therapiesListTableView;
@end

@implementation TherapyListViewController
{
    NSManagedObjectContext *context;
    NSMutableArray *therapiesArray;
    
    UIView *headerView;
    UIView *footerView;
    UIImageView *therapyHelpMessageAddImageView;
    UIImageView *therapyHelpMessageEditImageView;
    BOOL _hideTabBar;
    
    NSDateFormatter *dateFormatter;
    UIEdgeInsets inset;
    
    dispatch_queue_t queue3;
}
/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    queue3 = dispatch_queue_create("com.plusangel.queue3", nil);
    inset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    
    // Create the request for the therapy
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    context = self.pet.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Therapy" inManagedObjectContext:context];
    [request setEntity:entity];
    
    // Set the sort descriptor
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateOfTherapy" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    // Fetch therapy of the selected pet
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pet=%@", self.pet];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    
    therapiesArray = mutableFetchResults;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showHelp];
    
    self.therapiesListTableView.contentInset = inset;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTherapyRecord)];
    [[[self tabBarController] navigationItem] setRightBarButtonItem:add animated:YES];
    
    self.therapiesListTableView.contentInset = inset;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[[self tabBarController] navigationItem] setRightBarButtonItem:nil animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [therapiesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseID = @"myCell";
    
    TherapyCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(TherapyCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Therapy *therapy = [therapiesArray objectAtIndex:indexPath.row];
    
    cell.priceLabel.text = [NSString stringWithFormat:@"%@ %@", [therapy.price  stringValue], [self currencySymbol:self.currencyUnit]];
    
    cell.therapyLabel.text = therapy.therapyType;
    
    cell.dateLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"on", @"on String"), [dateFormatter stringFromDate:therapy.dateOfTherapy]];
    
    cell.theparyTypeImageView.image = [self selectTherapyImageFor:therapy.therapyType];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object at the given index path
        Therapy *therapy = [therapiesArray objectAtIndex:indexPath.row];
        [context deleteObject:therapy];
        
        [therapiesArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSError *error = nil;
        if (![context save:&error]) {
            [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText:NSLocalizedString(@"delete the therapy", @"Error description about deleting the therapy") ]; 
        }
        
        [self.therapiesListTableView reloadData];
        [self showHelp];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - PrepareForSegue

- (void)addTherapyRecord
{
    [self performSegueWithIdentifier:@"AddTherapy" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddTherapy"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        TherapyDetailsViewController *addTherapyViewController = [[navigationController viewControllers] objectAtIndex:0];
        addTherapyViewController.delegate = self;
        addTherapyViewController.currencyUnit = self.currencyUnit;
        
        addTherapyViewController.therapy = (Therapy *)[NSEntityDescription insertNewObjectForEntityForName:@"Therapy"inManagedObjectContext:context];
         
        addTherapyViewController.isEditing = NO;
        addTherapyViewController.helpStatus = self.helpStatus;
        
    } else if ([segue.identifier rangeOfString:@"EditTherapy"].location != NSNotFound) {
        UINavigationController *navigationController = segue.destinationViewController;
        TherapyDetailsViewController *therapyDetailsViewController = [[navigationController viewControllers] objectAtIndex:0];
        therapyDetailsViewController.delegate = self;
        therapyDetailsViewController.currencyUnit = self.currencyUnit;
        
        NSIndexPath *indexPath = [self.therapiesListTableView indexPathForCell:sender];
        Therapy *therapy = [therapiesArray objectAtIndex:indexPath.row];
        
        therapyDetailsViewController.therapy = therapy;
        therapyDetailsViewController.isEditing = YES;
        therapyDetailsViewController.helpStatus = self.helpStatus;
    }
    
}

#pragma mark - Assistant Methods

- (NSString *)currencySymbol:(NSInteger )choise
{
    if (self.currencyUnit == 0) {
        return @"€";
    } else if (self.currencyUnit == 1) {
        return @"$";
    } else {
        return @"£";
    }
}

- (UIImage *)selectTherapyImageFor:(NSString *)therapyType
{
    if ([therapyType isEqualToString:@"Treatments"] || [therapyType isEqualToString:@"Θεραπευτική αγωγή"]) {
        return [UIImage imageNamed:@"therapyViewTreatments"];
    } else if ([therapyType isEqualToString:@"Primary Vaccination"] || [therapyType isEqualToString:@"Πρώτος εμβολιασμός"]) {
        return [UIImage imageNamed:@"therapyViewPrimaryVac"];
    } else if ([therapyType isEqualToString:@"Revaccination"] || [therapyType isEqualToString:@"Επαναληπτικός εμβολιασμός"]) {
        return [UIImage imageNamed:@"therapyViewReVac"];
    }  else {
        return [UIImage imageNamed:@"therapyViewVermifugation"];
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
    
    if (self.helpStatus == YES) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 120.0)];
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 120.0)];
        
        if ([therapiesArray count] == 0) {
            therapyHelpMessageAddImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self localizeHelpMessages:@"therapyHelpMessageAdd.png" forLanguage:locale]]];
            [headerView addSubview:therapyHelpMessageAddImageView];
            self.therapiesListTableView.tableHeaderView = headerView;
        } else if (self.therapiesListTableView.tableHeaderView) {
            self.therapiesListTableView.tableHeaderView = nil;
        }
        
        if ([therapiesArray count] == 1 || [therapiesArray count] == 2) {
            therapyHelpMessageEditImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self localizeHelpMessages:@"therapyHelpMessageEdit.png" forLanguage:locale]]];
            [footerView addSubview:therapyHelpMessageEditImageView];
            self.therapiesListTableView.tableFooterView = footerView;
        } else if (self.therapiesListTableView.tableFooterView) {
            self.therapiesListTableView.tableFooterView = nil;
        }
    } else {
        if (self.therapiesListTableView.tableHeaderView) {
            self.therapiesListTableView.tableHeaderView = nil;
        }
        if (self.therapiesListTableView.tableFooterView) {
            self.therapiesListTableView.tableFooterView = nil;
        }
    }
}

#pragma mark - DetailsTherapyViewControllerDelegate Methods

- (void)detailsTherapyViewController:(TherapyDetailsViewController *)controller didSave:(Therapy *)therapyToAdd
{
    [therapyToAdd setPet:self.pet];
    [therapiesArray addObject:therapyToAdd];
        
    NSError *error = nil;
    if (![context save:&error]) {
        [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText:NSLocalizedString(@"add a new therapy", @"Error description in adding a new therapy")];
    }

    dispatch_async(queue3, ^{
        NSArray *datesArray = [therapiesArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDate *first = [(Therapy *)obj1 dateOfTherapy];
            NSDate *second = [(Therapy *)obj2 dateOfTherapy];
            return [second compare:first];
        }];
        
        therapiesArray = [(NSArray *)datesArray mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.therapiesListTableView reloadData];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (void)detailsTherapyViewController:(TherapyDetailsViewController *)controller didEdit:(Therapy *)therapyToEdit
{
    dispatch_async(queue3, ^{
        NSArray *datesArray = [therapiesArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDate *first = [(Therapy *)obj1 dateOfTherapy];
            NSDate *second = [(Therapy *)obj2 dateOfTherapy];
            return [second compare:first];
        }];
        therapiesArray = [(NSArray *)datesArray mutableCopy];
    });
    
    [self.therapiesListTableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)detailsTherapyViewController:(TherapyDetailsViewController *)controller didDelete:(Therapy *)therapyToDelete
{
    NSUInteger index = [therapiesArray indexOfObject:therapyToDelete];
    [therapiesArray removeObjectAtIndex:index];
    
    dispatch_async(queue3, ^{
        NSArray *datesArray = [therapiesArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDate *first = [(Therapy *)obj1 dateOfTherapy];
            NSDate *second = [(Therapy *)obj2 dateOfTherapy];
            return [second compare:first];
        }];
        therapiesArray = [(NSArray *)datesArray mutableCopy];
    });
    
    [self.therapiesListTableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)detailsTherapyViewControllerDidCancel:(TherapyDetailsViewController *)controller
{
    [self.therapiesListTableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
