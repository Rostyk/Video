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
#import "MTVideoLinksFetcher.h"

#import <Crashlytics/Crashlytics.h>

@import UPCarouselFlowLayout;

@interface ViewController () <MTPodcastDataSource, UICollectionViewDataSource, UICollectionViewDelegate, GMImagePickerControllerDelegate, MTInputVideoInfoDelegate>
@property (nonatomic, weak) IBOutlet MTPodscastsView *podcastsView;
@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, weak) IBOutlet UIButton *gridButton;
@property (nonatomic, weak) IBOutlet UIButton *uploadButton;
@property (nonatomic, weak) IBOutlet UIButton *homeButton;
@property (nonatomic, weak) IBOutlet UIView *bottomView;

@property (nonatomic) NSUInteger currentPage;
@property (nonatomic, weak) IBOutlet UIImageView *bgView;
@property (nonatomic, weak) IBOutlet UIImageView *topbBadgeView;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setupAnimation];
}

- (void)setupAnimation {
    self.bgView.image = [UIImage imageNamed:@"bg_frame3"];
    
    CABasicAnimation *theAnimation;
    
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=1.0;
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    theAnimation.toValue=[NSNumber numberWithFloat:0.0];
    [self.bgView.layer addAnimation:theAnimation forKey:@"animateOpacity"];
}

- (void)setup {
    _currentPage = 2;
    [self login];
}

- (void)login {
    self.bottomView.alpha = 0.0;
    self.topbBadgeView.alpha = 0.0;
    self.searchButton.alpha = 0.0;
   // [[MTProgressHUD sharedHUD] showOnView:self.view percentage:false];
    
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

    [[MTVideoLinksFetcher fetcher] fetch:^(BOOL success, NSError *error) {
         NSArray *videos = [[MTDataModel sharedDatabaseStorage] getVideosByCategory:self.currentPage + 1];
         weakSelf.videos = videos;
         [weakSelf setupVideoLinks];
         
         //[[MTProgressHUD sharedHUD] dismiss];
         [weakSelf hideBgView];
    }];
    
}

- (void)setupVideoLinks {
    self.podcastsView.datasource = self;
    self.icons = @[@"ic_NFL", @"ic_NHL", @"ic_NBA", @"ic_MLB", @"ic_CFB", @"ic_CBB", @"ic_GOLF"];
    
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
    if (index < self.videos.count) {
        MTVideo *info = self.videos[index];
        return info;
    }
    
    return nil;
}

- (NSUInteger)numberOfVideos {
    return self.videos.count;
}

- (NSUInteger)categoryId {
    return self.currentPage + 1;
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    UPCarouselFlowLayout *layout = (UPCarouselFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat pageSide = (layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? [self pageSize].width : [self pageSize].height;
    CGFloat offset = (layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y;
    
    self.currentPage = (NSUInteger)(floor((offset - pageSide / 2.) / pageSide) + 1);
    [self changeSection];
}

- (CGSize)pageSize {
    UPCarouselFlowLayout *layout = (UPCarouselFlowLayout *)self.collectionView.collectionViewLayout;
    CGSize pageSize = CGSizeMake(48, 48);
    if (layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        pageSize.width += 2;
    } else {
        pageSize.height += 2;
    }
    return pageSize;
}

- (UIDeviceOrientation)orientation {
   return [UIDevice currentDevice].orientation;
}

// Layout: Set Edges
/*- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}*/

#pragma mark - grid view

- (IBAction)gridButtonClicked {
    [self.podcastsView switchVideModes];
}

#pragma mark - upload video

- (IBAction)uploadVideButtonClicked:(id)sender {
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
        [weakSelf showVideoDetailsControllerForUploadVideoData:data path:path];
    }];
    
    NSLog(@"GMImagePicker: User ended picking assets. Number of selected items is: %lu", (unsigned long)assetArray.count);
}

- (void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker {
    NSLog(@"GMImagePicker: User pressed cancel button");
}

#pragma mark - input data details presentation

- (void)showVideoDetailsControllerForUploadVideoData:(NSData *)data path:(NSString *)path{
    MTInputVideoInfoViewController *inputVideoInfoViewController = [MTInputVideoInfoViewController new];
    inputVideoInfoViewController.path = path;
    inputVideoInfoViewController.category = @"nba";
    inputVideoInfoViewController.videoData = data;
    inputVideoInfoViewController.delegate = self;
    
    [self presentViewController:inputVideoInfoViewController animated:YES completion:NULL];
}

#pragma mark - MTInputVideViewDelegate

/*
- (void)onVideoUploadedWithId:(NSNumber *)videoId {
    __weak typeof(self) weakSelf = self;
    NSString *category = @"nba";
    
    NSMutableArray *ids = [NSMutableArray new];
    for (MTVideo *video in self.videos) {
        [ids addObject:video.videoId];
    }
    
    [[MTProgressHUD sharedHUD] showOnView:self.view
                               percentage:false];
    
    MTGetVideosRequest *getVideosRequest = [MTGetVideosRequest new];
    getVideosRequest.category = category;
    getVideosRequest.completionBlock = ^(SDRequest *request, SDResult *response) {
        NSArray *videos = [[MTDataModel sharedDatabaseStorage] getVideosByCategory:category];
        
        if (videos.count - self.videos.count == 1) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.videoId == %@", videoId];
            NSArray *newVideo = [videos filteredArrayUsingPredicate:predicate];
            
            NSMutableArray *newArray = [[NSMutableArray alloc] init];
            for (NSString *oldVideoId in ids) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.videoId == %@", oldVideoId];
                NSArray *videoFromNewPack = [videos filteredArrayUsingPredicate:predicate];
                [newArray addObject:videoFromNewPack.firstObject];
            }
            
            [newArray addObject:newVideo.firstObject];
            weakSelf.videos = newArray;
        }
        
        [[MTProgressHUD sharedHUD] dismiss];
    };
    
    [getVideosRequest run];
}*/

- (void)changeSection {
    NSLog(@"Current page: %ld", self.currentPage);
    NSArray *videos = [[MTDataModel sharedDatabaseStorage] getVideosByCategory:(self.currentPage + 1)];
    self.videos = videos;
    
    [self.podcastsView reload];
}

- (void)hideBgView {
    [self.bgView.layer removeAllAnimations];
    [UIView animateWithDuration:0.4 animations:^{
        self.bgView.alpha = 0;
    }];
    
    [UIView animateWithDuration:0.8
                     animations:^{
                         self.bottomView.alpha = 1.0;
                         self.topbBadgeView.alpha = 1.0;
                         self.searchButton.alpha = 1.0;
                     }
                     completion:NULL];
}


@end
