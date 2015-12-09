//
//  TUTSimpleScatterPlot.h
//  Core Plot Introduction
//
//  Created by Agathangelos Plastropoulos on 25/1/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@class SimpleScatterPlot;

@protocol SimpleScatterPlotDelegate <NSObject>
- (void)simpleScatterPlotController:(SimpleScatterPlot *)controller didHide:(BOOL)value;
@end


@interface SimpleScatterPlot : NSObject <CPTScatterPlotDataSource,CPTPlotSpaceDelegate> {
    CPTGraphHostingView *_hostingView;
    CPTXYGraph *_graph;
    NSMutableArray *_graphData;
}

@property (nonatomic, retain) CPTGraphHostingView *hostingView;
@property (nonatomic, retain) CPTXYGraph *graph;
@property (nonatomic, retain) NSMutableArray *graphData;
@property (nonatomic, copy) NSString *petsName;
@property (nonatomic, assign) BOOL onScreen;
@property (nonatomic, weak) UITabBar *myTabBar;
@property (nonatomic, weak) UINavigationBar *myNavigationBar;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) id <SimpleScatterPlotDelegate> delegate;

// Method to create this object and attach it to it's hosting view.
- (id)initWithHostingView:(CPTGraphHostingView *)hostingView andData:(NSMutableArray *)data inView:(UIView *)myView;

//- (void)initialisePlotInView:(UIView *)view;
- (void)clearPlot;

- (void)sendTapMessage;

@end
