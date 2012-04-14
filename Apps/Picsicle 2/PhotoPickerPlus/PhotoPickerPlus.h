//
//  PhotoPickerPlus.h
//  ChuteSDKDevProject
//
//  Created by Brandon Coston on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
//  BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <UIKit/UIKit.h>
#import "GetChute.h"

enum {
    PhotoPickerPlusSourceTypeAll,
    PhotoPickerPlusSourceTypeLibrary,
    PhotoPickerPlusSourceTypeCamera,
    PhotoPickerPlusSourceTypeNewestPhoto
};
typedef NSUInteger PhotoPickerPlusSourceType;

@protocol PhotoPickerPlusDelegate;

@interface PhotoPickerPlus : GCUIBaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIWebViewDelegate>

@property (nonatomic, assign) NSObject <PhotoPickerPlusDelegate> *delegate;

@property (nonatomic) int accountIndex;

@property (nonatomic, readonly) IBOutlet UIView *sourceView;
@property (nonatomic, readonly) IBOutlet UIView *accountView;
@property (nonatomic, readonly) IBOutlet UIView *albumView;
@property (nonatomic, readonly) IBOutlet UIView *photoView;

@property (nonatomic, retain) NSArray *photoAlbums;
@property (nonatomic, retain) NSArray *accounts;
@property (nonatomic, retain) NSArray *albums;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) NSMutableSet *selectedAssets;

@property (nonatomic, readonly) IBOutlet UITableView *accountsTable;
@property (nonatomic, readonly) IBOutlet UITableView *albumsTable;
@property (nonatomic, readonly) IBOutlet UITableView *photosTable;

@property (nonatomic, readonly) IBOutlet UINavigationItem *albumsBarTitle;
@property (nonatomic, readonly) IBOutlet UINavigationItem *photosBarTitle;

@property (nonatomic, readonly) IBOutlet UIView *photoCountView;
@property (nonatomic, readonly) IBOutlet UILabel *photoCountLabel;

@property (nonatomic, readonly) IBOutlet UIView *AddServiceView;
@property (nonatomic, readonly) IBOutlet UIWebView *AddServiceWebView;

//set to the source of the image selected
@property (nonatomic) PhotoPickerPlusSourceType sourceType;


@property (nonatomic) BOOL appeared;
@property (nonatomic) BOOL multipleImageSelectionEnabled;


-(UIView*)tableView:(UITableView *)tableView viewForIndexPath:(NSIndexPath*)indexPath;

@end

@protocol PhotoPickerPlusDelegate <NSObject>

-(void)PhotoPickerPlusController:(PhotoPickerPlus *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
-(void)PhotoPickerPlusControllerDidCancel:(PhotoPickerPlus *)picker;
-(void)PhotoPickerPlusController:(PhotoPickerPlus *)picker didFinishPickingArrayOfMediaWithInfo: (NSArray*)info;

@end

