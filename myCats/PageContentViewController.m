//
//  PageContentViewController.m
//  myPets
//
//  Created by Angelos Plastropoulos on 7/3/14.
//  Copyright (c) 2014 plusangel@gmail.com. All rights reserved.
//

#import "PageContentViewController.h"

@interface PageContentViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *petImageView;
@property (weak, nonatomic) IBOutlet UILabel *petWeightDescription;
@property (weak, nonatomic) IBOutlet UIImageView *petObesityPreventionImageView;
@end

@implementation PageContentViewController

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
    self.petWeightDescription.font = [UIFont fontWithName:@"Avenir-Light" size:14];

    self.petImageView.image = [UIImage imageNamed:self.imageFile];
    self.petWeightDescription.text = self.titleText;
    self.petObesityPreventionImageView.image = [UIImage imageNamed:@"firm"];
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

@end
