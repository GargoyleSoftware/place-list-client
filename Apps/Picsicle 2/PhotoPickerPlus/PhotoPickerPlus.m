//
//  PhotoPickerPlus.m
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

#import "PhotoPickerPlus.h"

#define ADD_SERVICES_ARRAY_NAMES [NSArray arrayWithObjects:@"Facebook", @"Instagram", @"Flickr", @"Picasa", nil]
#define ADD_SERVICES_ARRAY_LINKS [NSArray arrayWithObjects:@"facebook", @"instagram", @"flickr", @"google", nil]
#define messageTime 2


@implementation PhotoPickerPlus
@synthesize delegate;
@synthesize accountIndex;
@synthesize sourceView, accountView, albumView, photoView;
@synthesize photoAlbums, accounts, albums, photos, selectedAssets;
@synthesize accountsTable, albumsTable, photosTable;
@synthesize albumsBarTitle, photosBarTitle;
@synthesize photoCountView, photoCountLabel;
@synthesize appeared, multipleImageSelectionEnabled;
@synthesize AddServiceView, AddServiceWebView;
@synthesize sourceType;

-(void)dealloc{
    [photoAlbums release];
    [accounts release];
    [albums release];
    [photos release];
    [selectedAssets release];
    [super dealloc];
}

-(IBAction)hidePhotoCountView{
    [[self photoCountLabel] setText:@""];
    [[self photoCountView] removeFromSuperview];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePhotoCountView) object:nil];
}

-(void)showPhotoCountViewWithCount:(int)photoCount{
    [[self photoCountLabel] setText:[NSString stringWithFormat:@"Loaded %i photos in this album", photoCount]];
    [self.view addSubview:[self photoCountView]];
    [self performSelector:@selector(hidePhotoCountView) withObject:nil afterDelay:messageTime];
}

- (NSString *) pathForCachedUrl:(NSString *)urlString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    return [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], [[urlString stringByReplacingOccurrencesOfString:@"http://" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
}

-(void)setAccounts:(NSArray *)_accounts{
    if(!_accounts){
        if(accounts){
            [accounts release];
            accounts = NULL;
        }
        return;
    }
    NSMutableArray *temp = [NSMutableArray array];
    for(NSDictionary *dict in _accounts){
        if([[dict objectForKey:@"type"] caseInsensitiveCompare:@"custom"] != NSOrderedSame)
            [temp addObject:dict];
    }
    if(accounts){
        [accounts release];
        accounts = NULL;
    }
    accounts = [temp retain];
}

-(IBAction)cameraSelected:(id)sender{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){ 
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [picker setDelegate:self];
        [self presentViewController:picker animated:YES completion:^(void){
            [picker release];
        }];
    }
    else{
        [self quickAlertWithTitle:@"Camera Not Available" message:@"Please select a different source type" button:@"OK"];
    }
}


-(IBAction)deviceSelected:(id)sender{
    if(![[GCAccount sharedManager] accounts] || [[[GCAccount sharedManager] accounts] count] == 0){
        [self setAccounts:NULL];
        [self.view addSubview:accountView];
        [accountsTable reloadData];
        [self showHUD];
        [[GCAccount sharedManager] loadAccountsInBackgroundWithCompletion:^(void){
            [self setAccounts:[[GCAccount sharedManager] accounts]];
            [accountsTable reloadData];
            [self hideHUD];
        }];
        return;
    }
    [self setAccounts:[[GCAccount sharedManager] accounts]];
    [self.view addSubview:accountView];
    [accountsTable reloadData];
}

-(IBAction)latestSelected:(id)sender{
    [self showHUD];
    [[GCAccount sharedManager] loadAssetsCompletionBlock:^(void){
        if([[GCAccount sharedManager] assetsArray].count > 0){
            GCAsset *object = [[[GCAccount sharedManager] assetsArray] objectAtIndex:0];
            ALAsset *asset = [object alAsset];
            NSMutableDictionary* temp = [NSMutableDictionary dictionary];
            [temp setObject:[[asset defaultRepresentation] UTI] forKey:UIImagePickerControllerMediaType];
            [temp setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage] scale:1 orientation:(UIImageOrientation)[[asset defaultRepresentation] orientation]] forKey:UIImagePickerControllerOriginalImage];
            [temp setObject:[[asset defaultRepresentation] url] forKey:UIImagePickerControllerReferenceURL];
            if([self multipleImageSelectionEnabled]){
                if(delegate && [delegate respondsToSelector:@selector(PhotoPickerPlusController:didFinishPickingArrayOfMediaWithInfo:)])
                    [delegate PhotoPickerPlusController:self didFinishPickingArrayOfMediaWithInfo:[NSArray arrayWithObject:temp]];
            }
            else{
                if(delegate && [delegate respondsToSelector:@selector(PhotoPickerPlusController:didFinishPickingMediaWithInfo:)])
                    [delegate PhotoPickerPlusController:self didFinishPickingMediaWithInfo:temp];
            }
        }
        else{
            if(delegate && [delegate respondsToSelector:@selector(PhotoPickerPlusControllerDidCancel:)])
                [delegate PhotoPickerPlusControllerDidCancel:self];
        }
        [self hideHUD];
    }];
}

