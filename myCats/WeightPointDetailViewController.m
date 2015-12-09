//
//  WeightPointViewController.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 20/6/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import "WeightPointDetailViewController.h"
#import "WeightPoint.h"
#import "AppDelegate.h"
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface WeightPointDetailViewController () <UITextFieldDelegate>
    @property (weak, nonatomic) IBOutlet UILabel *weightUnitLabel;
    @property (weak, nonatomic) IBOutlet UITextField *weightTextField;
    @property (weak, nonatomic) IBOutlet UITextField *dateTextField;
    @property (weak, nonatomic) IBOutlet UIDatePicker *customInput;
    @property (weak, nonatomic) IBOutlet UIToolbar *accessoryView;

    @property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;
    @property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;
    @property (weak, nonatomic) IBOutlet UIButton *cautionWeightButton;
    @property (weak, nonatomic) IBOutlet UIButton *cautionDateButton;

    @property (nonatomic, weak) IBOutlet NSLayoutConstraint *cautionWeightButtonWidth;
    @property (nonatomic, weak) IBOutlet NSLayoutConstraint *cautionDateButtonWidth;
    @property (nonatomic, weak) IBOutlet UIImageView *weightPointFooterImageView;
@end

@implementation WeightPointDetailViewController
{
    WeightPoint *newWeightPoint;
    UIView *tableViewHeaderView;
    UIImageView *weightPointHelpMessageImageView;
    
    NSDateFormatter *dateFormatter;
    NSNumberFormatter *numberFormatter;

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];

    self.dateTextField.inputView = self.customInput;
    self.dateTextField.inputAccessoryView = self.accessoryView;
    self.dateTextField.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    
    self.weightTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.weightTextField.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    
    self.weightUnitLabel.text = (self.weightUnit?@"lb":@"kg");
    self.weightUnitLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    
    if (self.isEditing == YES) {
        self.title = NSLocalizedString(@"edit", @"edit title of view controller");
        self.editing = NO;
        self.weightTextField.text = [self.weightPoint.weight stringValue];
        self.dateTextField.text = [dateFormatter stringFromDate:self.weightPoint.date];
        self.customInput.date = self.weightPoint.date;
    } else {
        self.title = NSLocalizedString(@"add weight", @"new weight title of view controller");
        newWeightPoint = [[WeightPoint alloc] init];
        self.weightTextField.text = @"";
    }
    
    // if caution button is hidden make it zerowidth in order to maximize tap area of uitextfield
    if (self.cautionWeightButton.hidden) {
        self.cautionWeightButtonWidth.constant = 0.0f;
    }
    if (self.cautionDateButton.hidden) {
        self.cautionDateButtonWidth.constant = 0.0f;
    }
    
    // show the appropriate footer image
    [self showFooter];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showHelp];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view delegate

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create header components
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, 30.0)];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    UIImageView *headerImageView = [[UIImageView alloc] init];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(headerTitle, headerImageView);
    
    // content according to section
    switch (section) {
        case 0:
            headerTitle.text = NSLocalizedString(@"Pet's Weight", @"Pet's Weight header title");
            headerImageView.image = [UIImage imageNamed:@"weightPointWeight"];
            break;
        case 1:
            headerTitle.text = NSLocalizedString(@"Date", @"Date header title");
            headerImageView.image = [UIImage imageNamed:@"weightPointCalendar"];
            break;
            
        default:
            break;
    }
    
    // stylize labels
    UIFont *headerFont = [UIFont fontWithName:@"Avenir-Light" size:18];
    headerTitle.font = headerFont;
    [headerTitle setTextColor:[UIColor colorWithRed:40.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1.0]];
    [headerTitle setShadowColor:[UIColor colorWithRed:15.0/255.0 green:77.0/255.0 blue:42.0/255.0 alpha:1.0]];
    
    // add to header
    headerTitle.translatesAutoresizingMaskIntoConstraints = NO;
    headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:headerTitle];
    [headerView addSubview:headerImageView];
    
    [headerView setBackgroundColor:[UIColor clearColor]];
    [headerTitle setBackgroundColor:[UIColor clearColor]];
    
    // constraints
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[headerTitle]-(>=8)-[headerImageView]-|"
                                                                   options:NSLayoutFormatAlignAllTop
                                                                   metrics:nil
                                                                     views:viewsDictionary];
    [headerView addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[headerImageView]"
                                                          options:0
                                                          metrics:nil
                                                            views:viewsDictionary];
    [headerView addConstraints:constraints];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField 
{
    // when start correcting hide the caution button
    if (!self.cautionWeightButton.hidden) {
        self.cautionWeightButton.hidden = YES;
    }
    if (!self.cautionDateButton.hidden) {
        self.cautionDateButton.hidden = YES;
    }
    
    if (textField.tag == 1) {
        self.cancelBarButton.enabled = NO;
        self.saveBarButton.enabled = NO;
        
        if (self.weightPoint.date != nil) {
        [self.customInput setDate:self.weightPoint.date animated:YES];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.isEditing == NO) {
        if (textField == self.weightTextField) {
            [self.dateTextField becomeFirstResponder];
        } else {
            [textField resignFirstResponder];
        }
        return NO;
    }
    [textField resignFirstResponder];
    return NO;
}


#pragma mark - Check entry values

- (void)alertWeightValue 
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Pet's weight value",@"Title of pet's weight value alert")
                                message:NSLocalizedString(@"Please submit a valid weight in format x.x",@"Message for valid weigh reminder")
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

- (void)alertDateValue:(NSDate *)dateReference withOrder:(BOOL)straight
{
    if (straight == YES) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Date of Weight", @"Title for date of weight alert")
                                    message:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Please submit a date after", @"Submit a date after message"), [dateFormatter stringFromDate:dateReference]]
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];

    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Date of Weight", @"Title for date of weight alert")
                                    message:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Please submit a date before", @"Submit a date before message"), [dateFormatter stringFromDate:dateReference]]
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    }
}

