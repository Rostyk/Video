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

@import UPCarouselFlowLayout;

@interface ViewController () <MTPodcastDataSource, UICollectionViewDataSource>
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
    [[MTDataModel sharedDatabaseStorage] fetchObjectsForEntityName:@"Yo" withPredicate:nil];
    MTInfo *info1 = [[MTInfo alloc] initWithTitle:@"Some decription of the video goes here. Lorem ipsum"
                                          channel:@"Channel name"
                                     channelImage:nil
                                      bottomImage:nil
                                         videoUrl:@"http://media.video-cdn.espn.com/motion/2017/0717/dm_170717_nfl_news_elliott_bar_incident/dm_170717_nfl_news_elliott_bar_incident_720p30_2896k.mp4"];
    
    MTInfo *info2 = [[MTInfo alloc] initWithTitle:@"Lorem ipsum dolor sit amet consectetur adipiscing"
                                          channel:@"Here goes the channel name"
                                     channelImage:nil
                                      bottomImage:nil
                                         videoUrl:@"http://sachinchoolur.github.io/lightGallery/static/videos/video2.mp4"];
    
    MTInfo *info3 = [[MTInfo alloc] initWithTitle:@"Duis aute irure dolor in reprehenderit in voluptate"
                                          channel:@"Some channel"
                                     channelImage:nil
                                      bottomImage:nil
                                         videoUrl:@"http://techslides.com/demos/sample-videos/small.mp4"];
    
    MTInfo *info4 = [[MTInfo alloc] initWithTitle:@"Video 4. Last video"
                                          channel:@"Another channel"
                                     channelImage:nil
                                      bottomImage:nil
                                         videoUrl:@"http://html5videoformatconverter.com/data/images/happyfit2.mp4"];
    self.videos = @[info1, info2, info3, info4];

    self.podcastsView.datasource = self;
    
    self.icons = @[@"icon1", @"icon2", @"icon3", @"icon4", @"icon1", @"icon2", @"icon3", @"icon4"];
    
    //fff
    
    UPCarouselFlowLayout *layout = [[UPCarouselFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    layout.itemSize = CGSizeMake(60, 60);
    self.collectionView.collectionViewLayout = layout;
    

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
    return 8;
}
    
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = (MenuCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MenuCell" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:self.icons[indexPath.row]];
    return cell;
}

    

@end
