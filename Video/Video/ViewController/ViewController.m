//
//  ViewController.m
//  Video
//
//  Created by Rostyslav Stepanyak on 6/14/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "ViewController.h"
#import "MTVideoView.h"
#import "MTPodscastsView.h"
#import "MenuCell.h"
#import "MTDataModel.h"
#import "MTGetVideosRequest.h"
#import "MTGetVideosResponse.h"
#import "MTVideo.h"
#import "MTProgressView.h"
#import "MTLoginRequest.h"
#import "MTLoginResponse.h"
#import "GMImagePickerController.h"
#import "AssetToDataConverter.h"
#import "MTUploadVideoRequest.h"
#import "MTUploadVideoResponse.h"
#import "MTProgressHUD.h"
#import "JVFloatLabeledTextView.h"
#import "JVFloatLabeledTextField.h"
#import "MTInputVideoInfoViewController.h"

@import UPCarouselFlowLayout;

@interface ViewController () <MTPodcastDataSource, UICollectionViewDataSource, UICollectionViewDelegate, GMImagePickerControllerDelegate>
@property (nonatomic, weak) IBOutlet MTPodscastsView *podcastsView;
@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, weak) IBOutlet UIButton *gridButton;
@property (nonatomic, weak) IBOutlet UIButton *homeButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    [self login];
}

- (void)login {
    self.gridButton.alpha = 0.0;
    self.homeButton.alpha = 0.0;
    [[MTProgressView sharedView] showInView:self.view];
    
    __weak typeof(self) weakSelf = self;
    MTLoginRequest *loginRequest = [MTLoginRequest new];
    loginRequest.username = @"User1";
    loginRequest.password = @"user123";
    loginRequest.completionBlock = ^(SDRequest *request, SDResult *response) {
        [weakSelf getVideos];
    };
    
    [loginRequest run];
}

- (void)getVideos {
    __weak typeof(self) weakSelf = self;
    NSString *category = @"nba";
    MTGetVideosRequest *getVideosRequest = [MTGetVideosRequest new];
    getVideosRequest.category = category;
    getVideosRequest.completionBlock = ^(SDRequest *request, SDResult *response) {
        NSArray *videos = [[MTDataModel sharedDatabaseStorage] getVideosByCategory:category];
        weakSelf.videos = videos;
        [weakSelf setupVideoLinks];
        
        [[MTProgressView sharedView] remove];
        [UIView animateWithDuration:1.8
                         animations:^{
                             self.homeButton.alpha = 1.0;
                             self.gridButton.alpha = 1.0;
                         }
                         completion:NULL];
    };
    
    [getVideosRequest run];
}

- (void)setupVideoLinks {
    self.podcastsView.datasource = self;
    self.icons = @[@"", @"", @"", @"ic_trending", @"ic_NBA", @"ic_NHL", @"ic_MLB", @"ic_CFB", @"ic_EFL", @"ic_NFL", @"ic_CBB", @"ic_skateboarding", @"ic_GOLF", @"ic_surfing", @"", @"", @""];
    
    //setup layout
    UPCarouselFlowLayout *layout = [[UPCarouselFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 125.0f;
    layout.sideItemShift = 3.0f;
    layout.minimumLineSpacing = 5.0f;
    layout.itemSize = CGSizeMake(52, 52);
    self.collectionView.collectionViewLayout = layout;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView reloadData];
}

#pragma mark - MTPodcastDataSource

- (MTVideo *)videoInfoForIndex:(NSInteger)index {
    MTVideo *info = self.videos[index];
    return info;
}

- (NSUInteger)numberOfVideos {
    return self.videos.count;
}
    

#pragma mark - CollectionView data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.icons.count;
}
    
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = (MenuCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MenuCell" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:self.icons[indexPath.row]];
    return cell;
}

#pragma mark - Collection view delegate 

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}

#pragma mark - grid view

- (IBAction)gridButtonClicked {
    [self.podcastsView switchVideModes];
}

#pragma mark - upload video

