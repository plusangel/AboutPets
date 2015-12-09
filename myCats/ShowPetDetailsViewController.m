//
//  ShowPetDetailsViewController.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 16/2/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import "ShowPetDetailsViewController.h"
#import "Pet.h"
#import "Therapy.h"
#import "Photo.h"
#import "WeightPoint.h"
#import "AppDelegate.h"
#import "SimpleScatterPlot.h"
#import "Appointment.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

#define kBorderInset            20.0
#define kMainTextMargin         60.0
#define kTherapyMargin          210.0
#define kMainTextNewLine        20.0
#define kBorderWidth            1.0
#define kMarginInset            10.0
#define kLineWidth              1.0

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface ShowPetDetailsViewController () <UIActionSheetDelegate, UIPrintInteractionControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UIScrollViewDelegate>

    @property (weak, nonatomic) IBOutlet UILabel *breedLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *breedImageView;

    @property (weak, nonatomic) IBOutlet UILabel *weightLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *weightImageView;

    @property (weak, nonatomic) IBOutlet UILabel *agelLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *ageImageView;

    @property (weak, nonatomic) IBOutlet UILabel *appointmentLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *appointmentImageView;

    @property (weak, nonatomic) IBOutlet UILabel *microchipLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *microchipImageView;

    @property (weak, nonatomic) IBOutlet UILabel *registeredLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *registeredImageView;

    @property (weak, nonatomic) IBOutlet UILabel *infoPanelLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *infoPanelImageView;

    @property (weak, nonatomic) IBOutlet UIImageView *petImage;
    @property (weak, nonatomic) IBOutlet UIImageView *pawsBackgroundImageView;

    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftProfilePicConstraint;
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightProfilePicConstraint;
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ShowPetDetailsViewController
{
    NSDate *lastWeightDate;
    NSDate *lastTherapyDate;
    NSDate *lastAppointmentDate;
    NSString *lastWeightValue;
    NSArray *therapiesArray;
    NSMutableArray *arrayOfWeightPoints;
    
    CGSize pageSize;
    NSMutableParagraphStyle *textStyleCenterAligned;
    NSMutableParagraphStyle *textStyleLeftAligned;
    
    NSManagedObjectContext *context;
    NSDateFormatter *dateFormatter;
    
    dispatch_queue_t queue5;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollView.delegate = self;
    
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    
    self.pawsBackgroundImageView.image = [UIImage imageNamed:@"paws"];
    
    self.breedImageView.image = [UIImage imageNamed:@"breedImage"];
    self.breedImageView.alpha = 0.5;
    self.weightImageView.image = [UIImage imageNamed:@"weightImage"];
    self.weightImageView.alpha = 0.5;
    self.ageImageView.image = [UIImage imageNamed:@"ageImage"];
    self.ageImageView.alpha = 0.5;
    self.appointmentImageView.image = [UIImage imageNamed:@"appointmentImage"];
    self.appointmentImageView.alpha = 0.5;
    self.microchipImageView.image = [UIImage imageNamed:@"microchipImage"];
    self.microchipImageView.alpha = 0.5;
    self.registeredImageView.image = [UIImage imageNamed:@"registeredAtImage"];
    self.registeredImageView.alpha = 0.5;
    self.infoPanelImageView.image = [UIImage imageNamed:@"infoPanelImage"];
    self.infoPanelImageView.alpha = 0.5;
    
    self.petImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.petImage.clipsToBounds = YES;
    self.petImage.layer.cornerRadius = 5.0f;
    
    if (IS_WIDESCREEN) {
        self.leftProfilePicConstraint.constant = 55.0;
        self.rightProfilePicConstraint.constant = 55.0f;
        self.petImage.layer.cornerRadius = 10.0f;
    }
    
    queue5 = dispatch_queue_create("com.plusangel.queue5",nil);
    pageSize = CGSizeMake(595.4, 841.7); // Set size to A4
    
    textStyleCenterAligned = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyleCenterAligned.lineBreakMode = NSLineBreakByWordWrapping;
    textStyleCenterAligned.alignment = NSTextAlignmentCenter;
    
    textStyleLeftAligned = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyleLeftAligned.lineBreakMode = NSLineBreakByWordWrapping;
    textStyleLeftAligned.alignment = NSTextAlignmentLeft;
    
    
    //[[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    lastWeightDate = [[NSDate alloc] init];
    
    [[[self tabBarController] navigationItem] setTitle:self.pet.name];
    if (self.pet.photo.image == nil) {
        self.petImage.contentMode = UIViewContentModeScaleAspectFit;
        if (self.pet.kind == NO) {
            self.petImage.image = [UIImage imageNamed:@"defaultCatImage.png"];
        } else {
            self.petImage.image = [UIImage imageNamed:@"defaultDogImage.png"];
        }
    } else {
        self.petImage.contentMode =  UIViewContentModeScaleToFill;
        self.petImage.image = self.pet.photo.image;
    }
    

    self.agelLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Age:", @"Age string"), [self age:self.pet.dob]];
    self.breedLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Breed:", @"Breed string"), self.pet.breed];
    
    if ([self.pet.microchip length] != 0 && self.pet.registration != nil) {
        self.microchipLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Microchip:", @"Microchip string"), self.pet.microchip];
        self.registeredLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Registered at:", @"Registration string"), [dateFormatter stringFromDate:self.pet.registration]];
        self.microchipLabel.textColor = [UIColor blackColor];
        self.registeredLabel.textColor = [UIColor blackColor];
    } else {
        self.microchipLabel.text = NSLocalizedString(@"Microchip not defined", @"Microchip not defined string") ;
        self.registeredLabel.text = NSLocalizedString(@"Registration date not defined", @"Registration date not defined string") ;
        self.microchipLabel.textColor = [UIColor grayColor];
        self.registeredLabel.textColor = [UIColor grayColor];
    }
    
    if (self.pet.weight != nil) {
        arrayOfWeightPoints = [NSKeyedUnarchiver unarchiveObjectWithData:self.pet.weight];
        
        dispatch_async(queue5, ^{
            [self createChart];
        });
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                           target:self
                                                                           action:@selector(showActionSheet:)];
    
    [[[self tabBarController] navigationItem] setRightBarButtonItem:action animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[[self tabBarController] navigationItem] setRightBarButtonItem:nil animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.pet.weight != nil) {
        arrayOfWeightPoints = [NSKeyedUnarchiver unarchiveObjectWithData:self.pet.weight];
        if (arrayOfWeightPoints.count != 0) {
            WeightPoint *lastWeightPoint = [arrayOfWeightPoints objectAtIndex:0];
            lastWeightValue =  [NSString stringWithFormat:@"%@ %@", [[lastWeightPoint weight] stringValue], (self.weightUnit?@"lb":@"kg")];
            self.weightLabel.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"Weight:", @"Weight string"), [[lastWeightPoint weight] stringValue], (self.weightUnit?@"lb":@"kg")];
            lastWeightDate = [lastWeightPoint date];
            self.weightLabel.textColor = [UIColor blackColor];
        } else {
            self.weightLabel.text = [NSString stringWithFormat: NSLocalizedString(@"Weight: hasn't been weighed", @"No weight data warning")];
            self.weightLabel.textColor = [UIColor grayColor];
        }
        
        dispatch_async(queue5, ^{
            [self createChart];
        });
    } else {
        self.weightLabel.text = [NSString stringWithFormat: NSLocalizedString(@"Weight: hasn't been weighed", @"No weight data warning")];
        self.weightLabel.textColor = [UIColor grayColor];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    context = self.pet.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:context];
    [request setEntity:entity];
    
    // Set the sort descriptor
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"appointmentDate" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    // Fetch therapy of the selected pet
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pet=%@", self.pet];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    
    if ([mutableFetchResults count] != 0) {
    
        NSArray *arrayOfAppointments = mutableFetchResults;
        
        lastAppointmentDate = [[arrayOfAppointments objectAtIndex:0] appointmentDate];

        [arrayOfAppointments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDate *upcomingAppointment = [(Appointment *)obj appointmentDate];
            if ([upcomingAppointment compare:[NSDate date]] == NSOrderedDescending) {
                lastAppointmentDate = upcomingAppointment;
                *stop = YES;
            }
        }];
    }
    
    if (lastAppointmentDate != nil) {
        self.appointmentLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Next appointment on:", @"Next appointment string"), [dateFormatter stringFromDate:lastAppointmentDate]];
        self.appointmentLabel.textColor = [UIColor blackColor];
    } else {
        self.appointmentLabel.text = [NSString stringWithFormat: NSLocalizedString(@"Next appointment not defined", @"No appointment data")];
        self.appointmentLabel.textColor = [UIColor grayColor];
    }
    
    NSSet *therapiesSet = [self.pet therapy];
    therapiesArray = [therapiesSet allObjects];

    lastTherapyDate = [[therapiesArray lastObject] dateOfTherapy];
    
    // infoPanel hide or not settings
    NSString *infoString = [self infoPanel];
    if (infoString.length != 0) {
        self.infoPanelLabel.hidden = NO;
        self.infoPanelImageView.hidden = NO;
        self.infoPanelLabel.text = infoString;
        self.infoPanelLabel.textColor = [UIColor redColor];
        self.pawsBackgroundImageView.hidden = YES;
    } else {
        self.infoPanelLabel.hidden = YES;
        self.infoPanelImageView.hidden = YES;
        self.pawsBackgroundImageView.hidden = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Helper methods

- (NSString *)age:(NSDate *)dateOfBirth {
    
    NSInteger years; 
    NSInteger months;
    NSInteger days = 0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
    
    if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
        (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
        years = [dateComponentsNow year] - [dateComponentsBirth year] - 1;
    } else {
        years = [dateComponentsNow year] - [dateComponentsBirth year];
    }
    
    
    if ([dateComponentsNow year] == [dateComponentsBirth year]) {
        months = [dateComponentsNow month] - [dateComponentsBirth month];
    } else if ([dateComponentsNow year] > [dateComponentsBirth year] && [dateComponentsNow month] > [dateComponentsBirth month]) {
        months = [dateComponentsNow month] - [dateComponentsBirth month];
    } else if ([dateComponentsNow year] > [dateComponentsBirth year] && [dateComponentsNow month] < [dateComponentsBirth month]) {
        months = [dateComponentsNow month] - [dateComponentsBirth month] + 12;
    } else if ([dateComponentsNow year] > [dateComponentsBirth year] && [dateComponentsNow month] == [dateComponentsBirth month] && [dateComponentsNow day] < [dateComponentsBirth day]) {
        months = 11;
    } else {
        months = [dateComponentsNow month] - [dateComponentsBirth month];
    }
    
    
    if ([dateComponentsNow year] == [dateComponentsBirth year] && [dateComponentsNow month] == [dateComponentsBirth month]) {
        days = [dateComponentsNow day] - [dateComponentsBirth day];
    }
    
    if (years == 0 && months == 0) {
        if (days == 1) {
            return [NSString stringWithFormat:@"%ld %@", (long)days, NSLocalizedString(@"day", @"day")];
        } else {
            return [NSString stringWithFormat:@"%ld %@", (long)days, NSLocalizedString(@"days", @"days")];
        }
    } else if (years == 0) {
        if (months == 1) {
            return [NSString stringWithFormat:@"%ld %@", (long)months, NSLocalizedString(@"month", @"month")];
        } else {
            return [NSString stringWithFormat:@"%ld %@", (long)months, NSLocalizedString(@"months", @"months")];
        }
    } else if ((years != 0) && (months == 0)) {
        if (years == 1) {
            return [NSString stringWithFormat:@"%ld %@", (long)years, NSLocalizedString(@"year", @"year")];
        } else {
            return [NSString stringWithFormat:@"%ld %@", (long)years, NSLocalizedString(@"years", @"years")];
        }
    } else {
        if ((years == 1) && (months == 1)) {
            return [NSString stringWithFormat:@"%ld %@ %ld %@", (long)years, NSLocalizedString(@"year and", @"year and"), (long)months, NSLocalizedString(@"month", @"month")];
        } else if (years == 1) {
            return [NSString stringWithFormat:@"%ld %@ %ld %@", (long)years, NSLocalizedString(@"year and", @"year and"), (long)months, NSLocalizedString(@"months", @"months")];
        } else if (months == 1) {
            return [NSString stringWithFormat:@"%ld %@ %ld %@", (long)years, NSLocalizedString(@"years and", @"years and"), (long)months, NSLocalizedString(@"month", @"month")];
        } else {
            return [NSString stringWithFormat:@"%ld %@ %ld %@", (long)years, NSLocalizedString(@"years and", @"years and"), (long)months, NSLocalizedString(@"months", @"months")];
        }
    }
}


- (NSInteger)daysUntilBirthday:(NSDate *)birthday
{
    NSDate *today = [NSDate date];
    NSDateComponents *year = [[NSDateComponents alloc] init];
    NSInteger yearDiff = 1;
    NSDate *newBirthday = birthday;
    
    while([newBirthday earlierDate:today] == newBirthday) {
        [year setYear:yearDiff++];
        newBirthday = [[NSCalendar currentCalendar] dateByAddingComponents:year toDate:birthday options:0];
    }
    
    NSDateComponents *d = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:today toDate:newBirthday options:0];
    NSInteger difference = [d day];
    return difference;
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


#pragma mark - Provide info

- (NSString *)infoPanel
{
    NSDate *today = [NSDate date];
    
    NSInteger daysFromTherapy = 0;
    NSInteger daysTillBD = [self daysUntilBirthday:self.pet.dob];
    NSInteger daysFromWeight = [self daysBetweenDate:lastWeightDate andDate:today];
    if (lastTherapyDate) {
        daysFromTherapy = [self daysBetweenDate:lastTherapyDate andDate:today];
    }
    
    // show 50% of the times
    srand((unsigned int)time(nil));
    int r = rand()%2;
    
    if (daysTillBD == 0) {
        return [NSString stringWithFormat:@"%@ %@%@", NSLocalizedString(@"Tomorrow is", @"Tomorrow is string"), self.pet.name, NSLocalizedString(@"'s birthday!", @" birthday string")];
    } else if (daysTillBD < 30 && daysTillBD != 0) {
        return [NSString stringWithFormat:@"%ld %@", (long)daysTillBD, NSLocalizedString(@"days till birthday!", @"birthday countdown string")];
    } else if (daysFromWeight > 25 && r == 0) {
        return [NSString stringWithFormat:@"%ld %@", (long)daysFromWeight, NSLocalizedString(@"days since the last weight", @"days since the last weight string")];
    } else if (daysFromTherapy > 25 && r == 1 && therapiesArray.count != 0) {
        return [NSString stringWithFormat:@"%ld %@", (long)daysFromTherapy, NSLocalizedString(@"days since the last therapy", @"days since the last therapy string") ];
    } else {
        return nil;
    }
}

#pragma mark - IBActions

- (IBAction)showActionSheet:(id)sender
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel String")
                                              destructiveButtonTitle:NSLocalizedString(@"Remove pet", @"Remove Pet String")
                                                   otherButtonTitles:NSLocalizedString(@"Email pet's report", @"Email report String"), NSLocalizedString(@"Print pet's report", @"Print report String"), nil];
    
    popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
    [popupQuery showInView:[self.view window]];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:NSLocalizedString(@"Continue", @"Continue String")])
    {
        [self.delegate showPetDetailsViewController:self remove:self.pet];
    }
    
}
#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2) {
        
        [self createPdf];
        [self printContent];
    } else if (buttonIndex == 1) {
        
        [self createPdf];
        [self mailContent];
    } else if (buttonIndex == 0) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remove pet", @"Remove Pet String")
                                    message:NSLocalizedString(@"Are you sure that you want to remove the selected pet?", @"Removing a pet confirmation message")
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel String") 
                          otherButtonTitles:NSLocalizedString(@"Continue", @"Continue String"), nil] show];
    }
}

