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
UIGestureRecognizerDelegate
>

@property (assign, nonatomic) CGPoint beginPoint;
@property (assign, nonatomic) CGPoint endPoint;
@property (weak, nonatomic) IBOutlet UILabel *lblPercent;

@property (strong, nonatomic) IBOutlet JDFlipImageView *currentView;
@property (strong, nonatomic) IBOutlet JDFlipImageView *nextView;

@property (strong, nonatomic) UIViewController *nextViewController;

@property (weak, nonatomic) IBOutlet UIImageView *imageExample;

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
    [self addChildViewController: self.currentViewController ];
    [self.detailView addSubview: self.currentViewController.view];
    [self.currentViewController didMoveToParentViewController:self];

//    [self presentViewController:[[StepTWOViewController alloc] init]];

    UIPanGestureRecognizer *panGuesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGuesture:)];
    panGuesture.delegate = self;
    [self.detailView addGestureRecognizer:panGuesture];
}

//This function performs tha exchange between the CURRENT and the NEXT view
- (void)presentViewController:(UIViewController *)viewController{
    
    //A. Container hierarchy management ------------------------------
    
    //1. The current controller is going to be removed
    [self.currentViewController willMoveToParentViewController:nil];

    self.nextViewController = viewController;
    //2. The new controller is a new child of the container
    [self addChildViewController:self.nextViewController];
    
    //3. Setup the new controller's frame depending on the animation you want to obtain
    self.nextViewController.view.frame = CGRectMake(0, 0, self.detailView.frame.size.width, self.detailView.frame.size.height);
    
    //3b. Tell the controller that it's going to be showed 
    [self.nextViewController beginAppearanceTransition:YES animated:YES];
    
    
    
    //B. Generate images and setting up views (Screenshots) ------------------------
    
    //4. Create a screenshot of the CURRENT view and setup its layer
    JDFlipImageView *currentView = (JDFlipImageView *)[self takeScreenshot:self.view.layer];
    //4b. Build a view with black bg and attach here the just taken screenshot 
    UIView *blackView = [self blackView];
    [blackView addSubview:currentView];
    
    CGRect oldFrame = [currentView.layer frame];
    currentView.layer.anchorPoint = CGPointMake(0,0.5);
    currentView.layer.frame = oldFrame;

    self.currentView = currentView;
    
    //5. Hide the CURRENT view (we've taken the screenshot)
    [self.currentViewController.view setHidden:YES];

    //6. Add the new view to the detail view
    [self.detailView addSubview:viewController.view];

    //7. Create a screenshot of the NEXT view and setup its layer
    JDFlipImageView *nextView = (JDFlipImageView *)[self takeScreenshot:self.view.layer];
    oldFrame = [nextView.layer frame];
    nextView.layer.anchorPoint = CGPointMake(0,0.5);
    nextView.layer.frame = oldFrame;
    nextView.frame = CGRectMake(-self.view.frame.size.width, 0, nextView.frame.size.width, nextView.frame.size.height);
    //7.b Attach the screen shot to the black background view
    [blackView addSubview:nextView];
    [self.view addSubview:blackView];

    self.nextView = nextView;

#pragma mark - Flip the table
//    [currentView setImageAnimated:nextView.image duration:1.0f completion:^(BOOL finished) {
//        //Tell the controller that it's going to be removed
//        [self.currentViewController beginAppearanceTransition:NO animated:YES];
//        
//        //Remove the old Detail Controller view from superview
//        [self.currentViewController.view removeFromSuperview];
//     
//        //Remove the old Detail controller from the hierarchy
//        [self.currentViewController removeFromParentViewController];
//     
//        //Set the new view controller as current
//        self.currentViewController = viewController;
//        [self.currentViewController didMoveToParentViewController:self];
//     
//        //The Black backogrund view is no more needed
//        [blackView removeFromSuperview];
//    }];

#pragma mark - Far away
    //C. THE ANIMATION!!!! ------------------------------------------
    
    //8. Setup the NEXT view layer
    CATransform3D tp = CATransform3DIdentity;
    tp.m34 = 1.0/ -500;
    tp = CATransform3DTranslate(tp, -300.0f, -10.0f, 300.0f);
    tp = CATransform3DRotate(tp, radianFromDegree(20), 0.0f,1.0f, 0.8f);
    nextView.layer.transform = tp;
    nextView.layer.opacity = 0.0f;
    
    //9. Finally, perform the animation from PREVIOUS to NEXT view
    [UIView animateWithDuration:1.0
     
    //9b. Animate the views to create a transition effect
    animations:^{
        
        //9c. Create transition for the CURRENT view. 
        CATransform3D t = CATransform3DIdentity;
        t.m34 = 1.0/ -500;
        t = CATransform3DRotate(t, radianFromDegree(5.0f), 0.0f * 0.75,0.0f * 0.75, 1.0f * 0.75);
        t = CATransform3DTranslate(t, viewController.view.frame.size.width * 2 * 0.75, 0.0f * 0.75, -400.0 * 0.75);
        t = CATransform3DRotate(t, radianFromDegree(-45), 0.0f * 0.75,1.0f * 0.75, 0.0f * 0.75);
        t = CATransform3DRotate(t, radianFromDegree(50), 1.0f * 0.75,0.0f * 0.75, 0.0f * 0.75);
        currentView.layer.transform = t;
        currentView.layer.opacity = 1 - 1 * 0.75;
        
        //9d. Create transition for the NEXT view. 
//        CATransform3D t2 = CATransform3DIdentity;
//        t2.m34 = 1.0/ -500;
//        t2 = CATransform3DTranslate(t2, viewController.view.frame.size.width, 0.0f, 0.0);
//        nextView.layer.transform = t2;
//        nextView.layer.opacity = 1.0;

    }

     
    //D. Container hierarchy management ------------------------------
    //10. At the end of the animations we remove the previous view and update the Controller hierarchy.
    completion:^(BOOL finished) {
        
        //Tell the controller that it's going to be removed
//        [self.currentViewController beginAppearanceTransition:NO animated:YES];
//        
//        //Remove the old Detail Controller view from superview
//        [self.currentViewController.view removeFromSuperview];
//     
//        //Remove the old Detail controller from the hierarchy
//        [self.currentViewController removeFromParentViewController];
//     
//        //Set the new view controller as current
//        self.currentViewController = viewController;
//        [self.currentViewController didMoveToParentViewController:self];
//     
//        //The Black backogrund view is no more needed
//        [blackView removeFromSuperview];

    }];
}

