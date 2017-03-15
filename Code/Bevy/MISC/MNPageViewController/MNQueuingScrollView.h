//
//  MNQueuingScrollView.h
//  MNPageViewController
//
//  Created by CompanyName on 7/22/13.
//  Copyright (c) 2013 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MNQueuingScrollViewDelegate<NSObject, UIScrollViewDelegate>

@optional

- (void)queuingScrollViewDidPageForward:(UIScrollView *)scrollView;
- (void)queuingScrollViewDidPageBackward:(UIScrollView *)scrollView;

@end

@interface MNQueuingScrollView : UIScrollView

@property(nonatomic,weak) id <MNQueuingScrollViewDelegate> delegate;

@end
