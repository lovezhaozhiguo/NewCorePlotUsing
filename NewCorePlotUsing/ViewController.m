//
//  ViewController.m
//  NewCorePlotUsing
//
//  Created by ZZG on 2016/11/29.
//  Copyright © 2016年 htmitech.com. All rights reserved.
//

#import "ViewController.h"

#import "CorePlot-CocoaTouch.h"

@interface ViewController ()<CPTPlotDataSource,CPTAxisDelegate,CPTPlotSpaceDelegate,CPTPlotDelegate,CPTBarPlotDelegate,CPTBarPlotDelegate,CALayerDelegate,CPTAnimationDelegate>

/**
 画布
 */
@property (nonatomic, strong) CPTXYGraph *graph;
/**
 数据源
 */
@property (nonatomic, strong) NSMutableArray *barDataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initGraph];
    
    [self initPlotspace];

    [self initAxisX];
    
    [self initAxisY];
    
    [self initBarChart];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)initGraph {
    //画板
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(10, 64, 355, 520)];
    hostingView.backgroundColor = [UIColor grayColor];
    [hostingView setAllowPinchScaling:YES];//是否可捏合
    [self.view addSubview:hostingView];
    
    //画布
    self.graph = [[CPTXYGraph alloc] init];
    hostingView.hostedGraph = self.graph;
    
    //设置画布主题
    CPTTheme *theme = [CPTTheme themeNamed:kCPTSlateTheme];
    [self.graph applyTheme:theme];
    
    //设置边界：边框距离四边边界距离
    self.graph.paddingLeft = 26.0;
    self.graph.paddingRight = 26.0;
    self.graph.paddingBottom = 26.0;
    self.graph.paddingTop = 26.0;
    //坐标轴距离边框距离
    self.graph.plotAreaFrame.paddingLeft = 40.0;
    self.graph.plotAreaFrame.paddingRight = 6.0;
    self.graph.plotAreaFrame.paddingBottom = 60.0;
    self.graph.plotAreaFrame.paddingTop = 10.0;
    
    //自定义边框
    CPTMutableLineStyle *lineStyle = [[CPTMutableLineStyle alloc] init];
    lineStyle.lineColor = [CPTColor brownColor];
    lineStyle.lineWidth = 2.0;
    self.graph.plotAreaFrame.borderLineStyle = lineStyle;
}

- (void)initPlotspace {
    // 绘图空间 plot space
    CPTXYPlotSpace *plotSpace = ( CPTXYPlotSpace *) [self.graph defaultPlotSpace];
    // 绘图空间大小
    //当前显示范围
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f) lengthDecimal:CPTDecimalFromFloat(220)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f) lengthDecimal:CPTDecimalFromFloat(4.0f)];
    //共多大，滑动区域，不设置为无限大
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f) lengthDecimal:CPTDecimalFromFloat(220.0f)];
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f) lengthDecimal:CPTDecimalFromFloat(8.0f)];
    plotSpace.allowsUserInteraction = YES;//是否可滑动
    
}

