#import "ViewController.h"
#include "LayerTree.h"
#include "Layer.h"

@interface ViewController ()
@end

@implementation ViewController
- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
  [super viewDidLoad];
  UIView* view = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 300, 500)];
  view.backgroundColor = [UIColor greenColor];
  [self.view addSubview:view];
    DrawingLayer *drawing1 = [[DrawingLayer alloc] initWithDrawing:^(CGContextRef context) {
        UIGraphicsPushContext(context);
        [@"hej" drawAtPoint:CGPointMake(10, 10) withAttributes:nil];
        UIGraphicsPopContext();
    } frame:CGRectMake(5, 5, 50, 50)] ;
    DrawingLayer *drawing2 = [[DrawingLayer alloc] initWithDrawing:^(CGContextRef context) {
        [@"farvel" drawAtPoint:CGPointMake(10, 10) withAttributes:nil];
        NSLog(@"Drawing 2");
    } frame:CGRectMake(30, 30, 70, 70)];
  
  ClipLayer *root = [[ClipLayer alloc] initWithClip: CGRectMake(5, 5, 90, 90)];
  [root.childLayers addObject:drawing1];
    CATextLayer *externalCALayer = [CATextLayer layer];
    externalCALayer.string = @"EXTERNAL";
    externalCALayer.bounds = CGRectMake(0.0f, 0.0f, 100.0f, 100.0f);
    externalCALayer.backgroundColor = [UIColor purpleColor].CGColor;
    externalCALayer.wrapped = false;
  [root.childLayers addObject:[[ExternalLayer alloc]initWithLayer: externalCALayer offset:CGPointMake(20, 20)]];
  [root.childLayers addObject:drawing2];
  LayerTree *layerTree = [[LayerTree alloc] initWithRoot: root];

  [layerTree paintOnLayer:view.layer];
}
@end
