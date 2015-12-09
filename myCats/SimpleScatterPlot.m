//
//  TUTSimpleScatterPlot.m
//  Core Plot Introduction
//
//  Created by Agathangelos Plastropoulos on 25/1/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import "SimpleScatterPlot.h"
#import "WeightPoint.h"

@implementation SimpleScatterPlot
{
    NSDate *refDate;
    BOOL _hideStatusBar;
}
@synthesize hostingView = _hostingView;
@synthesize graph = _graph;
@synthesize graphData = _graphData;
@synthesize petsName, dateFormatter, onScreen;
dispatch_queue_t queue4;

// Initialise the scatter plot in the provided hosting view with the provided data.
- (id)initWithHostingView:(CPTGraphHostingView *)hostingView andData:(NSMutableArray *)data inView:(UIView *)myView;
{
    self = [super init];
    
    if ( self != nil ) {
        if (onScreen) {
            self.hostingView = hostingView;
        }
        
        self.graphData = data;
        self.graph = nil;
        
        queue4 = dispatch_queue_create("com.plusangel.queue4",nil);
        
        dispatch_async(queue4, ^{
            NSArray *sortedArray;
            
            sortedArray = [[self.graphData reverseObjectEnumerator] allObjects];
            _graphData = [(NSArray *)sortedArray mutableCopy];
            
            __block NSNumber *maxValue = [NSNumber numberWithFloat:0];
            __block NSNumber *minValue = [NSNumber numberWithFloat:50.0];
            [_graphData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSNumber *newValue = [(WeightPoint *)obj weight];
                if ([newValue isGreaterThan:maxValue]) {
                    maxValue = newValue;
                }
                if ([newValue isLessThan:minValue]) {
                    minValue = newValue;
                }
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self configureHostInView:myView];
                [self configureGraph];
                [self configurePlot];
                [self configureAxisWithMin:minValue andMax:maxValue];
                if (!onScreen) {
                    [self drawChart];
                }
            });
        });
    }
    return self;
}

- (void)configureHostInView:(UIView *)myView
{
    if (onScreen) {
        self.hostingView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:myView.bounds];
        self.hostingView.allowPinchScaling = YES;
        
        if ([(UIView *)self.hostingView superview] == nil) {
            [myView addSubview:(UIView *)self.hostingView];
        }
    } else {
        self.hostingView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:CGRectMake(0.0, 0.0, 420.0, 257.0)];
        self.hostingView.allowPinchScaling = YES;
    }
}

- (void)configureGraph
{
    // Create the graph
    self.graph = [[CPTXYGraph alloc] initWithFrame:self.hostingView.bounds];
    if (onScreen) {
        [self.graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    }
    self.hostingView.hostedGraph = self.graph;
    
    /// Set padding for plot area
    [self.graph.plotAreaFrame setPaddingLeft:30.0f];
    [self.graph.plotAreaFrame setPaddingBottom:30.0f];
    
    // Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
}

- (void)configurePlot
{
    // Get graph and plot space
    CPTGraph *graph = self.hostingView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.graph.defaultPlotSpace;
    plotSpace.delegate = self;
    
    // Create the plot
    CPTScatterPlot *plot = [[CPTScatterPlot alloc] init];
    plot.dataSource = self;
    plot.identifier = @"Date Plot";
    [graph addPlot:plot toPlotSpace:plotSpace];

    // Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObject:plot]];
    
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    
    // Create style
    CPTMutableLineStyle *lineStyle = [plot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 3.0f;
    lineStyle.lineColor = [CPTColor blueColor];
    plot.dataLineStyle = lineStyle;

}

- (void)configureAxisWithMin:(NSNumber *)minValue andMax:(NSNumber *)maxValue
{
    
    // Get the limits from data
    WeightPoint *firstPoint = [self.graphData objectAtIndex:0];
    
    // Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor redColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    if (onScreen) {
        axisLineStyle.lineColor = [CPTColor whiteColor];
    } else {
        axisLineStyle.lineColor = [CPTColor blackColor];
    }
    
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor redColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    
    // Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostingView.hostedGraph.axisSet;
    
    // Configure x-axis
    CPTXYAxis *x = axisSet.xAxis;
    //x.title = @"Day of Month";
    //x.titleTextStyle = axisTitleStyle;
    //x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;

    x.orthogonalCoordinateDecimal = CPTDecimalFromFloat([firstPoint.weight floatValue] + 1.0);
    
    
    CGFloat dateCount = self.graphData.count;
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    
    NSInteger i = 0;
    for (WeightPoint *wp in self.graphData) {
        NSDate *weightDate = [wp date];
        NSString *date = [self.dateFormatter stringFromDate:weightDate];
        
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        
        label.rotation = 1.2;
        
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;    
    x.majorTickLocations = xLocations;

    // 4 - Configure y-axis
    CPTXYAxis *y = axisSet.yAxis;
    //y.title = @"Price";
    //y.titleTextStyle = axisTitleStyle;
    //y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    
    //y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(intervallLenght*oneDay*0.8);
    
    NSInteger majorIncrement = 1;
    NSInteger minorIncrement = 1;
    
    CGFloat yMax = [maxValue floatValue];  // should determine dynamically based on max price
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    
    for (NSInteger j = [minValue intValue]; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;

}

- (void)drawChart
{
    NSString *fileName = [NSString stringWithFormat:@"%@.png", petsName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *graphFileName = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    UIImage *myGraph = _graph.imageOfLayer;
    [UIImagePNGRepresentation(myGraph) writeToFile:graphFileName atomically:YES];
}


- (void)clearPlot
{
    [(UIView *)self.hostingView removeFromSuperview];
}

// Delegate method that returns the number of points on the plot
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.graphData.count;
}

// Delegate method that returns a single X or Y value for a given plot.
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSInteger valueCount = self.graphData.count;

    WeightPoint *weightPoint = [self.graphData objectAtIndex:index];
    
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < valueCount) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
            
        case CPTScatterPlotFieldY:
            return weightPoint.weight;
            break;
    }
    return [NSDecimalNumber zero];
}

#pragma mark - hide and show the bars

- (void)sendTapMessage
{
    _hideStatusBar = NO;
}

- (CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)proposedDisplacementVector
{
    if (!_hideStatusBar){
        [self hideBars];
    }
    return proposedDisplacementVector;
}

- (void)hideBars {
    _hideStatusBar = YES;
    [self.delegate simpleScatterPlotController:self didHide:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
        //[self setNeedsStatusBarAppearanceUpdate];
        self.myNavigationBar.alpha = 0.0f;
        self.myTabBar.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.myNavigationBar.hidden = YES;
        self.myTabBar.hidden = YES;
    }];
    
}

#pragma mark - Assistant Methods

- (NSDateFormatter *)dateFormatter
{
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return dateFormatter;
}

@end
