#import <UIKit/UIKit.h>

typedef void(^Drawing)(CGContextRef);

@interface DrawingCALayer : CALayer
-(void)append:(Drawing)drawing;
@end

@interface PaintContext : NSObject
-(instancetype)initWithRoot:(CALayer*)root;
-(void)pushWithFrame:(CGRect)frame;
-(void)pop;
-(DrawingCALayer*)current;
@end

@protocol Layer
-(void)paintInContext:(PaintContext*)context;
-(void)preroll;
// Only valid after preroll.
-(bool)needsSystemComposite;
// Only valid after preroll.
-(CGRect)frame;
@end

@interface CompositeLayer : NSObject<Layer>
@property(nonatomic)NSMutableArray* childLayers;
-(id)init;
-(void)paintChildrenInContext:(PaintContext*)context;
@end

@interface ClipLayer : CompositeLayer
@property(nonatomic, readonly) CGRect clip;
-(id)initWithClip:(CGRect)clip;
@end

@interface TransformLayer : CompositeLayer
@property(nonatomic, readonly) CGAffineTransform transform;
@end

@interface ExternalLayer : NSObject<Layer>
-(id)initWithLayer:(CALayer*)layer offset:(CGPoint)offset;
@end

@interface DrawingLayer : NSObject<Layer>
@property(nonatomic, readonly) Drawing drawing;
-(id)initWithDrawing:(Drawing)drawing frame:(CGRect) frame;
@end
