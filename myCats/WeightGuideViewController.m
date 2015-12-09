//
//  weightGuideViewController.m
//  myPets
//
//  Created by angelos plastropoulos on 1/12/13.
//  Copyright (c) 2013 plusangel@gmail.com. All rights reserved.
//

#import "WeightGuideViewController.h"

@interface WeightGuideViewController ()
    @property (weak, nonatomic) IBOutlet UIImageView *petImageView;
    @property (weak, nonatomic) IBOutlet UILabel *petWeightDescription;
    @property (weak, nonatomic) IBOutlet UIImageView *petObesityPreventionImageView;
@end

@implementation WeightGuideViewController

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
	// Do any additional setup after loading the view.
    self.petWeightDescription.font = [UIFont fontWithName:@"Avenir-Book" size:17];
    
    self.petObesityPreventionImageView.image = [UIImage imageNamed:@"firm"];
    self.petImageView.image = [self appropriateImage:self.guidePage];
    self.petWeightDescription.text = [self appropriateText:self.guidePage];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)appropriateText:(NSUInteger)index
{
    NSString *description;
    
    switch (index) {
        case 1:
            description = NSLocalizedString(@"Ribs, spine and bony protrusions are easily seen at a distance. These pets have lost muscle mass and there is no observable body fat. Emaciated, bony, and starved in appearance.", @"cat1");
            break;
        case 2:
            description = NSLocalizedString(@"Ribs, spine and other bones are easily felt. These pets have an obvious waist when viewed from above and have an abdominal tuck. Thin, lean or skinny in appearance.", @"cat2");
            break;
        case 3:
            description = NSLocalizedString(@"Ribs and spine are easily felt but not necessarily seen. There is a waist when viewed from above and the abdomen is raised and not sagging when viewed from the side. Normal, ideal and often muscular in appearance.", @"cat3");
            break;
        case 4:
            description = NSLocalizedString(@"Ribs and spine are hard to feel or count underneath fat deposits. Waist is distended or often pear-shaped when viewed from above. The abdomen sags when seen from the side. There are typically fat deposits on the hips, base of tail and chest. Overweight, heavy, husky or stout.", @"cat4");
            break;
        case 5:
            description = NSLocalizedString(@"Large fat deposits over the chest, back, tail base and hindquarters. The abdomen sags prominently and there is no waist when viewed from above. The chest and abdomen often appear distended or swollen. Obese.", @"cat5");
            break;
            
        default:
            break;
    }
    
    return description;
}

-(UIImage *)appropriateImage:(NSUInteger)index
{
    NSString *fileName = [NSString stringWithFormat:@"%@%d", self.kind?@"dog":@"cat", index];
    
    return [UIImage imageNamed:fileName];
}


@end
