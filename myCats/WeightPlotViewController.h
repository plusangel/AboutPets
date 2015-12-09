//
//  WeightPlotViewController.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 17/2/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

@class Pet;

@interface WeightPlotViewController : UIViewController

@property (nonatomic, strong) Pet *pet;
@property (nonatomic, assign) NSInteger weightUnit;
@property (nonatomic, assign) BOOL helpStatus;

@end
