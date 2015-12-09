//
//  PetDetailsViewController.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 21/12/11.
//  Copyright (c) 2011 plusangel@gmail.com. All rights reserved.
//

#import "PetDetailsViewController.h"
#import "Pet.h"
#import "Photo.h"
#import "WeightPoint.h"
#import "AppDelegate.h"
#import "PetPictureDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface PetDetailsViewController () <UITextFieldDelegate, UIAlertViewDelegate, UIScrollViewDelegate, UINavigationBarDelegate>
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (weak, nonatomic) IBOutlet UISegmentedControl *sexSegmentedControl;
    @property (weak, nonatomic) IBOutlet UISegmentedControl *kindSegmentedControl;

    @property (weak, nonatomic) IBOutlet UITextField *nameTextField;
    @property (weak, nonatomic) IBOutlet UITextField *breedTextField;
    @property (weak, nonatomic) IBOutlet UITextField *weightTextField;
    @property (weak, nonatomic) IBOutlet UITextField *dobTextField;
    @property (weak, nonatomic) IBOutlet UITextField *microchipTextField;
    @property (weak, nonatomic) IBOutlet UITextField *registrationTextField;

    @property (weak, nonatomic) IBOutlet UIButton *profilePhoto;

    @property (weak, nonatomic) IBOutlet UIToolbar *accessoryView;
    @property (weak, nonatomic) IBOutlet UIDatePicker *customInput;
    @property (weak, nonatomic) IBOutlet UIToolbar *accessoryView2;
    @property (weak, nonatomic) IBOutlet UIDatePicker *customInput2;

    @property (weak, nonatomic) IBOutlet UILabel *weightLabel;
    @property (weak, nonatomic) IBOutlet UILabel *weightUnitLabel;
@end

@implementation PetDetailsViewController
{
    UITextField *activeField;
    
    NSMutableArray *arrayOfPoints;
    BOOL weightAtDateOfBirth;
    
    UIColor *maleColor;
    UIColor *femaleColor;
    UIFont *textFont;
    
    NSNumberFormatter *numberFormatter;
    NSDateFormatter *dateFormatter;
}

