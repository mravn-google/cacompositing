#import "Layer.h"


@interface DrawingCALayer ()
@property(readonly, nonatomic)NSMutableArray* drawings;
@end

@implementation DrawingCALayer
-(instancetype)init {
  self = [super init];
  _drawings = [NSMutableArray arrayWithCapacity:1];
  return self;
}
-(void)append:(Drawing)drawing {
  [_drawings addObject:drawing];
}
-(void)drawInContext:(CGContextRef)ctx {
  UIGraphicsPushContext(ctx);
  for (Drawing drawing in _drawings) {
    drawing(ctx);
  }
  UIGraphicsPopContext();
}
@end


@interface PaintContext ()
@property(readonly, nonatomic)NSMutableArray* stack;
@end

@implementation PaintContext
-(instancetype)initWithRoot:(CALayer*)root {
  self = [super init];
  DrawingCALayer* drawingLayer = [[DrawingCALayer alloc] init];
  drawingLayer.frame = root.bounds;
  [root addSublayer:drawingLayer];
  [_stack addObject:drawingLayer];
  return self;
}
-(void)pop {
  [_stack removeLastObject];
}
-(void)push {
  DrawingCALayer* layer = [[DrawingCALayer alloc] init];
  [[_stack lastObject] addSublayer:layer];
  [_stack addObject:layer];
}
-(DrawingCALayer*)current {
  return [_stack lastObject];
}
@end

@interface CompositeLayer ()
@property(readonly, nonatomic)NSMutableArray* children;
@end

@implementation CompositeLayer
-(instancetype)init {
  self = [super init];
  _children = [NSMutableArray arrayWithCapacity:1];
  return self;
}
-(void)paintInContext:(PaintContext *)context {
  [self paintChildrenInContext:context];
}
-(void)paintChildrenInContext:(PaintContext*)context {
  for (NSObject<Layer>* layer in _children) {
    [layer paintInContext:context];
  }
}
@end

@implementation ClipLayer
-(void)paintInContext:(PaintContext *)context {
  [context.current append:^(CGContextRef ctx) {
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, _clip);
    [self paintChildrenInContext:context];
    CGContextRestoreGState(ctx);
  }];
}
@end

@implementation TransformLayer
@end
