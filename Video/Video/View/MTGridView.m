//
//  MTGridView.m
//  Video
//
//  Created by Apple on 7/31/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTGridView.h"
#import "MTDataModel.h"
#import <FMMosaicLayout/FMMosaicLayout.h>
#import "MTGridViewCell.h"
#import "MTGridViewCell.h"
#import "MTVideoView.h"
#import "MTVideo.h"


#define MTGridViewCellReuseID         @"MTGridViewCell"

@interface MTGridView()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *videos;
@end

@implementation MTGridView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup {
    [self.collectionView registerClass:[MTGridViewCell class] forCellWithReuseIdentifier:MTGridViewCellReuseID];
}

- (void)setCategoryId:(NSUInteger)categoryId {
    _categoryId = categoryId;
    
    self.videos = [[MTDataModel sharedDatabaseStorage] getVideosByCategory:categoryId
                                                                minusVideo:self.firstTileVideoView.videoId];
    FMMosaicLayout *mosaicLayout = [[FMMosaicLayout alloc] init];
    self.collectionView.collectionViewLayout = mosaicLayout;
    
    [self.collectionView reloadData];
}


#pragma mark - UICollectionView datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MTVideo *video = [self.videos objectAtIndex:indexPath.row <= 1 ? 0 : indexPath.row - 1];
    MTGridViewCell *cell =
    (MTGridViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:MTGridViewCellReuseID
                                                                forIndexPath:indexPath];
    
    if (indexPath.row == 1 && indexPath.section == 0) {
        [cell setupVideViewWithExistingVideoView:self.firstTileVideoView];
    }
    
    else  {
        [cell setupVideoViewWithURL:video.url];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - <FMMosaicLayoutDelegate>

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout
   numberOfColumnsInSection:(NSInteger)section {
    
    return 3; // Or any number of your choosing.
}

- (FMMosaicCellSize)collectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout
  mosaicCellSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0)
        return FMMosaicCellSizeSmall;
    
    return FMMosaicCellSizeBig;
}


@end
