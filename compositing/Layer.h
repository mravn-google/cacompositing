#import <UIKit/UIKit.h>

typedef void(^Drawing)(CGContextRef);

@interface DrawingCALayer : CALayer
-(void)append:(Drawing)drawing;
@end

@interface PaintContext : NSObject
-(instancetype)initWithRoot:(CALayer*)root;
-(void)push;
-(void)pop;
-(DrawingCALayer*)current;
@end

@protocol Layer
-(void)paintInContext:(PaintContext*)context;
@end


@interface CompositeLayer : NSObject<Layer>
-(void)paintChildrenInContext:(PaintContext*)context;
@end

@interface ClipLayer : CompositeLayer
@property(nonatomic, readonly) CGRect clip;
@end

@interface TransformLayer : CompositeLayer
@property(nonatomic, readonly) CGAffineTransform transform;
@end

@interface DrawingLayer : NSObject<Layer>
@property(nonatomic, readonly) Drawing drawing;
@end