- (void)animationViewControllerWithPercent:(CGFloat)percent
{
    if (percent > 100 || percent < 0) {
        return;
    }

    percent = percent / 100;

    //8. Setup the NEXT view layer
    CATransform3D tp = CATransform3DIdentity;
    tp.m34 = 1.0/ -500;
    tp = CATransform3DTranslate(tp, -300.0f * percent, -10.0f * percent, 300.0f * percent);
    tp = CATransform3DRotate(tp, radianFromDegree(20), 0.0f * percent,1.0f * percent, 0.8f * percent);

    //9. Finally, perform the animation from PREVIOUS to NEXT view
    [UIView animateWithDuration:0
     
    //9b. Animate the views to create a transition effect
    animations:^{
        
        //9c. Create transition for the CURRENT view. 
        CATransform3D t = CATransform3DIdentity;
        t.m34 = 1.0/ -500;
        t = CATransform3DRotate(t, radianFromDegree(5.0f), 0.0f * percent,0.0f * percent, 1.0f * percent);
        t = CATransform3DTranslate(t, self.nextViewController.view.frame.size.width * 2 * percent * percent, 0.0f * percent, -400.0 * percent);
        t = CATransform3DRotate(t, radianFromDegree(-45), 0.0f * percent,1.0f * percent, 0.0f * percent);
        t = CATransform3DRotate(t, radianFromDegree(50), 1.0f * percent,0.0f * percent, 0.0f * percent);
        self.imageExample.layer.transform = t;
        self.imageExample.layer.opacity = 1 - percent;
    }];

}

//Create a view with a black background
- (UIView*)blackView{
    
    UIView *bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    bgView.backgroundColor = [UIColor blackColor];
    return bgView;
}


//Create a UIImageView from the given layer
- (JDFlipImageView *)takeScreenshot:(CALayer*)layer{
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, [[UIScreen mainScreen] scale]);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    JDFlipImageView *screnshot = [[JDFlipImageView alloc] initWithImage:image];
    
    return screnshot;
}


#pragma mark - UIGuesture delegate
- (IBAction)onPanGuesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.beginPoint = [recognizer translationInView:self.detailView];
    }

    if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.endPoint = [recognizer translationInView:self.detailView];
        CGFloat percent = abs(self.beginPoint.y - self.endPoint.y);
        self.lblPercent.text = [@(percent) stringValue];

        [self animationViewControllerWithPercent:percent];
    }

    if (recognizer.state == UIGestureRecognizerStateEnded) {

        self.endPoint = [recognizer translationInView:self.detailView];

        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        NSLog(@"magnitude: %f, slideMult: %f, velocity: %f", magnitude, slideMult, velocity.y);

        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor),
                                         recognizer.view.center.y + (velocity.y * slideFactor));
        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.view.bounds.size.width);
        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.view.bounds.size.height);

        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            recognizer.view.center = finalPoint;
        } completion:nil];
        
    }
}


#pragma mark - Convert Degrees to Radian
double radianFromDegree(float degrees) {
    return (degrees / 180) * M_PI;
}

@end
