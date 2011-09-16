//
//  Picsicle2ViewController.m
//  Picsicle2
//
//  Created by Frank Denbow on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Picsicle2ViewController.h"

@implementation Picsicle2ViewController
@synthesize imageView;

-(void)takePic {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];
        picker.allowsEditing= NO;
        [self presentModalViewController:picker animated:YES];
        [picker release];
    
    }
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:YES];
    
    if([mediaType isEqualToString:(NSString *) kUTTypeImage]){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        imageView.image = image;
        
      /*  UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:fineshedSavingWithError:contextInfo:), nil);
        */
        
    }
}

-(void)image:(UIImage *)
finishedSavingWithError:(NSError *) error
 contextInfo:(void *) contextInfo {
    if(error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Failed" message:@"Failed to save image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil ];
        
        [alert show];
        [alert release];
        //do something
    }
    
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
