#import <Foundation/Foundation.h>
#import "Layer.h"

@interface LayerTree : NSObject
@property (readonly, nonatomic) NSObject<Layer>* root;
-(id)initWithRoot:(NSObject<Layer> *)layer;
-(void)paintOnLayer:(CALayer*)rootCALayer;
@end