#pragma mark - mailing id

- (void)mailContent
{
    if ([MFMailComposeViewController canSendMail]) {
        NSString *fileName = [NSString stringWithFormat:@"%@.pdf", self.pet.name];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:fileName];
        NSData *dataFromPath = [NSData dataWithContentsOfFile:pdfPath];
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setSubject:NSLocalizedString(@"Record of health and vaccination", @"Subject of id email")];
        [picker setMessageBody:NSLocalizedString(@"Please find attached a record of health and vaccination for my pet", @"The body of email report") isHTML:NO];
        [picker addAttachmentData:dataFromPath mimeType:@"application/pdf" fileName:[NSString stringWithFormat:@"%@.pdf",self.pet.name]];
        
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Problem with email", @"Fail to email title")
                                                        message:NSLocalizedString(@"Your device is not configured to send emails.", @"Unable to email message.")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableString *messageString = [[NSMutableString alloc] init];
    
    if (result == MFMailComposeResultSent) {
        [messageString appendFormat:NSLocalizedString(@"Thanks! ", @"Thanks String")];
        [messageString appendFormat:NSLocalizedString(@"Your pet's record of health and vaccination sent succesfully.", @"id sent succesfully alert")];
        UIAlertView *abortAlert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:messageString
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        [abortAlert show];
        }
}


