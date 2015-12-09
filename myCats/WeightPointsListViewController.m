//
//  weightPointsListViewController.m
//  myPets
//
//  Created by angelos plastropoulos on 12/29/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import "WeightPointsListViewController.h"
#import "Pet.h"
#import "WeightPointCell.h"
#import "WeightPoint.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "WeightPointDetailViewController.h"

NSString *const REUSE_ID_MIDDLE_A = @"middlea";

@interface WeightPointsListViewController () <UITableViewDelegate, UITableViewDataSource, WeightPointViewControllerDelegate>
    @property (weak, nonatomic) IBOutlet UITableView *weightPointsListTableView;
    @property (weak, nonatomic) IBOutlet UIButton *weightGuideButton;
@end

@implementation WeightPointsListViewController
{
    NSMutableArray *newArrayOfPoints;
    NSManagedObjectContext *context;
    UIView *headerView;
    UIView *footerView;
    UIImageView *weightPointsHelpMessageAddImageView;
    UIImageView *weightPointsHelpMessageEditImageView;
    NSNumberFormatter *numberFormatter;
    NSDateFormatter *dateFormatter;
    dispatch_queue_t queue;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    
    if (numberFormatter == nil) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setDecimalSeparator:@"."];
    }
    
    
    [self.weightGuideButton setImage:[UIImage imageNamed:@"booksButton"] forState:UIControlStateNormal];
    [self.weightGuideButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [self.weightGuideButton setTitle:NSLocalizedString(@"read the weight guide", @"weight guide title button")  forState:UIControlStateNormal];
    self.weightGuideButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    [self.weightGuideButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
    self.title = NSLocalizedString(@"weight", @"Pet's weight String");
    queue = dispatch_queue_create("com.plusangel.queue",nil);
    
    if (self.pet.weight != nil) {
        newArrayOfPoints = [NSKeyedUnarchiver unarchiveObjectWithData:self.pet.weight];
    }
    
    context = self.pet.managedObjectContext;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showHelp];
}