- (void)initAxisX {
    CPTXYAxis *x = ((CPTXYAxisSet *)self.graph.axisSet).xAxis;
    
    //x轴的原点位置，其实这里是y坐标的值，也就是说x轴的原点在y轴的1位置
    {
//        x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
        x.orthogonalPosition = [NSNumber numberWithFloat:0.0f];
    }
    
    
    //x 轴小刻度
    {
        x.minorTicksPerInterval = 2;//每个大刻度之间有几个小刻度
        x.minorTickLength = 5;//小刻度的长度
        
        CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
        minorLineStyle.lineWidth = 1.0;
        minorLineStyle.lineColor = [CPTColor brownColor];
        x.minorTickLineStyle = minorLineStyle;//线条样式
    }
    
    //x 轴大刻度
    {
        x.majorIntervalLength =[NSNumber numberWithInteger:1];//大刻度值
        x.majorTickLength = 5;
        
        CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];
        majorLineStyle.lineWidth = 1.0;
        majorLineStyle.lineColor = [CPTColor purpleColor];
        x.majorTickLineStyle = majorLineStyle;//线条样式
    }
    
    //轴线
    {
        CPTMutableLineStyle *xAxisLineStyle = [[CPTMutableLineStyle alloc] init];
        xAxisLineStyle.lineColor = [CPTColor colorWithComponentRed:0/255.0 green:64/255.0 blue:128/255.0 alpha:1.0];
        xAxisLineStyle.lineWidth = 2.0;
        x.axisLineStyle = xAxisLineStyle;
    }
    
    //网格线。  注意：如果自定义了x轴需要重新定义majorGridLine位置
    {
        CPTMutableLineStyle *xGridStyle = [CPTMutableLineStyle lineStyle];
        xGridStyle.lineWidth = 0.5f;
        xGridStyle.lineColor = [CPTColor purpleColor];
        xGridStyle.dashPattern = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:5.0f],
                                  [NSNumber numberWithFloat:5.0f], nil];//破折线
        x.majorGridLineStyle = xGridStyle;
    }
    
    //自定义 x 轴
    {
        NSArray *xDataArray = @[@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期日"];
        x.labelingPolicy = CPTAxisLabelingPolicyNone;//设置为none才能自定义x轴
        
        CPTAxisLabel *axisLabel;
        NSMutableArray *mArr = [[NSMutableArray alloc] init];
        NSMutableArray *locations = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < xDataArray.count; i++) {
            CPTMutableTextStyle *xLabelStyle = [CPTMutableTextStyle textStyle];
            xLabelStyle.fontSize = 12.0;
            xLabelStyle.color = [CPTColor blackColor];
            
            axisLabel = [[CPTAxisLabel alloc] initWithText:xDataArray[i] textStyle:xLabelStyle];
            axisLabel.tickLocation = [NSNumber numberWithInt:i+1];
            axisLabel.offset = x.labelOffset + x.majorTickLength;
            //label倾斜度
            axisLabel.rotation = 45;
            [mArr addObject:axisLabel];
            [locations addObject:[NSNumber numberWithInt:i+1]];
        }
        x.axisLabels = [NSSet setWithArray:mArr];
        //设置 CPTAxisLabelingPolicyNone 后网格线要重新定义majorGridLine位置
        x.majorTickLocations = [NSSet setWithArray:locations];
    }
    
    //箭头
    {
        CPTLineCap *lineCap = [[CPTLineCap alloc] init];
        lineCap.lineCapType = CPTLineCapTypeSweptArrow;
        lineCap.size = CGSizeMake(12.0, 16.0);
        lineCap.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0/255.0 green:64/255.0 blue:128/255.0 alpha:1.0]];
        x.axisLineCapMax = lineCap;
    }
    
    //标题
    {
        x.title = @"时间";
        x.titleLocation = [NSNumber numberWithFloat:7.5f];//位置，与刻度有关
        x.titleOffset = 20;//title 上下移动
    }
    
    // 滑动时固定 x 轴
    {
        x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];
        x.axisConstraints = [CPTConstraints constraintWithRelativeOffset:0.0];//0.0~~1.0  x轴位置由最下端到最上端
    }
}

- (void)initAxisY {
    CPTXYAxis *y = ((CPTXYAxisSet *)self.graph.axisSet).yAxis;
    
    //与 x 轴相同部分
    {
        y.orthogonalPosition = [NSNumber numberWithFloat:0.0f];
        y.majorIntervalLength = [NSNumber numberWithInteger:20];
        y.minorTicksPerInterval = 0;
        
        //网格线
        CPTMutableLineStyle *xGridStyle = [CPTMutableLineStyle lineStyle];
        xGridStyle.lineWidth = 0.5f;
        xGridStyle.lineColor = [CPTColor purpleColor];
        xGridStyle.dashPattern = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:5.0f],
                                  [NSNumber numberWithFloat:5.0f], nil];//破折线
        y.majorGridLineStyle = xGridStyle;
        
        //小刻度
        CPTMutableLineStyle *xMinorTickStyle = [CPTMutableLineStyle lineStyle];
        xMinorTickStyle.lineColor = [CPTColor redColor];
        y.minorTickLineStyle = xMinorTickStyle;
        //大刻度
        CPTMutableLineStyle *xMajorTickStyle = [CPTMutableLineStyle lineStyle];
        xMajorTickStyle.lineColor = [CPTColor clearColor];
        y.majorTickLineStyle = xMajorTickStyle;
    }
    
    //需要排除的不显示数字的主刻度
    {
        NSArray *exclusionRangesY = [NSArray arrayWithObjects:[CPTPlotRange plotRangeWithLocation:[NSNumber numberWithInteger:220] length:[NSNumber numberWithInteger:220]], nil];
        y.labelExclusionRanges = exclusionRangesY;
    }
    
    //坐标轴的数据格式及方向
    {
        y.tickDirection = CPTSignNegative;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        y.labelFormatter = formatter;
    }
    
    // 滑动时固定 y 轴
    {
        y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];
        y.axisConstraints = [CPTConstraints constraintWithRelativeOffset:0.0];//0.0~~1.0  y轴位置由最左端到最右端
    }
}