#pragma mark - registering  and unregistering in recieving keyboard notifications
/*
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterFromKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
*/
#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updatePhoto];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    
    maleColor = [UIColor colorWithRed:25.0f/255.0f green:158.0f/255.0f blue:189.0f/255.0f alpha:1.0f];
    femaleColor = [UIColor colorWithRed:246.0f/255.0f green:100.0f/255.0f blue:175.0f/255.0f alpha:1.0f];
    textFont = [UIFont fontWithName:@"Avenir-Light" size:17];
    
    // customize profile pic
    [[self.profilePhoto layer] setMasksToBounds:YES];
    [[self.profilePhoto layer] setBorderWidth:2.0f];
    [[self.profilePhoto layer] setBorderColor:maleColor.CGColor];
    
    /*
    if (IS_WIDESCREEN) {
        self.petIconTopConstraint.constant =+ 480.0f;
        self.petIconBottomConstraint.constant =- 480.0f;
    }
    //self.view.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:250.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
    
    self.petIconImageView.image = [UIImage imageNamed:@"catDetails"];
    self.petIconImageView.alpha = 0.3;
    */
    [self.sexSegmentedControl setImage:[UIImage imageNamed:@"male"] forSegmentAtIndex:0];
    [self.sexSegmentedControl setImage:[UIImage imageNamed:@"female"] forSegmentAtIndex:1];
    
    [self.kindSegmentedControl setImage:[UIImage imageNamed:@"catHead"] forSegmentAtIndex:0];
    [self.kindSegmentedControl setImage:[UIImage imageNamed:@"dogHead"] forSegmentAtIndex:1];
    
    self.weightTextField.font = textFont;
    self.nameTextField.font = textFont;
    self.breedTextField.font = textFont;
    self.dobTextField.font = textFont;
    self.microchipTextField.font = textFont;
    self.registrationTextField.font = textFont;
    
    self.profilePhoto.highlighted = NO;
    
    weightAtDateOfBirth = NO;
    
    self.profilePhoto.clipsToBounds = YES;
    self.profilePhoto.layer.cornerRadius = 128.0/2.0f;
    
    self.dobTextField.inputView = self.customInput;
    self.dobTextField.inputAccessoryView = self.accessoryView;
    
    self.registrationTextField.inputView = self.customInput2;
    self.registrationTextField.inputAccessoryView = self.accessoryView2;
    self.registrationTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.weightUnitLabel.text = (self.weightUnit?@"lb":@"kg");
    self.weightTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    //[self registerForKeyboardNotifications];
    
    if (self.isEditing == YES) {
        self.title = NSLocalizedString(@"Edit", @"Title of edit pet screen");
        self.nameTextField.text = self.pet.name;
        self.breedTextField.text = self.pet.breed;
        self.registrationTextField.text = [dateFormatter stringFromDate:self.pet.registration];
        self.microchipTextField.text = self.pet.microchip;
        
        self.sexSegmentedControl.selectedSegmentIndex = self.pet.sex;
        if (self.pet.sex == 0) {
            [[self.profilePhoto layer] setBorderColor:maleColor.CGColor];
        } else {
            [[self.profilePhoto layer] setBorderColor:femaleColor.CGColor];
        }
        /*
        self.kindSegmentedControl.selectedSegmentIndex = self.pet.kind;
        if (self.pet.kind == YES) {
            self.petIconImageView.image = [UIImage imageNamed:@"dogDetails"];
        }
        */
        self.dobTextField.text = [dateFormatter stringFromDate:self.pet.dob];
        
        if (self.pet.weight != nil) {
            arrayOfPoints = [NSKeyedUnarchiver unarchiveObjectWithData:self.pet.weight];
            WeightPoint *lastWeightPoint = [arrayOfPoints lastObject];
            self.weightTextField.text = [[lastWeightPoint weight] stringValue];
            self.weightTextField.enabled = NO;
            self.weightTextField.textColor = [UIColor lightGrayColor];
        } else {
            self.weightTextField.hidden = YES;
            self.weightLabel.hidden = YES;
            self.weightUnitLabel.hidden = YES;
        }
    } else {
        //***Add to translation
        self.title = NSLocalizedString(@"Add", @"Title of add pet screen");
        self.pet = [NSEntityDescription insertNewObjectForEntityForName:@"Pet" inManagedObjectContext:self.context];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 3 && self.pet.dob != nil) {
        [self.customInput setDate:self.pet.dob animated:YES];
    } else if (textField.tag == 3 && self.pet.dob == nil) {
        self.dobTextField.text = [dateFormatter stringFromDate:[NSDate date]];
    }
    
    if (textField.tag == 5 && self.pet.registration != nil) {
        [self.customInput2 setDate:self.pet.registration animated:YES];
    } else if (textField.tag == 5 && self.pet.registration == nil) {
        self.registrationTextField.text = [dateFormatter stringFromDate:[NSDate date]];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
    
    if (textField.tag == 0) {
        NSNumber *weight = [numberFormatter numberFromString:self.weightTextField.text];
        if (weight == nil) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Pet's weight value",@"Title of pet's weight value alert")
                                        message:NSLocalizedString(@"Please submit a valid weight in format x.x",@"Message for valid weigh reminder")
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Pet's weight date",@"Title of pet's weight date alert")
                                        message:NSLocalizedString(@"Is this the initial weight at the time of birth or the current weight of your pet?",@"Message for choosing the date of weight")
                                       delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Today", @"String for today")
                              otherButtonTitles:NSLocalizedString(@"Date of Birth" , @"String for Date of Birth"), nil] show];
        }
    }

}

#pragma mark - Handle Notifications
/*
- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    CGFloat offset = 6.0;
    if (activeField.tag == 3) {
        // date of birth textfield
        offset = 96.0;//56.0
    } else if (activeField.tag == 5) {
        // registration date textfied
        offset = 96.0;//56.0
    }
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height + offset);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}
*/
#pragma mark - weight methods

- (BOOL)addWeightPoint
{
    // Check if user doesn't submit a weight value when he creates the pet
    if ([self.weightTextField.text length] != 0) {
    
        // Is it valid number?
        NSNumber *weight = [numberFormatter numberFromString:self.weightTextField.text];
        if (weight == nil) {
            return NO;
        }
        
        WeightPoint *newWeightPoint = [[WeightPoint alloc] init];
        newWeightPoint.weight = weight;
        
        if (weightAtDateOfBirth) {
            newWeightPoint.date = self.pet.dob;
        } else {
            newWeightPoint.date = [NSDate date];
        }
        
        NSMutableArray *petWeightPoints = [NSMutableArray array];
        [petWeightPoints addObject:newWeightPoint];
        
        self.pet.weight = [NSKeyedArchiver archivedDataWithRootObject:petWeightPoints];
    } 
    return YES;
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"Date of Birth"]) {
        weightAtDateOfBirth = YES;
    }
    
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    if (self.isEditing == NO) {
        [self.delegate petDetailsViewControllerDidCancel:self withRemovingDummyPet:self.pet];
    } else {
        [self.delegate petDetailsViewControllerDidCancel:self withRemovingDummyPet:nil];
    }
}