#pragma mark - Actions

- (IBAction)save:(id)sender
{
    BOOL abortSave = NO;
    
    if ([self.dateTextField.text length] == 0) {
        self.cautionDateButtonWidth.constant = 44.0f;
        self.cautionDateButton.hidden = NO;
        
        abortSave = YES;
    }
    
    NSNumber *weight = [numberFormatter numberFromString:self.weightTextField.text];
    
    if (self.isEditing == YES) {
        
        // Editing a weight point
        if (weight != nil) {
            self.weightPoint.weight = weight;
        } else {
            self.cautionWeightButtonWidth.constant = 44.0f;
            self.cautionWeightButton.hidden = NO;
            
            abortSave = YES;
        }
    } else {
        
        // Adding a new weight point
        if (weight != nil) {
            newWeightPoint.weight = weight;
        } else {
            self.cautionWeightButtonWidth.constant = 44.0f;
            self.cautionWeightButton.hidden = NO;
            
            abortSave = YES;
        }
    }
    
    if (!abortSave) {
        if (self.isEditing == YES) {
            [self.delegate weightPointViewController:self didEdit:self.weightPoint];
        } else {
            [self.delegate weightPointViewController:self didSave:newWeightPoint];
        }
    } else {
        return;
    }

}

- (IBAction)cancel:(id)sender
{
    [self.delegate weightPointViewControllerDidCancel:self];
}

- (IBAction)dateChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.dateTextField.text = [dateFormatter stringFromDate:datePicker.date];
}

- (IBAction)dateCancelEditing:(id)sender
{
    [self.saveBarButton setEnabled:YES];
    [self.cancelBarButton setEnabled:YES];
    [self.dateTextField resignFirstResponder];
}

