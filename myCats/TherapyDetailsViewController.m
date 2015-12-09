//
//  AddTherapyViewController.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 28/3/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import "TherapyDetailsViewController.h"
#import "Therapy.h"
#import "AppDelegate.h"

@interface TherapyDetailsViewController () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UIAlertViewDelegate>
    @property (weak, nonatomic) IBOutlet UITextField *priceTextField;

    @property (weak, nonatomic) IBOutlet UIDatePicker *customInput;
    @property (weak, nonatomic) IBOutlet UIToolbar *accessoryView;

    @property (weak, nonatomic) IBOutlet UIPickerView *customInput2;
    @property (weak, nonatomic) IBOutlet UIToolbar *accessoryView2;

    @property (weak, nonatomic) IBOutlet UIToolbar *accessoryView3;

    @property (weak, nonatomic) IBOutlet UITextField *dateTextField;
    @property (weak, nonatomic) IBOutlet UITextField *therapyTextField;
    @property (weak, nonatomic) IBOutlet UITextView *notesTextView;
    @property (weak, nonatomic) IBOutlet UILabel *currencyUnitLabel;
    @property (weak, nonatomic) IBOutlet UITextField *productTextField;

    @property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;
    @property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;

    @property (weak, nonatomic) IBOutlet UIButton *cautionTherapyButton;
    @property (weak, nonatomic) IBOutlet UIButton *cautionDateButton;
    @property (weak, nonatomic) IBOutlet UIButton *cautionPriceButton;

    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *cautionTherapyButtonWidth;
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *cautionDateButtonWidth;
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *cautionPriceButtonWidth;

@end

