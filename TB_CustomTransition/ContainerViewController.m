//
//  ContainerViewController.m
//  TB_CustomTransition
//
//  Created by Yari Dareglia on 7/28/13.
//  Copyright (c) 2013 Bitwaker. All rights reserved.
//

#import "ContainerViewController.h"
#import "StepTWOViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ContainerViewController ()
<
UIGestureRecognizerDelegate,
UITableViewDataSource,
UITableViewDelegate
>

@property (assign, nonatomic) CGPoint beginPoint;
@property (assign, nonatomic) CGPoint endPoint;
@property (weak, nonatomic) IBOutlet UILabel *lblPercent;

@property (strong, nonatomic) IBOutlet JDFlipImageView *currentView;
@property (strong, nonatomic) IBOutlet JDFlipImageView *nextView;

@property (strong, nonatomic) UIViewController *nextViewController;
@property (weak, nonatomic) IBOutlet UITableView *menu;

@property (strong, nonatomic) UIView *blackView;

@property (assign, nonatomic) CGFloat percent;
@property (assign, nonatomic) CATransform3D endAnimation;

@end

@implementation ContainerViewController

- (id)initWithViewController:(UIViewController*)viewController{
    
    if(self = [super init]){
        self.currentViewController = viewController;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.percent = 0;

    [self addChildViewController: self.currentViewController ];
    [self.detailView addSubview: self.currentViewController.view];
    [self.currentViewController didMoveToParentViewController:self];
}

//This function performs tha exchange between the CURRENT and the NEXT view
- (void)presentViewController:(UIViewController *)viewController{

    self.nextViewController = viewController;

    //4. Create a screenshot of the CURRENT view and setup its layer
    JDFlipImageView *currentView = (JDFlipImageView *)[self takeScreenshot:self.view.layer];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taptaptap:)];
    tap.numberOfTapsRequired = 1;
    [currentView addGestureRecognizer:tap];
    currentView.userInteractionEnabled = YES;

    //4b. Build a view with black bg and attach here the just taken screenshot
    [self.view addSubview:currentView];

    CGRect oldFrame = [currentView.layer frame];
    currentView.layer.anchorPoint = CGPointMake(0.5,0.5);
    currentView.layer.frame = oldFrame;

    self.currentView = currentView;
    
    //5. Hide the CURRENT view (we've taken the screenshot)
    [self.currentViewController.view setHidden:YES];

    //6. Add the new view to the detail view
    [self.detailView addSubview:viewController.view];

    CGFloat percent = 0.8;

#pragma mark - Far away
    [UIView animateWithDuration:.6
     
    animations:^{
        CATransform3D t = CATransform3DIdentity;
        t.m34 = 1.0/ -250;
        t = CATransform3DRotate(t, radianFromDegree(-35.0f), 0.0f, 1.0f, 0.0f);
        t = CATransform3DTranslate(t, viewController.view.frame.size.width * 0.7f * percent, 0.0f, -250.0 * percent);
        currentView.layer.transform = t;
        currentView.layer.opacity = 1;
        self.menu.alpha = 1;
        self.menu.transform = CGAffineTransformMakeTranslation(20, 0);
        self.endAnimation = t;
    }
    completion:^(BOOL finished) {
    }];
}

- (IBAction)taptaptap:(UITapGestureRecognizer *)recognizer
{
    self.percent += 0.25;
    if (self.percent > 1.0f) {
        self.percent = 1.0f;
    }

    JDFlipImageView *imageView = (JDFlipImageView *)recognizer.view;

    imageView.layer.shouldRasterize = YES;
    [[imageView superview] bringSubviewToFront:imageView];

    [UIView animateWithDuration:.6

                     animations:^{
                         CATransform3D t = self.endAnimation;
                         t = CATransform3DRotate(t, radianFromDegree(35.0f * self.percent), 0.0f, 1.0f, 0.0f);
                         t = CATransform3DTranslate(t, -300 * self.percent, 0.0f, 100);
                         imageView.layer.transform = t;
                         imageView.layer.opacity = 1;

                         self.menu.alpha = 1 * (1 - self.percent);
                         self.menu.transform = CGAffineTransformMakeTranslation(-20 * self.percent, 0);
                     }
                     completion:^(BOOL finished) {
//                         [imageView removeFromSuperview];
//                         [self.currentViewController.view setHidden:NO];
                     }];
    if (self.percent >= 1.0) {
        self.percent = 0.0f;
        [imageView removeFromSuperview];
        [self.currentViewController.view setHidden:NO];
        return;
    }
}

//Create a view with a black background
- (UIView*)blackView
{
    UIView *bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    bgView.backgroundColor = [UIColor clearColor];

    CGRect frame = self.view.bounds;
    frame.size.width = frame.size.width - 30;

    UITableView *table = [[UITableView alloc] initWithFrame:frame];

    [bgView addSubview:table];

    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.dataSource = self;
    table.delegate = self;
    table.backgroundColor = [UIColor clearColor];
    table.showsVerticalScrollIndicator = NO;

    self.menu = table;

    return bgView;
}

- (UITableView *)getMenuView
{
    for (UITableView *view in self.blackView.subviews) {
        if ([view isKindOfClass:[UITableView class]]) {
            return view;
        }
    }

    return nil;
}


//Create a UIImageView from the given layer
- (JDFlipImageView *)takeScreenshot:(CALayer*)layer{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, [[UIScreen mainScreen] scale]);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    JDFlipImageView *screnshot = [[JDFlipImageView alloc] initWithImage:image];
    
    return screnshot;
}

#pragma mark - Convert Degrees to Radian
double radianFromDegree(float degrees) {
    return (degrees / 180) * M_PI;
}

#pragma mark - Tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"Menu number %d", indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];

    if (indexPath.row == 3) {
        cell.textLabel.text = @"";
    }

    cell.textLabel.textColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
