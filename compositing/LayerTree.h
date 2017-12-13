#import <Foundation/Foundation.h>
#import "Layer.h"

@interface LayerTree : NSObject
@property (readonly, nonatomic) NSObject<Layer>* root;
@end