@implementation TherapyDetailsViewController
{
    NSArray *therapyTypes;
    
    UIFont *therapyDetailsFont;
    UIView *tableViewHeaderView;
    NSDictionary *therapyTypesDicEl;
    NSDictionary *therapyTypesDicEn;
    UIImageView *detailsTherapyHelpMessageImageView;
    
    NSDateFormatter *dateFormatter;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
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
    
    therapyDetailsFont = [UIFont fontWithName:@"Avenir-Light" size:17];
    
    self.title = NSLocalizedString(@"new", @"new therapy view title") ;
    
    self.dateTextField.inputView = self.customInput;
    self.dateTextField.inputAccessoryView = self.accessoryView;
    //self.dateTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.dateTextField.font = therapyDetailsFont;
    self.dateTextField.placeholder = NSLocalizedString(@"pick a date", @"date in therapyDetails Form");
    
    self.therapyTextField.inputView = self.customInput2;
    self.therapyTextField.inputAccessoryView = self.accessoryView2;
    //self.therapyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.therapyTextField.font = therapyDetailsFont;
    self.therapyTextField.placeholder = NSLocalizedString(@"pick a therapy type", @"therapy in therapyDetails Form");
    
    self.notesTextView.backgroundColor = [UIColor clearColor];
    self.notesTextView.inputAccessoryView = self.accessoryView3;
    self.notesTextView.font = therapyDetailsFont;
    self.notesTextView.text = NSLocalizedString(@"write your notes here...", @"notes in therapyDetails Form");;
    self.notesTextView.textColor = [UIColor lightGrayColor]; //optional
    
    self.priceTextField.font = therapyDetailsFont;
    self.priceTextField.placeholder = NSLocalizedString(@"write the price", @"price in therapyDetails Form");
    
    self.productTextField.font = therapyDetailsFont;
    self.productTextField.placeholder = NSLocalizedString(@"write the product's name", @"product in therapyDetails Form");
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    therapyTypes = @[NSLocalizedString(@"Treatments", @"Treatments string"), NSLocalizedString(@"Primary Vaccination", @"Primary Vaccination string"),
                    NSLocalizedString(@"Revaccination", @"Revaccination string"), NSLocalizedString(@"Vermifugation", @"Vermifugation string")];

    therapyTypesDicEl = @{@"Θεραπευτική αγωγή":@"0", @"Πρώτος εμβολιασμός":@"1", @"Επαναληπτικός εμβολιασμός":@"2", @"Αποπαρασίτωση":@"3"};
    therapyTypesDicEn = @{@"Treatments":@"0", @"Primary Vaccination":@"1", @"Revaccination":@"2", @"Vermifugation":@"3"};
    
    if (self.currencyUnit == 0) {
        self.currencyUnitLabel.text = @"€";
    } else if (self.currencyUnit == 1) {
        self.currencyUnitLabel.text = @"$";
    } else {
        self.currencyUnitLabel.text = @"£";
    }
    self.currencyUnitLabel.font = therapyDetailsFont;
    
    if (self.isEditing == YES) {
        self.editing = NO;
        self.title = NSLocalizedString(@"edit", @"edit therapy view title");
        self.priceTextField.text = [self.therapy.price stringValue];
        self.dateTextField.text = [dateFormatter stringFromDate:self.therapy.dateOfTherapy];
        self.therapyTextField.text = self.therapy.therapyType;
        self.productTextField.text = self.therapy.product;
        self.notesTextView.text = self.therapy.notes;
    }
    
    // if caution button is hidden make it zerowidth in order to maximize tap area of uitextfield
    if (self.cautionTherapyButton.hidden) {
        self.cautionTherapyButtonWidth.constant = 0.0f;
    }
    if (self.cautionDateButton.hidden) {
        self.cautionDateButtonWidth.constant = 0.0f;
    }
    if (self.cautionPriceButton.hidden) {
        self.cautionPriceButtonWidth.constant = 0.0f;
    }
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
#pragma mark - UITextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"placeholder text here..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"placeholder text here...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField 
{
    NSString *locale = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    
    // when start correcting hide the caution button
    if (!self.cautionTherapyButton.hidden) {
        self.cautionTherapyButton.hidden = YES;
    }
    if (!self.cautionDateButton.hidden) {
        self.cautionDateButton.hidden = YES;
    }
    if (!self.cautionPriceButton.hidden) {
        self.cautionPriceButton.hidden = YES;
    }
    
    if (textField.tag == 2) {
        NSUInteger index;
        self.cancelBarButton.enabled = NO;
        self.saveBarButton.enabled = NO;
        
        if (self.therapy.therapyType != nil) {
            if ((index = [therapyTypes indexOfObject:self.therapy.therapyType]) == NSNotFound) {
                if ([locale isEqualToString:@"el"]) {
                    index = [[therapyTypesDicEn objectForKey:self.therapy.therapyType] intValue];
                } else {
                    index = [[therapyTypesDicEl objectForKey:self.therapy.therapyType] intValue];
                }
            }
            [self.customInput2 selectRow:index inComponent:0 animated:YES];
        }
    } else if (textField.tag == 0) {
        self.cancelBarButton.enabled = NO;
        self.saveBarButton.enabled = NO;
        
        if (self.therapy.dateOfTherapy != nil) {
            [self.customInput setDate:self.therapy.dateOfTherapy animated:YES];
        }
    } else if (textField.tag == 4) {
        self.cancelBarButton.enabled = NO;
        self.saveBarButton.enabled = NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /*
    if (self.editing == NO) {
        if (textField == self.priceTextField) {
            [self.therapyTextField becomeFirstResponder];
        } else {
            [textField resignFirstResponder];
        }
    return NO;
    }*/
    
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Date", @"date Section Name");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Price", @"price Section Name");
            break;
        case 2:
            sectionName = NSLocalizedString(@"Therapy", @"therapy Section Name");
            break;
        case 3:
            sectionName = NSLocalizedString(@"Product used", @"product used Section Name");
            break;
        case 4:
            sectionName = NSLocalizedString(@"Notes", @"notes Section Name");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

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
            headerTitle.text = NSLocalizedString(@"Date", @"Date header title");
            headerImageView.image = [UIImage imageNamed:@"therapyDetailsDate"];
            break;
        case 1:
            headerTitle.text = NSLocalizedString(@"Price", @"Price header title");
            headerImageView.image = [UIImage imageNamed:@"therapyDetailsPrice"];
            break;
        case 2:
            headerTitle.text = NSLocalizedString(@"Therapy", @"Therapy header title");
            headerImageView.image = [UIImage imageNamed:@"therapyDetailsTherapy"];
            break;
        case 3:
            headerTitle.text = NSLocalizedString(@"Product used", @"Product used header title");
            headerImageView.image = [UIImage imageNamed:@"therapyDetailsProduct"];
            break;
        case 4:
            headerTitle.text = NSLocalizedString(@"Notes", @"Notes header title");
            headerImageView.image = [UIImage imageNamed:@"therapyDetailsNotes"];
            break;
            
        default:
            break;
    }
    
    // stylize labels
    UIFont *headerFont = [UIFont fontWithName:@"Avenir-Light" size:17];
    headerTitle.font = headerFont;
    [headerTitle setTextColor:[UIColor colorWithRed:40.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1.0]];
    //[headerTitle setShadowColor:[UIColor colorWithRed:15.0/255.0 green:77.0/255.0 blue:42.0/255.0 alpha:1.0]];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self resignFirstResponder];
    if (indexPath.section == 0) {
        [self.priceTextField becomeFirstResponder];
    }
}