#pragma mark - printing id

- (void)printContent
{
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.pdf", self.pet.name];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSData *dataFromPath = [NSData dataWithContentsOfFile:pdfPath];
    
    if (pic && [UIPrintInteractionController canPrintData:dataFromPath]) {
        pic.delegate = self;
        
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = [pdfPath lastPathComponent];
        printInfo.duplex = UIPrintInfoDuplexNone;
        pic.printInfo = printInfo;
        pic.showsPageRange = NO;
        pic.printingItem = dataFromPath;
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed && error) {
                [(AppDelegate *)[UIApplication sharedApplication].delegate presentError:error WithText:NSLocalizedString(@"print the record of health and vaccination", @"Error description in printing the report")];
            }
        };
        
        [pic presentAnimated:YES completionHandler:completionHandler];
    }
}

#pragma mark - compose document
- (void)createChart
{
    if (arrayOfWeightPoints.count > 2) {
        CPTGraphHostingView *graphHostingView;;
        SimpleScatterPlot *scatterPlot;
        scatterPlot = [[SimpleScatterPlot alloc] initWithHostingView:graphHostingView andData:arrayOfWeightPoints inView:nil];
        scatterPlot.onScreen = NO;
        scatterPlot.petsName = self.pet.name;
    }
}

- (void)createPdf
{
    NSString *fileName = [NSString stringWithFormat:@"%@.pdf", self.pet.name];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFileName = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    [self generatePdfWithFilePath:pdfFileName];
}

