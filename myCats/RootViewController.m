//
//  rootViewController.m
//  myPets
//
//  Created by Angelos Plastropoulos on 7/3/14.
//  Copyright (c) 2014 plusangel@gmail.com. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()
- (IBAction)strartWalkThrough:(id)sender;

@end

@implementation RootViewController

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
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)strartWalkThrough:(id)sender {
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == 5) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}


- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (index >= 5) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    
    pageContentViewController.imageFile = [self appropriateImage:index];
    pageContentViewController.titleText = [self appropriateText:index];
    
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 5;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - Helper methods

-(NSString *)appropriateImage:(NSUInteger)index
{
    NSString *fileName = [NSString stringWithFormat:@"%@%lu", self.kind?@"dog":@"cat", index + 1];
    
    return fileName;
}

-(NSString *)appropriateText:(NSUInteger)index
{
    NSString *description;
    
    switch (index) {
        case 0:
            description = NSLocalizedString(@"Ribs, spine and bony protrusions are easily seen at a distance. These pets have lost muscle mass and there is no observable body fat. Emaciated, bony, and starved in appearance.", @"cat1");
            break;
        case 1:
            description = NSLocalizedString(@"Ribs, spine and other bones are easily felt. These pets have an obvious waist when viewed from above and have an abdominal tuck. Thin, lean or skinny in appearance.", @"cat2");
            break;
        case 2:
            description = NSLocalizedString(@"Ribs and spine are easily felt but not necessarily seen. There is a waist when viewed from above and the abdomen is raised and not sagging when viewed from the side. Normal, ideal and often muscular in appearance.", @"cat3");
            break;
        case 3:
            description = NSLocalizedString(@"Ribs and spine are hard to feel or count underneath fat deposits. Waist is distended or often pear-shaped when viewed from above. The abdomen sags when seen from the side. There are typically fat deposits on the hips, base of tail and chest. Overweight, heavy, husky or stout.", @"cat4");
            break;
        case 4:
            description = NSLocalizedString(@"Large fat deposits over the chest, back, tail base and hindquarters. The abdomen sags prominently and there is no waist when viewed from above. The chest and abdomen often appear distended or swollen. Obese.", @"cat5");
            break;
            
        default:
            break;
    }
    
    return description;
}

@end
