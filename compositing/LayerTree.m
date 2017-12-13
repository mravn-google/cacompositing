#import "LayerTree.h"

@implementation LayerTree
-(id)initWithRoot:(NSObject<Layer> *)layer {
    self = [super init];
    _root = layer;
    return self;
}
-(void)paintOnLayer:(CALayer *)rootCALayer {
    [_root preroll];
    NSLog(@"Painting layertree on layer %@", [_root class]);
    [_root paintInContext:[[PaintContext alloc] initWithRoot:rootCALayer]];
}
@end
