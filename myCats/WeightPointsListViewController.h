//
//  weightPointsListViewController.h
//  myPets
//
//  Created by angelos plastropoulos on 12/29/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

@class Pet;

@interface WeightPointsListViewController : UIViewController 

@property (nonatomic, strong) Pet *pet;
@property (nonatomic, assign) NSInteger weightUnit;
@property (nonatomic, assign) BOOL helpStatus;

@end

