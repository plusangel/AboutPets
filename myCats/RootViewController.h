//
//  rootViewController.h
//  myPets
//
//  Created by Angelos Plastropoulos on 7/3/14.
//  Copyright (c) 2014 plusangel@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"

@interface RootViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (assign, nonatomic) BOOL kind;

@end
