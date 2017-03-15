//
//  CardsViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddCardViewController.h"
#import "CardIO.h"

/**
 * This class is used to view the added payment cards.
 */
@interface CardsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, StripCardDelegate, CardIOPaymentViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tblCardsView;
@property (nonatomic, strong) IBOutlet UIButton *btnAdd;
@property (nonatomic, strong) IBOutlet UILabel *labelNoRecords;

@property(nonatomic, retain) WS_Helper *objWSHelper;

@property (nonatomic, strong) NSMutableArray *arrayCards;
@property (nonatomic, assign) BOOL isCardFunctionality;
@property (nonatomic, assign) BOOL isFromProfile;

@property (nonatomic, assign) BOOL isFromOrderDetails;
@end
