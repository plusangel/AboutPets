//
//  TherapyViewController.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 26/3/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

@class Pet;

@interface TherapyListViewController : UIViewController

@property (nonatomic, strong) Pet *pet;
@property (nonatomic, assign) NSInteger currencyUnit;
@property (nonatomic, assign) BOOL helpStatus;

@end
