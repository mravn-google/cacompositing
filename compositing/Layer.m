#import "Layer.h"


@interface DrawingCALayer ()
-(id)initWithFrame:(CGRect)frame;
@property(readonly, nonatomic)NSMutableArray* drawings;
@end

@implementation DrawingCALayer
-(instancetype)initWithFrame:(CGRect)frame{
  self = [super init];
    self.needsDisplayOnBoundsChange = true;
    [self setNeedsDisplay];
    self.frame = frame;
    NSLog(@"Did it");
  _drawings = [NSMutableArray arrayWithCapacity:1];
  return self;
}
-(void)append:(Drawing)drawing {
  [_drawings addObject:drawing];
}
-(void)drawInContext:(CGContextRef)ctx {
    NSLog(@"Drawing a CADrawinglayer %@", _drawings);
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
  DrawingCALayer* drawingLayer = [[DrawingCALayer alloc] initWithFrame:root.frame];
  drawingLayer.frame = root.bounds;
  [root addSublayer:drawingLayer];
  _stack = [[NSMutableArray alloc] init];
  [_stack addObject:drawingLayer];
  return self;
}

-(void)pop {
  [_stack removeLastObject];
}

-(void)pushWithFrame:(CGRect)frame {
  DrawingCALayer* layer = [[DrawingCALayer alloc] initWithFrame: frame];
  [[_stack lastObject] addSublayer:layer];
  [_stack addObject:layer];
}

-(DrawingCALayer*)current {
  return [_stack lastObject];
}
@end

@implementation CompositeLayer
{
    bool needsSystemComposite_;
    CGRect frame_;
}
-(instancetype)init{
  self = [super init];
  _childLayers = [NSMutableArray arrayWithCapacity:1];
  return self;
}

-(bool)needsSystemComposite {
    return needsSystemComposite_;
}

-(void)preroll{
    needsSystemComposite_ = false;
    bool first = false;
    for (NSObject<Layer>* layer in _childLayers) {
        [layer preroll];
        if([layer needsSystemComposite]) {
            needsSystemComposite_ = true;
        }
        CGRect childFrame = [layer frame];
        CGRect childOffsetFrame = CGRectOffset(childFrame, frame_.origin.x, frame_.origin.y);
        frame_ = first ? childOffsetFrame : CGRectUnion(frame_, childOffsetFrame);
        first = false;
    }
}

-(void)paintInContext:(PaintContext *)context {
    NSLog(@"Painting composite layer %@", _childLayers);
  [self paintChildrenInContext:context];
}

- (CGRect)frame {
    return frame_;
}

-(void)paintChildrenInContext:(PaintContext*)context {
    if (self.needsSystemComposite) {
        int pushes = 0;
        for (NSObject<Layer>* child in _childLayers) {
            [child paintInContext:context];
            if ([child needsSystemComposite]) {
                [context pushWithFrame:self.frame];
                pushes++;
            }
        }
        for (int p = 0; p < pushes; p++) {
            [context pop];
        }
    } else {
      for (NSObject<Layer>* layer in _childLayers) {
        [layer paintInContext:context];
      }
    }
}
@end

@implementation ExternalLayer
{
    CALayer *layer_;
    CGPoint offset_;
    CGRect frame_;
    
}
-(id)initWithLayer:(CALayer*)layer offset:(CGPoint)offset {
    self = [super init];
    offset_ = offset;
    layer_ = layer;
    return self;
}

-(void)paintInContext:(PaintContext *)context {
    layer_.frame = self.frame;
    [context.current addSublayer: layer_];
}

- (bool)needsSystemComposite {
    return true;
}

- (void)preroll {
    frame_ = CGRectMake(offset_.x, offset_.y, layer_.bounds.size.width, layer_.bounds.size.height);
}
-(CGRect)frame {
    return frame_;
}
@end

@implementation ClipLayer
-(instancetype)initWithClip:(CGRect)clip{
    self = [super init];
    _clip = clip;
    return self;
}
-(void)paintInContext:(PaintContext *)context {
    if ([self needsSystemComposite]) {
        [context pushWithFrame: _clip];
        context.current.masksToBounds = true;
        [self paintChildrenInContext:context];
        [context pop];
    } else {
  [context.current append:^(CGContextRef ctx) {
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, _clip);
  }];
  [self paintChildrenInContext:context];
  [context.current append:^(CGContextRef ctx) {
    CGContextRestoreGState(ctx);
  }];
    }
}
@end

@implementation TransformLayer
@end

@implementation DrawingLayer
{CGRect frame_;}
-(id)initWithDrawing:(Drawing)drawing frame:(CGRect)frame {
    self = [super init];
    _drawing = drawing;
    frame_ = frame;
    return self;
}
-(void)paintInContext:(PaintContext *)context {
    NSLog(@"Painting drawinglayer current %@", [context current]);
    
    [context.current append: ^(CGContextRef ctx) {
        CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
                CGContextSaveGState(ctx);
        CGContextStrokeRect(ctx, frame_);
        CGContextTranslateCTM(ctx, frame_.origin.x, frame_.origin.y);
    }];
    [context.current append: _drawing];
    [context.current append:^(CGContextRef ctx) {
        CGContextRestoreGState(ctx);
    }];

}
-(void)preroll {}
-(bool)needsSystemComposite { return false; }
-(CGRect)frame {
    return frame_;
}
@end
