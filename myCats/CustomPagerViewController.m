//
//  CustomPageViewController.m
//  PageViewController
//
//  Created by Tom Fewster on 11/01/2012.
//

#import "CustomPagerViewController.h"
#import "WeightGuideViewController.h"

@interface CustomPagerViewController ()

@end

@implementation CustomPagerViewController

- (void)viewDidLoad
{
	// Do any additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
        
	[self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"View1"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"View2"]];
	[self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"View3"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"View4"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"View5"]];
    
    NSUInteger pageIndex = 1;
    for (WeightGuideViewController *vc in self.childViewControllers) {
        vc.kind = self.kind;
        vc.guidePage = pageIndex++;
    }
}

@end