- (void)initBarChart {
    
    for (int i = 0; i < self.barDataArray.count; i++) {
        CPTBarPlot *barChart = [CPTBarPlot tubularBarPlotWithColor:[CPTColor grayColor] horizontalBars:NO];//yes 时为y轴
        barChart.identifier = [NSString stringWithFormat:@"bar_%d",i];
        barChart.dataSource = self;
        barChart.delegate = self;
        barChart.barWidth = [NSNumber numberWithFloat:0.2f];
        barChart.baseValue = [NSNumber numberWithFloat:1.0f];//从零开始
        barChart.barOffset = @0.0;
        barChart.barCornerRadius = 5.0;//bar的边角弧度
        barChart.barWidthsAreInViewCoordinates = NO;//是否带宽度
        //        barChart.barsAreHorizontal = YES;//横竖
        [self.graph addPlot:barChart];
        
        //bar的边线
        {
            CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
            lineStyle.lineColor = [CPTColor grayColor];
            lineStyle.lineWidth = 1.0;
            barChart.lineStyle = lineStyle;
        }
        
        //填充颜色(渐变是由上到下的)
        {
            CPTColor *beginColor = [CPTColor colorWithComponentRed:206/255.0 green:91/255.0 blue:126/255.0 alpha:1.0];
            CPTColor *endColor = [CPTColor colorWithComponentRed:75/255.0 green:142/255.0 blue:188/255.0 alpha:1.0];
            
            CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:beginColor endingColor:endColor];
            gradient.angle = -90.0;
            CPTFill *fill = [CPTFill fillWithGradient:gradient];
            barChart.fill = fill;
        }
        
        //标题
        {
            CPTMutableTextStyle *textStyle = [[CPTMutableTextStyle alloc] init];
            textStyle. color = [CPTColor redColor];
            textStyle. fontSize = 16.0f ;
            self.graph.title = @"柱状图";
            self.graph.titleTextStyle = textStyle;
            self.graph.titleDisplacement = CGPointMake ( 0.0f , - 20.0f );
            self.graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
        }
    }
    
    //创建图例。图例多的情况需要自定义图例
    {
        CPTLegend *theLegeng = [CPTLegend legendWithGraph:self.graph];
        //图例的列数
        theLegeng.numberOfColumns = 3;
        //填充属性
        theLegeng.fill = [CPTFill fillWithColor:[CPTColor grayColor]];
        //图例外框的线条样式
        theLegeng.borderLineStyle = [CPTLineStyle lineStyle];
        //图例外框的圆角半径
        theLegeng.cornerRadius = 5.0;
        theLegeng.delegate = self;
        theLegeng.columnMargin = 20;
        
        //        self.graph.legend = theLegeng;
        //图例对齐于图框的位置，可以用 CPTRectAnchor 枚举类型，指定图例向图框的4角、4边（中点）对齐
        self.graph.legendAnchor = CPTRectAnchorTopRight;
        // 图例对齐时的偏移距离    -(左、下)     ＋(右、上)
        self.graph.legendDisplacement = CGPointMake(-10,-10);
    }
}


//询问有多少个数据，在 CPTPlotDataSource 中声明的
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    NSUInteger number = 0;
    for (int i = 0; i < self.barDataArray.count; i++) {
        if ([plot.identifier isEqual:[NSString stringWithFormat:@"bar_%d",i]]) {
            number = ((NSArray *)self.barDataArray[i]).count;
        }
    }
    return number;
}

