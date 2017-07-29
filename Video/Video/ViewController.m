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
#import "MTInfo.h"
#import "MenuCell.h"
#import "MTDataModel.h"
#import "MTGetVideosRequest.h"
#import "MTGetVideosResponse.h"
#import "MTVideo.h"

@import UPCarouselFlowLayout;

@interface ViewController () <MTPodcastDataSource, UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) IBOutlet MTPodscastsView *podcastsView;
@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    __weak typeof(self) weakSelf = self;
    NSString *category = @"nba";
    MTGetVideosRequest *getVideosRequest = [MTGetVideosRequest new];
    getVideosRequest.category = category;
    getVideosRequest.completionBlock = ^(SDRequest *request, SDResult *response) {
        NSArray *videos = [[MTDataModel sharedDatabaseStorage] getVideosByCategory:category];
        weakSelf.videos = videos;
        [weakSelf setupVideoLinks];
    };
    
    [getVideosRequest run];
}

- (void)setupVideoLinks {
    NSMutableArray *parsedVideoMetaDatas = [NSMutableArray new];
    for (MTVideo *video in self.videos) {
        MTInfo *videoMetaData = [[MTInfo alloc] initWithTitle:@"Some decription of the video goes here. Lorem ipsum"
                                              channel:@"Channel name"
                                         channelImage:nil
                                          bottomImage:nil
                                             videoUrl:video.url];
        [parsedVideoMetaDatas addObject:videoMetaData];
    }
   
    self.videos = parsedVideoMetaDatas;
    
    self.podcastsView.datasource = self;
   
    
    dispatch_async(dispatch_get_main_queue(), ^{
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
        
    });
}

#pragma mark - MTPodcastDataSource

- (MTInfo *)videoInfoForIndex:(NSInteger)index {
    MTInfo *info = self.videos[index];
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

    

@end