- (IBAction)done:(id)sender
{
    if (self.isEditing == YES) {
        
        // Edit Pet
        
        self.pet.name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.pet.breed = [self.breedTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.pet.microchip = self.microchipTextField.text;
        [self.delegate petDetailsViewController:self didEditPet:self.pet];
    } else {
        
        // Add a new Pet
        
        self.pet.name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.pet.breed = [self.breedTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.pet.microchip = [self.microchipTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([self.dobTextField.text isEqualToString:@""]) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Pet's date o birth",@"Title of pet's dob alert")
                                        message:NSLocalizedString(@"Please submit a valid date of birth",@"Message for dob reminder")
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil] show];
            return;
        }
        
        if ([self addWeightPoint] == NO) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Pet's weight",@"Pet's weight String")
                                        message:NSLocalizedString(@"Please submit a valid weight in format x.x",@"Message for valid weigh reminder")
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil] show];
            return;
        }
        
        [self.delegate petDetailsViewController:self didAddPet:self.pet];
    }
}

- (IBAction)sexSelection:(id)sender
{
    self.pet.sex = self.sexSegmentedControl.selectedSegmentIndex;
    if (self.pet.sex == 0) {
        [[self.profilePhoto layer] setBorderColor:maleColor.CGColor];
    } else {
        [[self.profilePhoto layer] setBorderColor:femaleColor.CGColor];
    }
}

- (IBAction)kindSelection:(id)sender
{
    self.pet.kind = self.kindSegmentedControl.selectedSegmentIndex;
    /*
    if (self.pet.kind == YES) {
        self.petIconImageView.image = [UIImage imageNamed:@"dogDetails"];
    } else {
        self.petIconImageView.image = [UIImage imageNamed:@"catDetails"];
    }*/
}

- (IBAction)dateDoneEditing:(id)sender
{
    self.dobTextField.text = [dateFormatter stringFromDate:self.customInput.date];
    self.pet.dob = self.customInput.date;
    
    [self.dobTextField resignFirstResponder];
}

- (IBAction)dateChangeValue:(id)sender
{
    UIDatePicker *dp = (UIDatePicker *)sender;
    self.dobTextField.text = [dateFormatter stringFromDate:dp.date];
}

- (IBAction)registrationDateValueChanged:(id)sender {
    UIDatePicker *dp = (UIDatePicker *)sender;
    self.registrationTextField.text = [dateFormatter stringFromDate:dp.date];
}

- (IBAction)registrationDateDoneEditing:(id)sender
{
    if (self.registrationTextField.text.length != 0) {
        self.registrationTextField.text = [dateFormatter stringFromDate:self.customInput2.date];
        self.pet.registration = self.customInput2.date;
    }
    [self.registrationTextField resignFirstResponder];
}

- (IBAction)registrationDateCancelEditing:(id)sender
{
    self.registrationTextField.text = @"";
    [self.registrationTextField resignFirstResponder];
}

- (void)updatePhoto
{
    UIImage *image = self.pet.photo.image;
    
    if (image) {
        [[self.profilePhoto imageView] setContentMode:UIViewContentModeScaleAspectFit];
        [self.profilePhoto setImage:image forState:UIControlStateNormal];
        [self.profilePhoto setTitle:@"" forState:UIControlStateNormal];
    } else {
        self.profilePhoto.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.profilePhoto.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.profilePhoto setTitle:NSLocalizedString(@"Add Photo", @"Add Photo String") forState:UIControlStateNormal];
        
        [self.profilePhoto setImage:nil forState:UIControlStateNormal];
    }
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"managePhoto"]) {
        PetPictureDetailViewController *petPictureDetailViewController = segue.destinationViewController;
        petPictureDetailViewController.pet = self.pet;
    } 
}

@end