-(IBAction)closeSelected:(id)sender{
    [self setAccounts:NULL];
    [self setAlbums:NULL];
    [self setPhotos:NULL];
    [accountsTable reloadData];
    [albumsTable reloadData];
    [photosTable reloadData];
    [self setAccountIndex:-1];
    [photoView removeFromSuperview];
    [albumView removeFromSuperview];
    [accountView removeFromSuperview];
    if(delegate && [delegate respondsToSelector:@selector(PhotoPickerPlusControllerDidCancel:)])
        [delegate PhotoPickerPlusControllerDidCancel:self];
}
-(IBAction)doneSelected:(id)sender{
    NSMutableArray *returnArray = [NSMutableArray array];
    [self showHUD];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        for(id object in [[self selectedAssets] allObjects]){
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            if([object isKindOfClass:[GCAsset class]]){
                ALAsset *asset = [object alAsset];
                NSMutableDictionary* temp = [NSMutableDictionary dictionary];
                [temp setObject:[[asset defaultRepresentation] UTI] forKey:UIImagePickerControllerMediaType];
                [temp setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:1 orientation:(UIImageOrientation)[[asset defaultRepresentation] orientation]] forKey:UIImagePickerControllerOriginalImage];
                [temp setObject:[[asset defaultRepresentation] url] forKey:UIImagePickerControllerReferenceURL];
                [returnArray addObject:temp];
            }
            else{
                NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithDictionary:object];
                if([self accountIndex] >= 0){
                    int count = 0;
                    if([self photoAlbums])
                        count += [[self photoAlbums] count];
                    NSString *type = [ADD_SERVICES_ARRAY_LINKS objectAtIndex:[self accountIndex] - count];
                    NSDictionary *account = NULL;
                    if([self accounts]){
                        for(NSDictionary *dict in [self accounts]){
                            if([[dict objectForKey:@"type"] caseInsensitiveCompare:type] == NSOrderedSame)
                                account = dict;
                        }
                    }
                    if(account){
                        [asset setObject:account forKey:@"source"];
                    }
                }
                NSData *data = NULL;
                if([[NSString stringWithFormat:@"%@",[asset objectForKey:@"url"]] caseInsensitiveCompare:@"<null>"] != NSOrderedSame)
                    data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[asset objectForKey:@"url"]]];
                else{
                    data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[asset objectForKey:@"thumb"]]];
                }
                UIImage *image = [UIImage imageWithData:data];
                NSMutableDictionary* temp = [NSMutableDictionary dictionary];
                [temp setObject:@"public.image" forKey:UIImagePickerControllerMediaType];
                if(image)
                    [temp setObject:image forKey:UIImagePickerControllerOriginalImage];
                if([[NSString stringWithFormat:@"%@",[asset objectForKey:@"url"]] caseInsensitiveCompare:@"<null>"] != NSOrderedSame)
                    [temp setObject:[asset objectForKey:@"url"] forKey:UIImagePickerControllerReferenceURL];
                else{
                    [temp setObject:[asset objectForKey:@"thumb"] forKey:UIImagePickerControllerReferenceURL];
                }
                [temp setObject:asset forKey:UIImagePickerControllerMediaMetadata];
                [returnArray addObject:temp];
            }
            [pool release];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if(delegate && [delegate respondsToSelector:@selector(PhotoPickerPlusController:didFinishPickingArrayOfMediaWithInfo:)])
                [delegate PhotoPickerPlusController:self didFinishPickingArrayOfMediaWithInfo:returnArray];
            [self setAccounts:NULL];
            [self setAlbums:NULL];
            [self setPhotos:NULL];
            [self setSelectedAssets:NULL];
            [accountsTable reloadData];
            [albumsTable reloadData];
            [photosTable reloadData];
            [self setAccountIndex:-1];
            [photoView removeFromSuperview];
            [albumView removeFromSuperview];
            [accountView removeFromSuperview];
            [self hideHUD];
        });
    });
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if([self multipleImageSelectionEnabled]){
        [self dismissViewControllerAnimated:YES completion:^(void){
            if(delegate && [delegate respondsToSelector:@selector(PhotoPickerPlusController:didFinishPickingArrayOfMediaWithInfo:)])
                [delegate PhotoPickerPlusController:self didFinishPickingArrayOfMediaWithInfo:[NSArray arrayWithObject:info]];
            else if(delegate && [delegate respondsToSelector:@selector(PhotoPickerPlusController:didFinishPickingMediaWithInfo:)])
                [delegate PhotoPickerPlusController:self didFinishPickingMediaWithInfo:info];
        }];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:^(void){
            if(delegate && [delegate respondsToSelector:@selector(PhotoPickerPlusController:didFinishPickingMediaWithInfo:)])
                [delegate PhotoPickerPlusController:self didFinishPickingMediaWithInfo:info];
        }];
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:^(void){
        if(delegate && [delegate respondsToSelector:@selector(PhotoPickerPlusControllerDidCancel:)])
            [delegate PhotoPickerPlusController:self didFinishPickingArrayOfMediaWithInfo:[[self selectedAssets] allObjects]];
        
    }];
}