#pragma mark - IBActions methods

- (IBAction)save:(id)sender {
    
    NSManagedObjectContext *context = [self.therapy managedObjectContext];
    BOOL abortSave = NO;
    
    if ([[NSDecimalNumber decimalNumberWithString:self.priceTextField.text] isEqual:[NSDecimalNumber notANumber]] || [self.priceTextField.text length] == 0) {
        self.cautionPriceButtonWidth.constant = 44.0f;
        self.cautionPriceButton.hidden = NO;
        
        abortSave = YES;
    } else {
        self.therapy.price = [NSDecimalNumber decimalNumberWithString:self.priceTextField.text];
    }
    
    // Check for non selected therapy type
    if ([self.therapyTextField.text length] == 0) {
        self.cautionTherapyButtonWidth.constant = 44.0f;
        self.cautionTherapyButton.hidden = NO;
        
        abortSave = YES;
    } else {
        self.therapy.therapyType = self.therapyTextField.text;
    }
    
    // Check for empty date field
    if ([self.dateTextField.text length] == 0) {
        self.cautionDateButtonWidth.constant = 44.0f;
        self.cautionDateButton.hidden = NO;
        
        abortSave = YES;
    }
    
    self.therapy.product = [self.productTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.therapy.notes = self.notesTextView.text;
    
    if (!abortSave) {
        if (self.isEditing == NO) {
            [self.delegate detailsTherapyViewController:self didSave:self.therapy];
        } else {
            NSError *error = nil;
            if (![context save:&error]) {
                [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText:NSLocalizedString(@"edit a therapy", @"Error description in editing a therapy")];
            }
            
            [self.delegate detailsTherapyViewController:self didEdit:self.therapy];
        }
    } else {
        return;
    }
}

- (IBAction)cancel:(id)sender {
    [self.delegate detailsTherapyViewControllerDidCancel:self];
}

- (IBAction)dateDoneEditing:(id)sender
{
    self.dateTextField.text = [dateFormatter stringFromDate:self.customInput.date];
    self.therapy.dateOfTherapy = self.customInput.date;
    /*
    if (self.isEditing == NO) {
        [self.priceTextField becomeFirstResponder];
    }
    */
    [self.saveBarButton setEnabled:YES];
    [self.cancelBarButton setEnabled:YES];
    [self.dateTextField resignFirstResponder];
}

- (IBAction)dateCancelEditing:(id)sender
{
    [self.saveBarButton setEnabled:YES];
    [self.cancelBarButton setEnabled:YES];
    self.dateTextField.text = @"";
    [self.dateTextField resignFirstResponder];
}

- (IBAction)dateChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.dateTextField.text = [dateFormatter stringFromDate:datePicker.date];
}