#pragma mark - Customization methods
/*
- (NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowCount = [newArrayOfPoints count];
    NSInteger rowIndex = indexPath.row;
    
    if (rowCount == 1 || rowIndex == 0) {
        return REUSE_ID_SINGLETOP_A;
    }
    
    return REUSE_ID_MIDDLE_A;
}

- (UIImage *)backgroundImageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseID = [self reuseIdentifierForRowAtIndexPath:indexPath];
    
    if ([REUSE_ID_SINGLETOP_A isEqualToString:reuseID] == YES) {
        UIImage *background = [UIImage imageNamed:@"table_cell_b_singletop.png"];
        return [background resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 30.0, 0.0, 30.0)];
    } else {
        UIImage *background = [UIImage imageNamed:@"table_cell_b_middle.png"];
        return [background resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 30.0, 0.0, 30.0)];
    }
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [newArrayOfPoints count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseID = @"middlea";
    
    WeightPointCell *cell = (WeightPointCell *)[tableView dequeueReusableCellWithIdentifier:reuseID];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(WeightPointCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WeightPoint *weightPoint = [newArrayOfPoints objectAtIndex:indexPath.row];
    
    cell.dateLabel.text = [dateFormatter stringFromDate:weightPoint.date];
    cell.dateLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    
    cell.weightLabel.text = [NSString stringWithFormat:@"%@ %@", [weightPoint.weight stringValue], (self.weightUnit?@"lb":@"kg")];
    cell.weightLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    
    cell.weightSign.image = [self getWeightSignFor:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [newArrayOfPoints removeObjectAtIndex:indexPath.row];
        
        [self saveArrayOfWeightPoints];
        [self showHelp];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - Assistant methods

- (UIImage *)getWeightSignFor:(NSUInteger )index
{
    UIImage *weightSign;
    WeightPoint *currentPoint;
    WeightPoint *nextPoint;
                    
    if (index == (newArrayOfPoints.count - 1)) {
        weightSign = [UIImage imageNamed:@"weightNew"];
    } else {
        currentPoint = newArrayOfPoints[index];
        nextPoint = newArrayOfPoints[index + 1];
        if ([currentPoint.weight compare:nextPoint.weight] == NSOrderedDescending) {
            weightSign = [UIImage imageNamed:@"weightUp"];
        } else if ([currentPoint.weight compare:nextPoint.weight] == NSOrderedAscending) {
            weightSign = [UIImage imageNamed:@"weightDown"];
        } else {
            weightSign = [UIImage imageNamed:@"weightLine"];
        }
    }
    return weightSign;
}


- (void)saveArrayOfWeightPoints
{
    
    dispatch_async(queue, ^{
        NSArray *sortedArray;
        sortedArray = [newArrayOfPoints sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDate *first = [(WeightPoint *)obj1 date];
            NSDate *second = [(WeightPoint *)obj2 date];
            return [second compare:first];
        }];
        
        newArrayOfPoints = [(NSArray *)sortedArray mutableCopy];
        self.pet.weight = [NSKeyedArchiver archivedDataWithRootObject:newArrayOfPoints];
        // commit the changes
        NSError *error = nil;
        if (![context save:&error]) {
            [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText: NSLocalizedString(@"save weight data", @"Error discription for save weight data")];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.weightPointsListTableView reloadData];
        });
    });
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
        
        if ([newArrayOfPoints count] == 0) {
            weightPointsHelpMessageAddImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self localizeHelpMessages:@"weightPointHelpMessageAdd.png" forLanguage:locale]]];
            [headerView addSubview:weightPointsHelpMessageAddImageView];
            self.weightPointsListTableView.tableHeaderView = headerView;
        } else if (self.weightPointsListTableView.tableHeaderView) {
            self.weightPointsListTableView.tableHeaderView = nil;
        }
        if (newArrayOfPoints.count == 1 || newArrayOfPoints.count == 2) {
            weightPointsHelpMessageEditImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self localizeHelpMessages:@"weightPointHelpMessageEdit.png" forLanguage:locale]]];
            [footerView addSubview:weightPointsHelpMessageEditImageView];
            self.weightPointsListTableView.tableFooterView = footerView;
        } else if (self.weightPointsListTableView.tableFooterView) {
            self.weightPointsListTableView.tableFooterView = nil;
        }
    } else {
        if (self.weightPointsListTableView.tableHeaderView) {
            self.weightPointsListTableView.tableHeaderView = nil;
        }
        if (self.weightPointsListTableView.tableFooterView) {
            self.weightPointsListTableView.tableFooterView = nil;
        }
    }
}

#pragma mark - WeightPointViewControllerDelegate Methods

- (void)weightPointViewControllerDidCancel:(WeightPointDetailViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)weightPointViewController:(WeightPointDetailViewController *)controller didSave:(WeightPoint *)weightPoint
{
    if (newArrayOfPoints == nil) {
        newArrayOfPoints = [NSMutableArray array];
    }
    
    [newArrayOfPoints addObject:weightPoint];
    [self saveArrayOfWeightPoints];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)weightPointViewController:(WeightPointDetailViewController *)controller didEdit:(WeightPoint *)weightPoint
{
    NSUInteger index = [newArrayOfPoints indexOfObject:weightPoint];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self.weightPointsListTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self saveArrayOfWeightPoints];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier rangeOfString:@"WeightPoint"].location != NSNotFound) {
        // Edit WeightPoint
        UINavigationController *navigationController = segue.destinationViewController;
        WeightPointDetailViewController *weightPointViewController = [[navigationController viewControllers] objectAtIndex:0];
        weightPointViewController.delegate = self;
        
        NSIndexPath *indexPath = [self.weightPointsListTableView indexPathForCell:sender];
        WeightPoint *weightPoint = [newArrayOfPoints objectAtIndex:indexPath.row];
        
        if ([newArrayOfPoints count] > 2) {
            if (indexPath.row == [newArrayOfPoints count] - 1) {
                WeightPoint *point2 = [newArrayOfPoints objectAtIndex:(indexPath.row - 1)];
                weightPointViewController.nextDate = point2.date;
                weightPointViewController.previousDate = nil;
            } else if (indexPath.row == 0){
                weightPointViewController.nextDate = nil;
                WeightPoint *point1 = [newArrayOfPoints objectAtIndex:(indexPath.row + 1)];
                weightPointViewController.previousDate = point1.date;
            } else {
                WeightPoint *point1 = [newArrayOfPoints objectAtIndex:(indexPath.row + 1)];
                weightPointViewController.previousDate = point1.date;
                WeightPoint *point2 = [newArrayOfPoints objectAtIndex:(indexPath.row - 1)];
                weightPointViewController.nextDate = point2.date;
            }
        } else if ([newArrayOfPoints count] == 2) {
            if (indexPath.row == 0) {
                WeightPoint *point = [newArrayOfPoints objectAtIndex:(indexPath.row + 1)];
                weightPointViewController.nextDate = nil;
                weightPointViewController.previousDate = point.date;
            } else {
                WeightPoint *point = [newArrayOfPoints objectAtIndex:(indexPath.row - 1)];
                weightPointViewController.nextDate = point.date;
                weightPointViewController.previousDate = nil;
            }
        } else {
            weightPointViewController.previousDate = nil;
            weightPointViewController.nextDate = nil;
        }
        
        weightPointViewController.weightPoint = weightPoint;
        weightPointViewController.weightUnit = self.weightUnit;
        weightPointViewController.isEditing = YES;
        weightPointViewController.helpStatus = self.helpStatus;
    } else if ([segue.identifier isEqualToString:@"AddNewPoint"]) {
        
        //Add weightPoint
        UINavigationController *navigationController = segue.destinationViewController;
        WeightPointDetailViewController *weightPointViewController = [[navigationController viewControllers] objectAtIndex:0];
        
        if ([newArrayOfPoints count] > 0) {
            WeightPoint *point = [newArrayOfPoints lastObject];
            weightPointViewController.previousDate = point.date;
        }
        
        weightPointViewController.delegate = self;
        weightPointViewController.weightUnit = self.weightUnit;
        weightPointViewController.isEditing = NO;
        weightPointViewController.helpStatus = self.helpStatus;
    } else if ([segue.identifier isEqualToString:@"weightGuide"]) {
        RootViewController *weightGuideViewController = segue.destinationViewController;
        weightGuideViewController.kind = self.pet.kind;
    }
}

@end