-(void)accountLoginStatusChangedWithNotification:(NSNotification*)notification{
    if([[GCAccount sharedManager] accountStatus] == GCAccountLoggedIn){
        [self showHUD];
        [[GCAccount sharedManager] loadAccountsInBackgroundWithCompletion:^(void){
            [self setAccounts:[[GCAccount sharedManager] accounts]];
            [[self accountsTable] reloadData];
            if([self accountIndex] >= 0){
                int count = 0;
                if([self photoAlbums])
                    count += [[self photoAlbums] count];
                NSString *type = [ADD_SERVICES_ARRAY_LINKS objectAtIndex:[self accountIndex] - count];
                NSDictionary *account = NULL;
                if([self accounts]){
                    for(NSDictionary *dict in [self accounts]){
                        if([[dict objectForKey:@"type"] caseInsensitiveCompare:type] == NSOrderedSame)
                            account = dict;
                    }
                }
                if(account){
                    if([[account objectForKey:@"type"] caseInsensitiveCompare:@"instagram"] == NSOrderedSame){
                        [self setPhotos:NULL];
                        [self setAlbums:NULL];
                        [[self photosBarTitle] setTitle:[account objectForKey:@"type"]];
                        [self.view addSubview:photoView];
                        [[GCAccount sharedManager] albumsForAccount:[account objectForKey:@"accountID"] inBackgroundWithResponse:^(GCResponse *response){
                            if([response isSuccessful]){
                                [[GCAccount sharedManager] photosForAccount:[account objectForKey:@"accountID"] andAlbum:[[[response object] objectAtIndex:0] objectForKey:@"id"] inBackgroundWithResponse:^(GCResponse *response){
                                    if([response isSuccessful]){
                                        [self setPhotos:[response object]];
                                        [photosTable reloadData];
                                        [self showPhotoCountViewWithCount:[[self photos] count]];
                                    }
                                    [self hideHUD];
                                }];
                            }
                            else{
                                [self setAccountIndex:-1];
                                [self hideHUD];
                            }
                        }];
                        return;
                    }
                    [self setAlbums:NULL];
                    [self.view addSubview:albumView];
                    [self showHUD];
                    [albumsTable reloadData];
                    [[GCAccount sharedManager] albumsForAccount:[account objectForKey:@"accountID"] inBackgroundWithResponse:^(GCResponse *response){
                        if([response isSuccessful]){
                            [self setAlbums:[response object]];
                            [albumsTable reloadData];
                        }
                        else{
                            [self setAccountIndex:-1];
                        }
                        [self hideHUD];
                    }];
                }
            }
            [self hideHUD];
        }];
    }
}
-(IBAction)albumsBack:(id)sender{
    [self setAccountIndex:-1];
    [self setAlbums:NULL];
    [albumsTable reloadData];
    [albumView removeFromSuperview];
}
-(IBAction)photosBack:(id)sender{
    [self setSelectedAssets:[NSMutableSet set]];
    [self setPhotos:NULL];
    [photosTable reloadData];
    [photoView removeFromSuperview];
}
-(IBAction)addServiceBack:(id)sender{
    [AddServiceWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    [AddServiceView removeFromSuperview];
}

-(void) loginWithService:(NSString*)service{
    NSDictionary *params = [NSMutableDictionary new];
    [params setValue:@"profile" forKey:@"scope"];
    [params setValue:@"web_server" forKey:@"type"];
    [params setValue:@"code" forKey:@"response_type"];
    [params setValue:kOAuthAppID forKey:@"client_id"];
    [params setValue:kOAuthCallbackURL forKey:@"redirect_uri"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/%@?%@", 
                                                                               SERVER_URL,
                                                                               service,
                                                                               [params stringWithFormEncodedComponents]]]];
    [AddServiceWebView sizeToFit];
    [self.view addSubview:[self AddServiceView]];
    [AddServiceWebView loadRequest:request];
    [params release];
}

