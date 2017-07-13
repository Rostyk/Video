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
    MTInfo *info1 = [[MTInfo alloc] initWithTitle:@"Some decription of the video goes here. Lorem ipsum"
                                          channel:@"Channel name"
                                     channelImage:nil
                                      bottomImage:nil
                                         videoUrl:@"https://r2---sn-p5qlsnzd.googlevideo.com/videoplayback?ipbits=0&mm=31&expire=1499978093&mt=1499956406&ei=DYVnWZLlFM_p1gK_95zoAw&requiressl=yes&lmt=1479730735274578&dur=350.296&itag=22&ratebypass=yes&mv=m&initcwndbps=67500&source=youtube&sparams=dur%2Cei%2Cid%2Cinitcwndbps%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cexpire&ms=au&pl=24&id=o-AMH-EE540NhaIBpN6Znl51m7czr4d_RYU8Wr0z_Uj7uv&mime=video%2Fmp4&mn=sn-p5qlsnzd&ip=159.253.144.86&key=yt6&signature=AFEA6B7D167FFCCA77D0AD876B75FEA19DCD2ADD.8F90F65CA5B6E52AB60FF5362ED1E38DCACA8330&title=Lionel+Messi+-+Story+with+Argentina"];
    
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