- (IBAction)therapyDoneEditing:(id)sender
{
    self.therapy.therapyType = [therapyTypes objectAtIndex:[self.customInput2 selectedRowInComponent:0]];
    /*
    if ([self.therapyTextField.text length] == 0) {
        self.therapyTextField.text = NSLocalizedString(@"Treatments", @"Treatments string");
    }
    
    if (self.isEditing == NO) {
        [self.productTextField becomeFirstResponder];
    }*/

    [self.saveBarButton setEnabled:YES];
    [self.cancelBarButton setEnabled:YES];
    [self.therapyTextField resignFirstResponder];
}

- (IBAction)therapyCancelEditing:(id)sender
{
    self.therapyTextField.text = self.therapy.therapyType;
    
    [self.saveBarButton setEnabled:YES];
    [self.cancelBarButton setEnabled:YES];
    [self.therapyTextField resignFirstResponder];
}

- (IBAction)notesDoneEditing:(id)sender
{
    [self.saveBarButton setEnabled:YES];
    [self.cancelBarButton setEnabled:YES];
    [self.notesTextView resignFirstResponder];
}

- (IBAction)notesCancelEditing:(id)sender
{
    [self.saveBarButton setEnabled:YES];
    [self.cancelBarButton setEnabled:YES];
    [self.notesTextView resignFirstResponder];
}

#pragma mark - Therapy UIPickerView methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [therapyTypes count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [therapyTypes objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.therapyTextField.text = [therapyTypes objectAtIndex:row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *pickerCustomView = (id)view;
    UILabel *pickerViewLabel;
    UIImageView *pickerImageView;
    
    if (!pickerCustomView) {
        pickerCustomView= [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                   [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView rowSizeForComponent:component].height)];
        pickerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 35.0f, 35.0f)];
        pickerViewLabel= [[UILabel alloc] initWithFrame:CGRectMake(37.0f, -5.0f,
                                                                   [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView rowSizeForComponent:component].height)];
        [pickerCustomView addSubview:pickerImageView];
        [pickerCustomView addSubview:pickerViewLabel];
    }
    
    pickerImageView.image = [self selectTherapyImageFor:therapyTypes[row]];
    pickerViewLabel.backgroundColor = [UIColor clearColor];
    pickerViewLabel.text = therapyTypes[row];
    pickerViewLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:18];
    
    return pickerCustomView;
}

#pragma mark - NSConstraintLayout Action methods

-(IBAction)cautionTherapyButtonPressed:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Type of Therapy", @"Title for date of therapy alert")
                                message:[NSString stringWithFormat:@"%@", NSLocalizedString(@"Please select the type of therapy", @"Select a therapy type message")]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];

}

-(IBAction)cautionDateButtonPressed:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Date of Therapy", @"Title for date of therapy alert")
                                message:NSLocalizedString(@"Please submit a date", @"Submit a date message")
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

-(IBAction)cautionPriceButtonPressed:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Price of Therapy", @"Title for price of therapy alert")
                                message:NSLocalizedString(@"Please submit a valid price", @"Submit price message")
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}


#pragma mark - Assistant Methods

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
        tableViewHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 120.0)];
        
        if (self.editing == NO) {
            detailsTherapyHelpMessageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self localizeHelpMessages:@"therapyDetailsHelpMessageAdd" forLanguage:locale]]];
            [tableViewHeaderView addSubview:detailsTherapyHelpMessageImageView];
            self.tableView.tableHeaderView = tableViewHeaderView;
        } else if (self.editing == YES) {
            detailsTherapyHelpMessageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self localizeHelpMessages:@"therapyDetailsHelpMessageEdit" forLanguage:locale]]];
            [tableViewHeaderView addSubview:detailsTherapyHelpMessageImageView];
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

@end
