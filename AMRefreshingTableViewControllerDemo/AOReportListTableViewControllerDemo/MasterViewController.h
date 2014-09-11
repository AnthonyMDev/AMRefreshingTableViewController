//
//  MasterViewController.h
//  AOReportListTableViewControllerDemo
//
//  Created by Anthony Miller on 8/14/14.
//  Copyright (c) 2014 App-Order, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AOBaseControllers/AOBaseViewController.h>

#import <AOReportListViewController/AOReportListViewControllerDelegate.h>

#import <AOReportNavigationController/AOReportNavigationControllerDelegate.h>

@interface MasterViewController : AOBaseViewController <AOReportListViewControllerDelegate, AOReportNavigationControllerDelegate>

- (IBAction)myReportsButtonPressed:(id)sender;

- (IBAction)allOpenButtonPressed:(id)sender;
@end