- (IBAction)dateDoneEditing:(id)sender
{
    
    if (self.isEditing == YES ) {
        
        // Edit an existing weightPoint
        if ([self.customInput.date compare:self.nextDate] == NSOrderedDescending || [self isSameDayWithDate1:self.customInput.date date2:self.nextDate]) {
            [self alertDateValue:self.nextDate withOrder:NO];
            return;
        } else if ([self.customInput.date compare:self.previousDate] == NSOrderedAscending || [self isSameDayWithDate1:self.customInput.date date2:self.previousDate]){
            [self alertDateValue:self.previousDate withOrder:YES];
            return;
        } else if (([self.customInput.date compare:self.previousDate] == NSOrderedDescending && self.nextDate == nil)
                   || ([self.customInput.date compare:self.nextDate] == NSOrderedAscending && self.previousDate == nil)
                   || (self.previousDate == nil && self.nextDate == nil)) {
            self.dateTextField.text = [dateFormatter stringFromDate:self.customInput.date];
            self.weightPoint.date = self.customInput.date;
        } else if ([self.customInput.date compare:self.previousDate] == NSOrderedDescending  && [self.customInput.date compare:self.nextDate] == NSOrderedAscending && [self.customInput.date compare:self.nextDate] != NSOrderedSame && [self.customInput.date compare:self.previousDate] != NSOrderedSame) {
            self.dateTextField.text = [dateFormatter stringFromDate:self.customInput.date];
            self.weightPoint.date = self.customInput.date;
        }
    } else {
        
        // Create a new weightPoint
        newWeightPoint.date = self.customInput.date;
        self.dateTextField.text = [dateFormatter stringFromDate:self.customInput.date];
    }

    [self.saveBarButton setEnabled:YES];
    [self.cancelBarButton setEnabled:YES];
    [self.dateTextField resignFirstResponder];
}

#pragma mark - NSConstraintLayout Action methods

-(IBAction)cautionWeightButtonPressed:(id)sender
{
    [self alertWeightValue];
}

-(IBAction)cautionDateButtonPressed:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Date of Weight", @"Title for date of weight alert")
                                message:NSLocalizedString(@"Please submit a date", @"Submit a date message")
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}


#pragma mark - Assistant methods

- (BOOL)isSameDayWithDate1:(NSDate*)date1 date2:(NSDate*)date2 {
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    if (date1 == nil || date2 == nil) {
        return NO;
    }
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
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
        tableViewHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 120.0)];
        
        if (self.editing == NO) {
            weightPointHelpMessageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self localizeHelpMessages:@"newWeightPointHelpMessageAdd" forLanguage:locale]]];
            [tableViewHeaderView addSubview:weightPointHelpMessageImageView];
            self.tableView.tableHeaderView = tableViewHeaderView;
        } else if (self.editing == YES) {
            weightPointHelpMessageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self localizeHelpMessages:@"newWeightPointHelpMessageEdit" forLanguage:locale]]];
            [tableViewHeaderView addSubview:weightPointHelpMessageImageView];
            self.tableView.tableHeaderView = tableViewHeaderView;
        } else if (self.tableView.tableHeaderView) {
            self.tableView.tableHeaderView = nil;
        }
    } else {
        if (self.tableView.tableHeaderView) {
            self.tableView.tableHeaderView = nil;
        }
    }
}

- (void)showFooter
{
    CGRect initialRect = self.weightPointFooterImageView.frame;
    
    if (self.helpStatus == YES) {
        if (IS_WIDESCREEN) {
            self.weightPointFooterImageView.frame = CGRectMake(initialRect.origin.x, initialRect.origin.y, [[UIScreen mainScreen] bounds].size.width, 207.0f);
            self.weightPointFooterImageView.image = [UIImage imageNamed:@"weightPointFooterWithHelp5"];
        } else {
            self.weightPointFooterImageView.frame = CGRectMake(initialRect.origin.x, initialRect.origin.y, [[UIScreen mainScreen] bounds].size.width, 119.0f);
            self.weightPointFooterImageView.image = [UIImage imageNamed:@"weightPointFooterWithHelp"];
        }
    } else {
        if (IS_WIDESCREEN) {
            self.weightPointFooterImageView.frame = CGRectMake(initialRect.origin.x, initialRect.origin.y, [[UIScreen mainScreen] bounds].size.width, 327.0f);
            self.weightPointFooterImageView.image = [UIImage imageNamed:@"weightPointFooterNoHelp5"];
        } else {
            self.weightPointFooterImageView.frame = CGRectMake(initialRect.origin.x, initialRect.origin.y, [[UIScreen mainScreen] bounds].size.width, 239.0f);
            self.weightPointFooterImageView.image = [UIImage imageNamed:@"weightPointFooterNoHelp"];
        }
    }
}

@end