-(void)objectTappedWithGesture:(UIGestureRecognizer*)gesture{
    UIImageView *view = (UIImageView*)[gesture view];
    if([self multipleImageSelectionEnabled]){
        id asset = [[self photos] objectAtIndex:view.tag];
        if(![[self selectedAssets] containsObject:asset]){
            UIImageView *v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectionIndicator.png"]];
            [v setBackgroundColor:[UIColor clearColor]];
            [v setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
            [view addSubview:v];
            [v release];
            [[self selectedAssets] addObject:asset];
        }
        else{
            for(UIImageView *v in view.subviews){
                [v removeFromSuperview];
            }
            [[self selectedAssets] removeObject:asset];
        }
    }
    else{
        [self showHUD];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
            id object = [[self photos] objectAtIndex:[view tag]];
            if([object isKindOfClass:[GCAsset class]]){
                ALAsset *asset = [object alAsset];
                NSMutableDictionary* temp = [NSMutableDictionary dictionary];
                [temp setObject:[[asset defaultRepresentation] UTI] forKey:UIImagePickerControllerMediaType];
                [temp setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage] scale:1 orientation:(UIImageOrientation)[[asset defaultRepresentation] orientation]] forKey:UIImagePickerControllerOriginalImage];
                [temp setObject:[[asset defaultRepresentation] url] forKey:UIImagePickerControllerReferenceURL];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if(delegate && [delegate respondsToSelector:@selector(PhotoPickerPlusController:didFinishPickingMediaWithInfo:)])
                        [delegate PhotoPickerPlusController:self didFinishPickingMediaWithInfo:temp];
                    [self setAccounts:NULL];
                    [self setAlbums:NULL];
                    [self setPhotos:NULL];
                    [accountsTable reloadData];
                    [albumsTable reloadData];
                    [photosTable reloadData];
                    [self setAccountIndex:-1];
                    [photoView removeFromSuperview];
                    [albumView removeFromSuperview];
                    [accountView removeFromSuperview];
                    [self hideHUD];
                });
            }
            else{
                NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithDictionary:object];
                if([self accountIndex] >= 0){
                    int count = 0;
                    if([self photoAlbums])
                        count += [[self photoAlbums] count];
                    NSString *type = [ADD_SERVICES_ARRAY_LINKS objectAtIndex:[self accountIndex] - count];
                    NSDictionary *account = NULL;
                    if([self accounts]){
                        for(NSDictionary *dict in [self accounts]){
                            if([[dict objectForKey:@"type"] caseInsensitiveCompare:type] == NSOrderedSame)
                                account = dict;
                        }
                    }
                    if(account){
                        [asset setObject:account forKey:@"source"];
                    }
                }
                NSData *data = NULL;
                if([[NSString stringWithFormat:@"%@",[asset objectForKey:@"url"]] caseInsensitiveCompare:@"<null>"] != NSOrderedSame)
                    data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[asset objectForKey:@"url"]]];
                else{
                    data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[asset objectForKey:@"thumb"]]];
                }
                UIImage *image = [UIImage imageWithData:data];
                NSMutableDictionary* temp = [NSMutableDictionary dictionary];
                [temp setObject:@"public.image" forKey:UIImagePickerControllerMediaType];
                if(image)
                    [temp setObject:image forKey:UIImagePickerControllerOriginalImage];
                else if([view image])
                    [temp setObject:[view image] forKey:UIImagePickerControllerOriginalImage];
                if([[NSString stringWithFormat:@"%@",[asset objectForKey:@"url"]] caseInsensitiveCompare:@"<null>"] != NSOrderedSame)
                    [temp setObject:[asset objectForKey:@"url"] forKey:UIImagePickerControllerReferenceURL];
                else{
                    [temp setObject:[asset objectForKey:@"thumb"] forKey:UIImagePickerControllerReferenceURL];
                }
                [temp setObject:asset forKey:UIImagePickerControllerMediaMetadata];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if(delegate && [delegate respondsToSelector:@selector(PhotoPickerPlusController:didFinishPickingMediaWithInfo:)])
                        [delegate PhotoPickerPlusController:self didFinishPickingMediaWithInfo:temp];
                    [self setAccounts:NULL];
                    [self setAlbums:NULL];
                    [self setPhotos:NULL];
                    [accountsTable reloadData];
                    [albumsTable reloadData];
                    [photosTable reloadData];
                    [self setAccountIndex:-1];
                    [photoView removeFromSuperview];
                    [albumView removeFromSuperview];
                    [accountView removeFromSuperview];
                    [self hideHUD];
                });
            }
        });
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setMultipleImageSelectionEnabled:NO];
        [self setSourceType:PhotoPickerPlusSourceTypeAll];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setSelectedAssets:[NSMutableSet set]];
    
    NSMutableArray *array = [NSMutableArray array];
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group == nil) {
            [self setPhotoAlbums:array];
            [self.accountsTable reloadData];
        }
        else{
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if([group numberOfAssets]> 0)
                [array insertObject:group atIndex:0];
        }
    };
    
    void (^assetFailureBlock)(NSError *) = ^(NSError *error)
    {
        [self setPhotoAlbums:NULL];
    };
    
    if(![[GCAccount sharedManager] assetsLibrary]){
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [[GCAccount sharedManager] setAssetsLibrary:library];
        [library release];
    }
    [[[GCAccount sharedManager] assetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:assetFailureBlock];
    
    if(accountsTable){
        [accountsTable setDelegate:self];
        [accountsTable setDataSource:self];
    }
    if(albumsTable){
        [albumsTable setDelegate:self];
        [albumsTable setDataSource:self];
    }
    if(photosTable){
        [photosTable setDelegate:self];
        [photosTable setDataSource:self];
        [photosTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [photosTable setAllowsSelection:NO];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountLoginStatusChangedWithNotification:) name:GCAccountStatusChanged object:nil];
    appeared = NO;
    UIBarButtonItem *rightPhotoButton;
    if([self multipleImageSelectionEnabled])
        rightPhotoButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneSelected:)];
    else
        rightPhotoButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(closeSelected:)];
    [[self photosBarTitle] setRightBarButtonItem:rightPhotoButton];
    [rightPhotoButton release];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!appeared){
        if(sourceType == PhotoPickerPlusSourceTypeAll){
            if([self multipleImageSelectionEnabled]){
                UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photos", @"Last Photo Taken", nil];
                popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
                [popupQuery showInView:self.view];
                [popupQuery release];
            }
            else{
                UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", @"Last Photo Taken", nil];
                popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
                [popupQuery showInView:self.view];
                [popupQuery release];
            }
        }else if(sourceType == PhotoPickerPlusSourceTypeCamera){
            [self cameraSelected:nil];
        }else if(sourceType == PhotoPickerPlusSourceTypeLibrary){
            [self deviceSelected:nil];
        }else if(sourceType == PhotoPickerPlusSourceTypeNewestPhoto){
            [self latestSelected:nil];
        }
        appeared = YES;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
        [self cameraSelected:nil];
	} else if (buttonIndex == 1) {
        [self deviceSelected:nil];
	} else if (buttonIndex == 2) {
        [self latestSelected:nil];
	} else if (buttonIndex == 3) {
        [self closeSelected:nil];
	}
}

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

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == accountsTable){
        int count = 0;
        if([self photoAlbums])
            count += [[self photoAlbums] count];
        count += [ADD_SERVICES_ARRAY_NAMES count];
        return count;
    }
    if(tableView == albumsTable){
        if(!albums)
            return 0;
        return [albums count];
    }
    if(tableView == photosTable){
        if(!photos)
            return 0;
        return ceil([photos count]/4.);
    }
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    [cell.textLabel setText:@" "];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        UIView *v = [self tableView:tableView viewForIndexPath:indexPath];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if(v){
                for(UIView *view in cell.contentView.subviews){
                    [view removeFromSuperview];
                }
                [cell.contentView addSubview:v];
            }
            else{
                //                [cell.textLabel setFont:[UIFont boldSystemFontOfSize:22]];
                if(tableView == accountsTable){
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    [cell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    int count = 0;
                    if([self photoAlbums])
                        count += [[self photoAlbums] count];
                    if(indexPath.row >= count){
                        NSString *imageName = [[NSString stringWithFormat:@"%@.png",[ADD_SERVICES_ARRAY_NAMES objectAtIndex:indexPath.row - count]] lowercaseString];
                        UIImage *temp = [UIImage imageNamed:imageName];
                        [cell.imageView setImage:temp];
                        [cell.textLabel setText:[ADD_SERVICES_ARRAY_NAMES objectAtIndex:indexPath.row - count]];
                        NSString *type = [ADD_SERVICES_ARRAY_LINKS objectAtIndex:indexPath.row - count];
                        NSDictionary *account = NULL;
                        if([self accounts]){
                            for(NSDictionary *dict in [self accounts]){
                                if([[dict objectForKey:@"type"] caseInsensitiveCompare:type] == NSOrderedSame)
                                    account = dict;
                            }
                        }
                        if(account){
                            if([[NSString stringWithFormat:@"%@",[account objectForKey:@"name"]] caseInsensitiveCompare:@"(null)"] != NSOrderedSame)
                                [cell.textLabel setText:[account objectForKey:@"name"]];
                        }
                    }
                    else{
                        ALAssetsGroup *group = [self.photoAlbums objectAtIndex:indexPath.row];
                        [cell.textLabel setText:[group valueForProperty:ALAssetsGroupPropertyName]];
                        [cell.imageView setImage:[UIImage imageWithCGImage:[group posterImage]]];
                    }
                }
                if(tableView == albumsTable){
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    [cell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    [cell.textLabel setText:[[[self albums] objectAtIndex:indexPath.row] objectForKey:@"name"]];
                }
                if(tableView == photosTable){
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    [cell setEditingAccessoryType:UITableViewCellAccessoryNone];
                }
            }
        });
    });
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(tableView == photosTable)
        return 79;
	return 45;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(tableView == accountsTable){
        [self setAccountIndex:indexPath.row];
        int count = 0;
        if([self photoAlbums])
            count += [[self photoAlbums] count];
        if(indexPath.row >= count){
            NSString *type = [ADD_SERVICES_ARRAY_LINKS objectAtIndex:indexPath.row - count];
            [albumsBarTitle setTitle:[ADD_SERVICES_ARRAY_NAMES objectAtIndex:indexPath.row - count]];
            NSDictionary *account = NULL;
            if([self accounts]){
                for(NSDictionary *dict in [self accounts]){
                    if([[dict objectForKey:@"type"] caseInsensitiveCompare:type] == NSOrderedSame)
                        account = dict;
                }
            }
            if(account){
                if([[account objectForKey:@"type"] caseInsensitiveCompare:@"instagram"] == NSOrderedSame){
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSString *filePath = [self pathForCachedUrl:[NSString stringWithFormat:@"%@/%@/photos",[account objectForKey:@"accountID"],@""]];
                    if ([fileManager fileExistsAtPath:filePath])
                    {
                        NSLog(@"Using cached file!");
                        NSError *error = NULL;
                        NSString *data = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
                        if(!error){
                            id result = [data JSONValue];
                            if([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"data"])
                                result = [result objectForKey:@"data"];
                            [self setPhotos:result];
                        }
                        else{
                            [self setPhotos:NULL];
                        }
                    }
                    else{
                        [self setPhotos:NULL];
                    }
                    [self setAlbums:NULL];
                    [[self photosBarTitle] setTitle:[ADD_SERVICES_ARRAY_NAMES objectAtIndex:indexPath.row - count]];
                    [self.view addSubview:photoView];
                    [photosTable reloadData];
                    if(![self photos])
                        [self showHUD];
                    [[GCAccount sharedManager] albumsForAccount:[account objectForKey:@"accountID"] inBackgroundWithResponse:^(GCResponse *response){
                        if([response isSuccessful]){
                            [[GCAccount sharedManager] photosForAccount:[account objectForKey:@"accountID"] andAlbum:[[[response object] objectAtIndex:0] objectForKey:@"id"] inBackgroundWithResponse:^(GCResponse *response){
                                if([response isSuccessful]){
                                    [self setPhotos:[response object]];
                                    [photosTable reloadData];
                                    [self showPhotoCountViewWithCount:[[self photos] count]];
                                    [[response rawResponse] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
                                }
                                [self hideHUD];
                            }];
                        }
                        else{
                            if(![self photos])
                                [self setAccountIndex:-1];
                            [self hideHUD];
                        }
                    }];
                    return;
                }
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *filePath = [self pathForCachedUrl:[NSString stringWithFormat:@"%@/albums",[account objectForKey:@"accountID"]]];
                if ([fileManager fileExistsAtPath:filePath])
                {
                    NSLog(@"Using cached file!");
                    NSError *error = NULL;
                    NSString *data = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
                    if(!error){
                        id result = [data JSONValue];
                        if([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"data"])
                            result = [result objectForKey:@"data"];
                        [self setAlbums:result];
                    }
                    else{
                        [self setAlbums:NULL];
                    }
                }
                else{
                    [self setAlbums:NULL];
                }
                [self.view addSubview:albumView];
                [albumsTable reloadData];
                if(![self albums])
                    [self showHUD];
                [[GCAccount sharedManager] albumsForAccount:[account objectForKey:@"accountID"] inBackgroundWithResponse:^(GCResponse *response){
                    if([response isSuccessful]){
                        [self setAlbums:[response object]];
                        [albumsTable reloadData];
                        [[response rawResponse] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
                    }
                    else{
                        if(![self albums])
                            [self setAccountIndex:-1];
                    }
                    [self hideHUD];
                }];
            }
            else{
                [self loginWithService:type];
            }
        }
        else{
            ALAssetsGroup *group = [self.photoAlbums objectAtIndex:indexPath.row];
            [self setPhotos:NULL];
            [[self photosBarTitle] setTitle:[group valueForProperty:ALAssetsGroupPropertyName]];
            [self.view addSubview:photoView];
            [photosTable reloadData];
            [self showHUD];
            
            NSMutableArray *assetsArray = [[NSMutableArray alloc] init];
            
            void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop)
            {
                if(result != nil){
                    GCAsset *_asset = [[GCAsset alloc] init];
                    [_asset setAlAsset:result];
                    [assetsArray insertObject:_asset atIndex:0];
                    [_asset release];
                }
                else{
                    [self setPhotos:assetsArray];
                    [photosTable reloadData];
                    [self showPhotoCountViewWithCount:[[self photos] count]];
                    [self hideHUD];
                }
            };
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:assetEnumerator];
        }
        /*
         GCResponse *response = [[GCAccount sharedManager] albumsForAccount:[[accounts objectAtIndex:indexPath.row] objectForKey:@"accountID"]];
         if([response isSuccessful]){
         [self setAlbums:[response object]];
         [self.view addSubview:albumView];
         [albumsTable reloadData];
         }
         else{
         [self setAccountIndex:-1];
         }
         */
    }
    if(tableView == albumsTable){
        if([self accountIndex] >= 0){
            int count = 0;
            if([self photoAlbums])
                count += [[self photoAlbums] count];
            NSString *type = [ADD_SERVICES_ARRAY_LINKS objectAtIndex:[self accountIndex] - count];
            NSDictionary *account = NULL;
            if([self accounts]){
                for(NSDictionary *dict in [self accounts]){
                    if([[dict objectForKey:@"type"] caseInsensitiveCompare:type] == NSOrderedSame)
                        account = dict;
                }
            }
            if(account){
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *filePath = [self pathForCachedUrl:[NSString stringWithFormat:@"%@/%@/photos",[account objectForKey:@"accountID"],[[albums objectAtIndex:indexPath.row] objectForKey:@"id"]]];
                if ([fileManager fileExistsAtPath:filePath])
                {
                    NSLog(@"Using cached file!");
                    NSError *error = NULL;
                    NSString *data = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
                    if(!error){
                        id result = [data JSONValue];
                        if([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"data"])
                            result = [result objectForKey:@"data"];
                        [self setPhotos:result];
                    }
                    else{
                        [self setPhotos:NULL];
                    }
                }
                else{
                    [self setPhotos:NULL];
                }
                [[self photosBarTitle] setTitle:[[[self albums] objectAtIndex:indexPath.row] objectForKey:@"name"]];
                [self.view addSubview:photoView];
                [photosTable reloadData];
                if(![self photos])
                    [self showHUD];
                [[GCAccount sharedManager] photosForAccount:[account objectForKey:@"accountID"] andAlbum:[[albums objectAtIndex:indexPath.row] objectForKey:@"id"] inBackgroundWithResponse:^(GCResponse *response){
                    if([response isSuccessful]){
                        [self setPhotos:[response object]];
                        [photosTable reloadData];
                        [self showPhotoCountViewWithCount:[[self photos] count]];
                        [[response rawResponse] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
                    }
                    [self hideHUD];
                }];
            }
        }
    }
    if(tableView == photosTable){
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForIndexPath:(NSIndexPath*)indexPath{
    if(tableView == photosTable){
        int count = 0;
        if([self photoAlbums])
            count += [[self photoAlbums] count];
        if([self accountIndex] >= count){
            UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, photosTable.frame.size.width, [self tableView:photosTable heightForRowAtIndexPath:indexPath])] autorelease];
            int index = indexPath.row * 4;
            int maxIndex = index + 3;
            CGRect rect = CGRectMake(2, 1, 77, 77);
            int x = 4;
            if (maxIndex >= [[self photos] count]) {
                x = x - (maxIndex - [[self photos] count]) - 1;
            }
            
            for (int i=0; i<x; i++) {
                NSDictionary *asset = [[self photos] objectAtIndex:index+i];
                UIImageView *image = [[[UIImageView alloc] initWithFrame:rect] autorelease];
                [image setTag:index+i];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(objectTappedWithGesture:)];
                [image addGestureRecognizer:tap];
                [tap release];
                [image setUserInteractionEnabled:YES];
                [image setImageWithURL:[NSURL URLWithString:[asset objectForKey:@"thumb"]]];
                [view addSubview:image];
                if([[self selectedAssets] containsObject:asset]){
                    UIImageView *v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectionIndicator.png"]];
                    [v setBackgroundColor:[UIColor clearColor]];
                    [v setFrame:CGRectMake(0, 0, image.frame.size.width, image.frame.size.height)];
                    [image addSubview:v];
                    [v release];
                }
                rect = CGRectMake((rect.origin.x+77+2), rect.origin.y, rect.size.width, rect.size.height);
            }
            return view;
        }
        else{
            UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, photosTable.frame.size.width, [self tableView:photosTable heightForRowAtIndexPath:indexPath])] autorelease];
            int index = indexPath.row * 4;
            int maxIndex = index + 3;
            CGRect rect = CGRectMake(2, 1, 77, 77);
            int x = 4;
            if (maxIndex >= [[self photos] count]) {
                x = x - (maxIndex - [[self photos] count]) - 1;
            }
            
            for (int i=0; i<x; i++) {
                GCAsset *asset = [[self photos] objectAtIndex:index+i];
                UIImageView *image = [[[UIImageView alloc] initWithFrame:rect] autorelease];
                [image setTag:index+i];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(objectTappedWithGesture:)];
                [image addGestureRecognizer:tap];
                [tap release];
                [image setUserInteractionEnabled:YES];
                [image setImage:[asset thumbnail]];
                [view addSubview:image];
                if([[self selectedAssets] containsObject:asset]){
                    UIImageView *v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectionIndicator.png"]];
                    [v setBackgroundColor:[UIColor clearColor]];
                    [v setFrame:CGRectMake(0, 0, image.frame.size.width, image.frame.size.height)];
                    [image addSubview:v];
                    [v release];
                }
                rect = CGRectMake((rect.origin.x+77+2), rect.origin.y, rect.size.width, rect.size.height);
            }
            return view;
        }
    }
    return nil;
}

#pragma mark WebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] path] isEqualToString:kOAuthCallbackRelativeURL]) {
        NSString *_code = [[NSDictionary dictionaryWithFormEncodedString:[[request URL] query]] objectForKey:@"code"];
        
        [[GCAccount sharedManager] verifyAuthorizationWithAccessCode:_code success:^(void) {
            [self addServiceBack:nil];
        } andError:^(NSError *error) {
            DLog(@"%@", [error localizedDescription]);
        }];
        
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self showHUDWithTitle:nil andOpacity:0.3f];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideHUD];
    
    if (error.code == NSURLErrorCancelled) return; 
    
    if (![[error localizedDescription] isEqualToString:@"Frame load interrupted"]) {
        [self quickAlertViewWithTitle:@"Error" message:[error localizedDescription] button:@"Reload" completionBlock:^(void) {
            [AddServiceWebView reload]; 
        } cancelBlock:^(void) {
            [self addServiceBack:nil];
        }];
    }
}

@end