- (void)drawCredit
{
    NSString *creditsString = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"Report generated on", @"Report generated on String"), [dateFormatter stringFromDate:[NSDate date]], NSLocalizedString(@"using about Pets App", @"using about Pets App String")];
    UIFont *theFont = [UIFont systemFontOfSize:8];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:creditsString attributes:@{NSFontAttributeName:theFont, NSParagraphStyleAttributeName:textStyleCenterAligned}];
    CGRect rect = [attributedText boundingRectWithSize:pageSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize creditsStringSize = rect.size;
                                          
    CGRect stringRenderingRect = CGRectMake(kBorderInset, pageSize.height - 40.0, pageSize.width - 2*kBorderInset, creditsStringSize.height);
    [creditsString drawInRect:stringRenderingRect withAttributes:@{NSFontAttributeName:theFont, NSParagraphStyleAttributeName:textStyleCenterAligned}];
}

- (void)drawBorder
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    UIColor *borderColor = [UIColor brownColor];
    CGRect rectFrame = CGRectMake(kBorderInset, kBorderInset, pageSize.width - 2*kBorderInset, pageSize.height - 2*kBorderInset);
    CGContextSetStrokeColorWithColor(currentContext, borderColor.CGColor);
    CGContextSetLineWidth(currentContext, kBorderWidth);
    CGContextStrokeRect(currentContext, rectFrame);
}

