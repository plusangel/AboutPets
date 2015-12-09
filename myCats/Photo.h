//
//  Photo.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 6/1/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pet;

@interface Photo : NSManagedObject

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) Pet *pet;

@end
