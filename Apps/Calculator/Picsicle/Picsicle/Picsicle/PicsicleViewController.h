//
//  PicsicleViewController.h
//  Picsicle
//
//  Created by Frank Denbow on 9/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PicsicleViewController : UIViewController
            <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    
    UIImageView *imageView;
    BOOL newMedia;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;

- (IBAction)useCamera;
- (IBAction)useCameraRoll;

@end