- (void) drawHeader
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.3, 0.7, 0.2, 1.0);
    
    NSString *textToDraw = [NSString stringWithFormat:@"%@%@", self.pet.name, NSLocalizedString(@"'s record of health and vaccination", @"'s record of health and vaccination String")];
    
    UIFont *font = [UIFont systemFontOfSize:24.0];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:textToDraw attributes:@{NSFontAttributeName:font}];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize stringSize = rect.size;
    
    CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset, pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
    
    UIColor *color = [UIColor greenColor];
    [textToDraw drawInRect:renderingRect withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyleCenterAligned, NSForegroundColorAttributeName:color}];
}

- (void)drawline
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(currentContext, kLineWidth);
    CGContextSetStrokeColorWithColor(currentContext, [UIColor blueColor].CGColor);
    
    CGPoint startPoint = CGPointMake(kMarginInset + kBorderInset, kMarginInset + kBorderInset + 40.0);
    CGPoint endPoint = CGPointMake(pageSize.width - kMarginInset - kBorderInset, kMarginInset + kBorderInset + 40.0);
    
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    CGContextClosePath(currentContext);
    
    CGContextDrawPath(currentContext, kCGPathFillStroke);
}

- (void)drawText
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
    UIFont *font = [UIFont systemFontOfSize:14.0];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:14.0];
    UIFont *italicFont = [UIFont italicSystemFontOfSize:14.0];
    
    // Name
    NSString *nameTitleString = NSLocalizedString(@"Name: ", @"Name String");
    NSString *nameValueString = self.pet.name;
    
    NSAttributedString *attributedNameStringSizeB = [[NSAttributedString alloc] initWithString:nameValueString attributes:@{NSFontAttributeName:boldFont}];
    CGRect rectNameStringB = [attributedNameStringSizeB boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize nameStringSizeB = rectNameStringB.size;
    
    NSAttributedString *attributedNameStringSize = [[NSAttributedString alloc] initWithString:nameTitleString attributes:@{NSFontAttributeName:font}];
    CGRect rectNameString = [attributedNameStringSize boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize nameStringSize = rectNameString.size;
    
    
    CGRect nameRenderingRectB = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + kMainTextMargin, pageSize.width - 2*kBorderInset - 2*kMarginInset, nameStringSizeB.height);
    CGRect nameRenderingRect = CGRectMake(kBorderInset + kMarginInset + nameStringSizeB.width + 5, kBorderInset + kMarginInset + kMainTextMargin, pageSize.width - 2*kBorderInset - 2*kMarginInset, nameStringSize.height);
    
    [nameTitleString drawInRect:nameRenderingRectB withAttributes:@{NSFontAttributeName:boldFont, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    [nameValueString drawInRect:nameRenderingRect withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    
    // Date of Birth
    NSString *dobTitleString = NSLocalizedString(@"Date of birth: ", @"Date of birth String");
    NSString *dobValueString = [dateFormatter stringFromDate:self.pet.dob];
    
    NSAttributedString *attributedDobStringSizeB = [[NSAttributedString alloc] initWithString:dobTitleString attributes:@{NSFontAttributeName:boldFont}];
    CGRect rectDobStringB = [attributedDobStringSizeB boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize dobStringSizeB = rectDobStringB.size;
    
    NSAttributedString *attributedDobStringSize = [[NSAttributedString alloc] initWithString:dobValueString attributes:@{NSFontAttributeName:font}];
    CGRect rectDobString = [attributedDobStringSize boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize dobStringSize = rectDobString.size;
    
    CGRect dobRenderingRectB = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + kMainTextMargin + kMainTextNewLine, pageSize.width - 2*kBorderInset - 2*kMarginInset, dobStringSizeB.height);
    CGRect dobRenderingRect = CGRectMake(kBorderInset + kMarginInset + dobStringSizeB.width + 5, kBorderInset + kMarginInset + kMainTextMargin + kMainTextNewLine, pageSize.width - 2*kBorderInset - 2*kMarginInset, dobStringSize.height);
    
    [dobTitleString drawInRect:dobRenderingRectB withAttributes:@{NSFontAttributeName:boldFont, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    [dobValueString drawInRect:dobRenderingRect withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    
    // sex
    NSString *sexTitleString = NSLocalizedString(@"Sex: ", @"Sex String");
    NSString *sexValueString = (self.pet.sex?NSLocalizedString(@"Female", @"Female String"):NSLocalizedString(@"Male", @"Male String"));
    
    NSAttributedString *attributedSexStringSizeB = [[NSAttributedString alloc] initWithString:sexTitleString attributes:@{NSFontAttributeName:boldFont}];
    CGRect rectSexStringB = [attributedSexStringSizeB boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize sexStringSizeB = rectSexStringB.size;
    
    NSAttributedString *attributedSexStringSize = [[NSAttributedString alloc] initWithString:sexValueString attributes:@{NSFontAttributeName:font}];
    CGRect rectSexString = [attributedSexStringSize boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize sexStringSize = rectSexString.size;
    
    CGRect sexRenderingRectB = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + kMainTextMargin + 2*kMainTextNewLine, pageSize.width - 2*kBorderInset - 2*kMarginInset, sexStringSizeB.height);
    CGRect sexRenderingRect = CGRectMake(kBorderInset + kMarginInset + sexStringSizeB.width + 5, kBorderInset + kMarginInset + kMainTextMargin + 2*kMainTextNewLine, pageSize.width - 2*kBorderInset - 2*kMarginInset, sexStringSize.height);
    
    [sexTitleString drawInRect:sexRenderingRectB withAttributes:@{NSFontAttributeName:boldFont, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    [sexValueString drawInRect:sexRenderingRect withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    
    // Breed
    NSString *breedTitleString = NSLocalizedString(@"Breed: ", @"Breed String");
    NSString *breedValueString = self.pet.breed;
    
    NSAttributedString *attributedBreedStringSizeB = [[NSAttributedString alloc] initWithString:breedTitleString attributes:@{NSFontAttributeName:boldFont}];
    CGRect rectBreedStringB = [attributedBreedStringSizeB boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize breedStringSizeB = rectBreedStringB.size;
    
    NSAttributedString *attributedBreedStringSize = [[NSAttributedString alloc] initWithString:breedValueString attributes:@{NSFontAttributeName:font}];
    CGRect rectBreedString = [attributedBreedStringSize boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize breedStringSize = rectBreedString.size;
    
    CGRect breedRenderingRectB = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + kMainTextMargin + 3*kMainTextNewLine, pageSize.width - 2*kBorderInset - 2*kMarginInset, breedStringSizeB.height);
    CGRect breedRenderingRect = CGRectMake(kBorderInset + kMarginInset + breedStringSizeB.width + 5, kBorderInset + kMarginInset + kMainTextMargin + 3*kMainTextNewLine, pageSize.width - 2*kBorderInset - 2*kMarginInset, breedStringSize.height);
    
    [breedTitleString drawInRect:breedRenderingRectB withAttributes:@{NSFontAttributeName:boldFont, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    [breedValueString drawInRect:breedRenderingRect withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    
    // Weight
    NSString *weightTitleString = NSLocalizedString(@"Weight: ", @"Weight String");
    NSString *weightValueString = lastWeightValue;
    
    NSAttributedString *attributedWeightStringSizeB = [[NSAttributedString alloc] initWithString:weightTitleString attributes:@{NSFontAttributeName:boldFont}];
    CGRect rectWeightStringB = [attributedWeightStringSizeB boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize weightStringSizeB = rectWeightStringB.size;
    
    NSAttributedString *attributedWeightStringSize = [[NSAttributedString alloc] initWithString:weightValueString attributes:@{NSFontAttributeName:font}];
    CGRect rectWeightString = [attributedWeightStringSize boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize weightStringSize = rectWeightString.size;
    
    CGRect weightRenderingRectB = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + kMainTextMargin + 4*kMainTextNewLine, pageSize.width - 2*kBorderInset - 2*kMarginInset, weightStringSizeB.height);
    CGRect weightRenderingRect = CGRectMake(kBorderInset + kMarginInset + weightStringSizeB.width + 5, kBorderInset + kMarginInset + kMainTextMargin + 4*kMainTextNewLine, pageSize.width - 2*kBorderInset - 2*kMarginInset, weightStringSize.height);
    
    [weightTitleString drawInRect:weightRenderingRectB withAttributes:@{NSFontAttributeName:boldFont, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    [weightValueString drawInRect:weightRenderingRect withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    
    // Identification title
    NSString *identificationTitleString = NSLocalizedString(@"Identification number", @"Identification number String");
    
    NSAttributedString *attributedIdentificationStringSizeB = [[NSAttributedString alloc] initWithString:identificationTitleString attributes:@{NSFontAttributeName:italicFont}];
    CGRect rectIdentificationStringB = [attributedIdentificationStringSizeB boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize identificationStringSizeB = rectIdentificationStringB.size;
    
    CGRect identificationRenderingRectB = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + kMainTextMargin + 5*kMainTextNewLine + 10.0, pageSize.width - 2*kBorderInset - 2*kMarginInset, identificationStringSizeB.height);
    
    [identificationTitleString drawInRect:identificationRenderingRectB withAttributes:@{NSFontAttributeName:italicFont, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    
    // Microchip
    NSString *microchipTitleString = NSLocalizedString(@"Microchip: ", @"Microchip String");
    NSString *microchipValueString;
    
    if (self.pet.microchip.length == 0) {
        microchipValueString = NSLocalizedString(@"not defined", @"not defined String") ;
    } else {
        microchipValueString = self.pet.microchip;
    }
    
    NSAttributedString *attributedMicrochipStringSizeB = [[NSAttributedString alloc] initWithString:microchipTitleString attributes:@{NSFontAttributeName:boldFont}];
    CGRect rectMicrochipStringB = [attributedMicrochipStringSizeB boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize microchipStringSizeB = rectMicrochipStringB.size;
    
    NSAttributedString *attributedMicrochipStringSize = [[NSAttributedString alloc] initWithString:microchipValueString attributes:@{NSFontAttributeName:font}];
    CGRect rectMicrochipString = [attributedMicrochipStringSize boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize microchipStringSize = rectMicrochipString.size;
    
    CGRect microchipRenderingRectB = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + kMainTextMargin + 6*kMainTextNewLine + 10.0, pageSize.width - 2*kBorderInset - 2*kMarginInset, microchipStringSizeB.height);
    CGRect microchipRenderingRect = CGRectMake(kBorderInset + kMarginInset + microchipStringSizeB.width + 5, kBorderInset + kMarginInset + kMainTextMargin + 6*kMainTextNewLine + 10.0, pageSize.width - 2*kBorderInset - 2*kMarginInset, microchipStringSize.height);
    
    [microchipTitleString drawInRect:microchipRenderingRectB withAttributes:@{NSFontAttributeName:boldFont, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    [microchipValueString drawInRect:microchipRenderingRect withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    
    // Registered at
    NSString *registerTitleString = NSLocalizedString(@"Registered at: ", @"Registered at String");
    NSString *registerValueString;
    
    if (self.pet.registration == nil) {
        registerValueString = NSLocalizedString(@"not defined", @"not defined String");
    } else {
        registerValueString = [dateFormatter stringFromDate:self.pet.registration];
    }
    
    NSAttributedString *attributedRegisterStringSizeB = [[NSAttributedString alloc] initWithString:registerTitleString attributes:@{NSFontAttributeName:boldFont}];
    CGRect rectRegisterStringB = [attributedRegisterStringSizeB boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize registerStringSizeB = rectRegisterStringB.size;
    
    NSAttributedString *attributedRegisterStringSize = [[NSAttributedString alloc] initWithString:registerValueString attributes:@{NSFontAttributeName:font}];
    CGRect rectRegisterString = [attributedRegisterStringSize boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize registerStringSize = rectRegisterString.size;
    
    CGRect registerRenderingRectB = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + kMainTextMargin + 7*kMainTextNewLine + 10.0, pageSize.width - 2*kBorderInset - 2*kMarginInset, registerStringSizeB.height);
    CGRect registerRenderingRect = CGRectMake(kBorderInset + kMarginInset + registerStringSizeB.width + 5, kBorderInset + kMarginInset + kMainTextMargin + 7*kMainTextNewLine + 10.0, pageSize.width - 2*kBorderInset - 2*kMarginInset, registerStringSize.height);
    
    [registerTitleString drawInRect:registerRenderingRectB withAttributes:@{NSFontAttributeName:boldFont, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    [registerValueString drawInRect:registerRenderingRect withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    
}

- (void)drawImage
{
    UIImage *profileImage = self.petImage.image;
    [profileImage drawInRect:CGRectMake(pageSize.width/2, 100.0, profileImage.size.width, profileImage.size.height)];
}

- (void)drawTherapies
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
    UIFont *font = [UIFont systemFontOfSize:14.0];
    UIFont *italicFont = [UIFont italicSystemFontOfSize:14.0];
    
    // therapies title
    NSString *therapiesTitleString;
    NSUInteger therapiesTotal = therapiesArray.count;
    
    if (therapiesTotal == 0) {
        therapiesTitleString = NSLocalizedString(@"No therapies have been declared", @"No therapies have been declared String");
    } else if (therapiesTotal == 1) {
        therapiesTitleString = NSLocalizedString(@"One therapy has been done:", @"One therapy has been done String");
    } else if (therapiesTotal < 10) {
        therapiesTitleString = [NSString stringWithFormat: @"%@ %lu %@", NSLocalizedString(@"The last", @"The last String"), (unsigned long)therapiesTotal, NSLocalizedString(@"therapies are:", @"therapies are String")];
    } else {
        therapiesTitleString = NSLocalizedString(@"The last 10 therapies are: ", @"The last 10 therapies are String") ;
    }
    
    NSAttributedString *attributedTherapiesStringSizeB = [[NSAttributedString alloc] initWithString:therapiesTitleString attributes:@{NSFontAttributeName:italicFont}];
    CGRect rectTherapiesStringB = [attributedTherapiesStringSizeB boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize therapiesStringSizeB = rectTherapiesStringB.size;
    
    CGRect therapiesRenderingRectB = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + kMainTextMargin + kTherapyMargin - 20.0, pageSize.width - 2*kBorderInset - 2*kMarginInset, therapiesStringSizeB.height);
    
    [therapiesTitleString drawInRect:therapiesRenderingRectB withAttributes:@{NSFontAttributeName:italicFont, NSParagraphStyleAttributeName:textStyleLeftAligned}];
    
    [therapiesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Therapy *currentTherapy = (Therapy *)obj;
        NSString *currentString;
        
        if (currentTherapy.product.length != 0) {
            currentString = [NSString stringWithFormat:@"- %@ %@ %@ %@ %@", currentTherapy.therapyType, NSLocalizedString(@"using", @"using String"), currentTherapy.product, NSLocalizedString(@"on", @"on String"), [dateFormatter stringFromDate:currentTherapy.dateOfTherapy]];
        } else {
            currentString = [NSString stringWithFormat:@"- %@ %@ %@", currentTherapy.therapyType, NSLocalizedString(@"on", @"on String"), [dateFormatter stringFromDate:currentTherapy.dateOfTherapy]];
        }
        
        NSAttributedString *attributedTherapiesStringSize = [[NSAttributedString alloc] initWithString:currentString attributes:@{NSFontAttributeName:font}];
        CGRect rectTherapiesString = [attributedTherapiesStringSize boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        CGSize therapiesStringSize = rectTherapiesString.size;
        
        CGRect therapiesRenderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + kMainTextMargin + kTherapyMargin + idx*kMainTextNewLine, pageSize.width - 2*kBorderInset - 2*kMarginInset, therapiesStringSize.height);
        [currentString drawInRect:therapiesRenderingRect withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyleLeftAligned}];
        
        if (idx == 9) {
            *stop = YES;
        }
    }];
}

- (void)drawChart
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* chartFile = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.pet.name]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:chartFile];
    
    if (fileExists) {
        UIFont *italicFont = [UIFont italicSystemFontOfSize:14.0];
        NSString *chartTitleString = [NSString stringWithFormat:@"%@%@", self.pet.name, NSLocalizedString(@"'s weight over time", @"'s weight over time String")];
        
        NSAttributedString *attributedChartStringSizeB = [[NSAttributedString alloc] initWithString:chartTitleString attributes:@{NSFontAttributeName:italicFont}];
        CGRect rectChartStringB = [attributedChartStringSizeB boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        CGSize chartStringSizeB = rectChartStringB.size;
        
        CGRect chartRenderingRectB = CGRectMake(kBorderInset + kMarginInset, 500.0, pageSize.width - 2*kBorderInset - 2*kMarginInset, chartStringSizeB.height);
        
        [chartTitleString drawInRect:chartRenderingRectB withAttributes:@{NSFontAttributeName:italicFont, NSParagraphStyleAttributeName:textStyleLeftAligned}];
        
        UIImage *chartImage = [UIImage imageWithContentsOfFile:chartFile];
        //[chartImage drawInRect:CGRectMake(185, 510.0, 224.0, 257.0)]; // scale 0.7
        [chartImage drawInRect:CGRectMake(78.0, 510.0, 420.0, 257.0)];
    }
}

- (void) generatePdfWithFilePath:(NSString *)thefilePath
{
    UIGraphicsBeginPDFContextToFile(thefilePath, CGRectZero, nil);
    
    BOOL done = NO;
    
    do {
        // mark the beginning of a new page
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
        
        // draw credit string at the bottom of page
        [self drawCredit];
        
        // draw a border for each page
        [self drawBorder];
        
        // draw text for header
        [self drawHeader];
        
        // draw a line bellow the header
        [self drawline];
        
        // draw the text fro the line
        [self drawText];
        
        // draw the image
        [self drawImage];
        
        // draw therapies array
        [self drawTherapies];
        
        // draw weight chart
        [self drawChart];
        
        done = YES;
    } while (!done);
    
    UIGraphicsEndPDFContext();
}

@end
