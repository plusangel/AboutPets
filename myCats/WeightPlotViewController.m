//
//  WeightPlotViewController.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 17/2/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import "WeightPlotViewController.h"
#import "WeightPoint.h"
#import "Pet.h"
#import "WeightPointsListViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "SimpleScatterPlot.h"

@interface WeightPlotViewController() <UIScrollViewDelegate,SimpleScatterPlotDelegate>
    @property (nonatomic, weak) IBOutlet CPTGraphHostingView *graphHostingView;
    @property (nonatomic, weak) IBOutlet UILabel *warningLabel;
@end

@implementation WeightPlotViewController
{
    SimpleScatterPlot *scatterPlot;
    NSMutableArray *arrayOfPoints;
    UIView *helpView;
    UIImageView *weightPlotHelpListMessageImageView;
    BOOL _hideStatusBar;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showHelp];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    // show list navigation bar button
    [super viewDidAppear:animated];

    UIBarButtonItem *list = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"List", @"List") 
                                                             style:UIBarButtonItemStyleBordered 
                                                            target:self 
                                                            action:@selector(showWeightPointsViewController)];
    
    [[[self tabBarController] navigationItem] setRightBarButtonItem:list animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[[self tabBarController] navigationItem] setRightBarButtonItem:nil animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.graphHostingView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:250.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(tapped:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    //self.tabBarController.tabBar.hidden = YES;
    //UIEdgeInsets inset = UIEdgeInsetsMake(64, 0, 0, 0);
    //self.tableView.contentInset = inset;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowWeightPoints"]) {
        WeightPointsListViewController *weightPointsListViewController = segue.destinationViewController;
        weightPointsListViewController.pet = self.pet;
        weightPointsListViewController.weightUnit = self.weightUnit;
        weightPointsListViewController.helpStatus = self.helpStatus;
    } 
}

#pragma mark - hide and show bars

- (void)tapped:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded && _hideStatusBar) {
        [scatterPlot sendTapMessage];
        [self showBars];
    }
}

- (void)showBars {
    _hideStatusBar = NO;
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
        self.navigationController.navigationBar.alpha = 1.0f;
        self.tabBarController.tabBar.alpha = 1.0f;
    }];
}

- (void)simpleScatterPlotController:(SimpleScatterPlot *)controller didHide:(BOOL)value
{
    if (value) {
        _hideStatusBar = YES;
    }
}

#pragma mark - Methods

- (void)showWeightPointsViewController
{
    [self performSegueWithIdentifier:@"ShowWeightPoints" sender:nil];
}

#pragma mark - Assistant methods

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
    
    if (self.pet.weight != nil) {
        arrayOfPoints = [NSKeyedUnarchiver unarchiveObjectWithData:self.pet.weight];
    }
    
    if ([arrayOfPoints count] < 3) {
        self.warningLabel.hidden = NO;
        
        [[self view] setBackgroundColor:[UIColor whiteColor]];
        
        if (scatterPlot) {
            [scatterPlot clearPlot];
        }
    } else {
        self.warningLabel.hidden = YES;
        
        [[self view] setBackgroundColor:[UIColor blackColor]];
        scatterPlot = [[SimpleScatterPlot alloc] initWithHostingView:_graphHostingView andData:arrayOfPoints inView:self.view];
        scatterPlot.delegate = self;
        scatterPlot.onScreen = YES;
        scatterPlot.petsName = self.pet.name;
        scatterPlot.myTabBar = self.tabBarController.tabBar;
        scatterPlot.myNavigationBar = self.navigationController.navigationBar;
    }
    
    if (self.helpStatus == YES) {
        if ([arrayOfPoints count] < 3 && helpView == nil) {
            helpView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 64.0, 320.0, 120.0)];
            weightPlotHelpListMessageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self localizeHelpMessages:@"weightPlotHelpMessageList.png" forLanguage:locale]]];
            [helpView addSubview:weightPlotHelpListMessageImageView];
            [self.view addSubview:helpView];
        } else if ([arrayOfPoints count] >= 3 && helpView) {
            [helpView removeFromSuperview];
        } else if ([arrayOfPoints count] < 3 && helpView) {
            [self.view addSubview:helpView];
        }
    } else {
        if (helpView) {
            [helpView removeFromSuperview];
        }
    }
    
}

@end