/**
 询问一个个数据值，在 CPTPlotDataSource 中声明的
 
 @param plot      barChart
 @param fieldEnum bar的位置和高
 @param index     <#index description#>
 
 @return bar的位置和高
 */
- (NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSNumber *num = nil;
    
    for (int i = 0; i < self.barDataArray.count; i++) {
        if ([plot.identifier isEqual:[NSString stringWithFormat:@"bar_%d",i]]) {
            switch (fieldEnum) {
                case CPTBarPlotFieldBarLocation:
                    num = [NSNumber numberWithFloat:index+i*0.2+0.8];//X 轴位置
                    break;
                case CPTBarPlotFieldBarTip:
                    num = [NSNumber numberWithInt:[self.barDataArray[i][index] intValue]];//高
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    return num;
}

//柱上方的标题
- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    CPTTextLayer *label;
    NSArray *array = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G"];
    
    for (int i = 0; i < self.barDataArray.count; i++) {
        if ([plot.identifier isEqual:[NSString stringWithFormat:@"bar_%d",i]]) {
            label = [[CPTTextLayer alloc] initWithText:array[i]];
        }
    }
    
    CPTMutableTextStyle *textStyle =[label.textStyle mutableCopy];
    textStyle.color = [CPTColor purpleColor];
    label.textStyle = textStyle;
    
    return label;
}

//点击事件
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx {
    for (int i = 0; i < self.barDataArray.count; i++) {
        if ([plot.identifier isEqual:[NSString stringWithFormat:@"bar_%d",i]]) {
            NSLog(@"index:%d-%ld",i,idx);
        }
    }
}

//设置某个柱子的样式（fill 或line）：指定柱时也可以设置
-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx {
    CPTColor *beginColor = [CPTColor colorWithComponentRed:206/255.0 green:91/255.0 blue:126/255.0 alpha:1.0];
    CPTColor *endColor = [CPTColor colorWithComponentRed:75/255.0 green:142/255.0 blue:188/255.0 alpha:1.0];
    
    CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:beginColor endingColor:[CPTColor grayColor]];
    gradient.angle = -90.0;
    CPTFill *fill = [CPTFill fillWithGradient:gradient];
    barPlot.fill = fill;
    
    return fill;
}

//柱线条样式：指定柱时也可以设置
-(CPTLineStyle *)barLineStyleForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx {
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor grayColor];
    lineStyle.lineWidth = 1.0;
    
    if (idx == 1) {
        return lineStyle;
    }
    return nil;
}

////同下
//-(NSString *)legendTitleForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx
//{
//    return nil;
//}

//返回图例
-(NSAttributedString *)attributedLegendTitleForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx {
    NSAttributedString *title;
    if ([barPlot.identifier isEqual:@"bar_0"]) {
        title = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",@"hah"]];
    }
    
    return title;
}

-(BOOL)legend:(CPTLegend *)legend shouldDrawSwatchAtIndex:(NSUInteger)index forPlot:(CPTPlot *)plot inRect:(CGRect)rect inContext:(CGContextRef)context {
    return YES;
}

#pragma mark ------ 懒加载
- (NSMutableArray *)barDataArray {
    if (!_barDataArray) {
        _barDataArray = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            NSMutableArray *array = [NSMutableArray array];
            for (int i = 0; i < 7; i++) {
                int a = arc4random()%200;
                [array addObject:[NSString stringWithFormat:@"%d",a]];
            }
            [_barDataArray addObject:array];
        }
    }
    return _barDataArray;
}

#pragma mark ------ 动画，研究中。。。。。。（只会改变x、y轴范围）
- (void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event {
    
    CPTPlotRange *newYRange = [CPTPlotRange plotRangeWithLocation:@0 length:@150];
    
    CPTXYPlotSpace *plotSpace = ( CPTXYPlotSpace *) [self.graph defaultPlotSpace];
    
    [CPTAnimation animate:plotSpace property:@"yRange" fromPlotRange:plotSpace.yRange toPlotRange:newYRange duration:.1 animationCurve:CPTAnimationCurveCubicInOut delegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
