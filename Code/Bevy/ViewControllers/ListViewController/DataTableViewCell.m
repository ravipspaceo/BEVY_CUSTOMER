//
//  DataTableViewCell.m
//  TableCellAnimationDemo
//
//  Created by CompanyName on 12/23/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "DataTableViewCell.h"
#import "ItemCollectionViewCell.h"

@implementation DataTableViewCell

- (void)awakeFromNib
{
    [self.itemsCollectionView setFrame:self.contentView.bounds];
    [self.itemsCollectionView registerNib:[UINib nibWithNibName:@"ItemCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ItemCollectionCell"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - UICollectionViewDelegate Methods

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrItems.count;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemCollectionCell" forIndexPath:indexPath];    
    NSMutableDictionary *dict = [self.arrItems objectAtIndex:indexPath.row];
    [cell.lblItemName setText:[dict valueForKey:@"category_name"]];
;
    [cell.imgItem sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"category_icon"]] placeholderImage:[UIImage imageNamed:@"listview_placeholder"]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionDelegate dataTableViewCell:self didSelectItemAtIndexPath:indexPath];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (IS_IPHONE_6)
    {
        return 20;
    }
    else if (IS_IPHONE_6_PLUS)
    {
        return 40;
    }
    return 10.0;
}

@end
