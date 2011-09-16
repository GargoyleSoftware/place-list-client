//
//  Picsicle2ViewController.h
//  Picsicle2
//
//  Created by Frank Denbow on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface Picsicle2ViewController : UIViewController 
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImageView *imageView;
}
@property (nonatomic,retain) IBOutlet UIImageView *imageView;
-(IBAction)takePic;

@end
