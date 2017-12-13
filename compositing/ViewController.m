#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController
- (void)viewDidLoad {
  [super viewDidLoad];
  UIView* view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 50, 50)];
  view.backgroundColor = [UIColor redColor];
  [self.view addSubview:view];
}
@end