- (IBAction)uploadVideButtonClicked:(id)sender {
    MTInputVideoInfoViewController *vvv = [MTInputVideoInfoViewController new];
    [self presentViewController:vvv animated:YES completion:NULL];
    return;
    
    GMImagePickerController *picker = [[GMImagePickerController alloc] init];
    
    //Display or not the selection info Toolbar:
    picker.displaySelectionInfoToolbar = YES;
    
    //Display or not the number of assets in each album:
    picker.displayAlbumsNumberOfAssets = YES;
    
    //Customize the picker title and prompt (helper message over the title)
    picker.title = @"";
    picker.customNavigationBarPrompt = @"Please pick the video to upload";
    
    //Customize the number of cols depending on orientation and the inter-item spacing
    picker.colsInPortrait = 3;
    picker.colsInLandscape = 5;
    picker.minimumInteritemSpacing = 2.0;
    
    //You can pick the smart collections you want to show:
    /*_customSmartCollections = @[@(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                @(PHAssetCollectionSubtypeSmartAlbumSlomoVideos),
                                @(PHAssetCollectionSubtypeSmartAlbumTimelapses),
                                @(PHAssetCollectionSubtypeSmartAlbumBursts),
                                @(PHAssetCollectionSubtypeSmartAlbumPanoramas)];*/
    
    
    //Disable multiple selecion
    picker.allowsMultipleSelection = NO;
    
    //Show a promt to confirm single selection
    picker.confirmSingleSelection = YES;
    picker.confirmSingleSelectionPrompt = @"Do you want to upload this video?";
    
    //Camera integration
    picker.showCameraButton = YES;
    picker.autoSelectCameraImages = YES;
    
    //Select the media types you want to show and filter out the rest
    picker.mediaTypes = @[@(PHAssetMediaTypeVideo)];
    
    //UI color & text customizations
    picker.pickerBackgroundColor = [UIColor blackColor];
    picker.pickerTextColor = [UIColor whiteColor];
    picker.toolbarBarTintColor = [UIColor colorWithRed:120./255. green:120./255. blue:120./255. alpha:0.3];
    picker.toolbarTextColor = [UIColor whiteColor];
    picker.toolbarTintColor = [UIColor whiteColor];
    picker.navigationBarBackgroundColor = [UIColor blackColor];
    picker.navigationBarTextColor = [UIColor whiteColor];
    picker.navigationBarTintColor = [UIColor whiteColor];
    picker.pickerFontName = @"HelveticaNeue-Light";
    picker.pickerBoldFontName = @"HelveticaNeue-Thin";
    picker.pickerFontNormalSize = 14.f;
    picker.pickerFontHeaderSize = 17.0f;
    picker.pickerStatusBarStyle = UIStatusBarStyleLightContent;
    picker.useCustomFontForNavigationBar = YES;
    
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - GMImagePickerControllerDelegate

- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assetArray {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    PHAsset *asset = [assetArray firstObject];
    __weak typeof(self) weakSelf = self;
    [AssetToDataConverter convertAsset:asset completion:^(NSData *data, NSString *path) {
        [weakSelf uploadVideoData:data path:path];
    }];
    
    NSLog(@"GMImagePicker: User ended picking assets. Number of selected items is: %lu", (unsigned long)assetArray.count);
}

- (void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker {
    NSLog(@"GMImagePicker: User pressed cancel button");
}

#pragma mark - upload video request

- (void)uploadVideoData:(NSData *)data path:(NSString *)path{
    [[MTProgressHUD sharedHUD] showOnView:self.view percentage:false];
    
    __weak typeof(self) weakSelf = self;
    MTUploadVideoRequest *uploadRequest = [MTUploadVideoRequest new];
    uploadRequest.path = path;
    uploadRequest.videoData = data;
    uploadRequest.category = @"nba";
    uploadRequest.completionBlock = ^(SDRequest *request, SDResult *response) {
        [weakSelf getVideos];
    };
    
    [uploadRequest run];
}
    

@end
