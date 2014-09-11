//
//  MasterViewController.m
//  AOReportListTableViewControllerDemo
//
//  Created by Anthony Miller on 8/14/14.
//  Copyright (c) 2014 App-Order, LLC. All rights reserved.
//

#import "MasterViewController.h"

#import <AOReportListViewController/AOReportListTableViewController.h>
#import <AOReportListViewController/AOReportListOperationManagerProtocol.h>
#import <AOReportListViewController/AOReportListItemProtocol.h>

#import <AOReportNavigationController/AOReportNavigationController.h>
#import <AOReportNetworking/AOReportAnonymousOperationManager.h>
#import <AOReportNetworking/AOReportOperationManager.h>
#import <AOReportNetworking/AOReportSchemaManager.h>
#import <AOReportModels/AOReportUser.h>
#import <AOReportModels/AOReportSchema.h>
#import <AOReportAdapter/AOReportOperationManager+AOReportListOperationManagerProtocol.h>
#import <AOReportAdapter/AOReportUser+AOReportUserAuthenticationProtocol.h>
#import <AOReportAdapter/AODetail+AODetailNavigationProtocol.h>

@implementation MasterViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  AOReportUser *user = [AOReportUser currentUser];
  
  NSURL *baseURL = [NSURL URLWithString:@"http://app-order.com"];
  [AOReportAnonymousOperationManager createSharedInstanceWithBaseURL:baseURL appIdentifier:353 appVersion:@"1.0.0" user:user];
}

- (IBAction)myReportsButtonPressed:(id)sender
{
  AOReportListTableViewController * vc = [[AOMyReportsListTableViewController alloc] initWithSchemaID:1128 operationManager:[AOReportAnonymousOperationManager sharedInstance]];
  vc.delegate = self;
  
  [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)allOpenButtonPressed:(id)sender {
  
  AOReportListTableViewController *vc = [[AOReportListTableViewController alloc] initWithSchemaID:1128 scope:AOReportListOperationScopeScopeAll operationManager:[AOReportOperationManager sharedInstance]];
  vc.delegate = self;
  
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)controller:(AOBaseReportListTableViewController *)controller didSelectReport:(id<AOReportListItemProtocol>)report
{
  AOReportOperationManager *operationManger = [AOReportOperationManager sharedInstance];
  [operationManger getReportWithID:[report identifier]
                           success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject)
   {
     AOReportSchemaManager *schemaManager = [AOReportSchemaManager sharedInstance];
     
     AOReportSchema *reportSchema = [schemaManager reportSchemaForIdentifier:[report schemaIdentifier] error:nil];
     [reportSchema mapValuesFromReportDictionary:responseObject];
     
     AOReportNavigationController *navController = [[AOReportNavigationController alloc]
                                                    initWithRootDetail:reportSchema.rootDetail
                                                    wizard:reportSchema.wizard];
     navController.editable = NO;
     navController.delegate = self;
     [self presentViewController:navController animated:YES completion:nil];
   }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error)
  {
    return;
  }];
   
}

#pragma mark - AOReportNavigationControllerDelegate

- (void)userPressedQuitOnReportNavigationController:(AOReportNavigationController *)controller
{
  [self dismissViewControllerAnimated:controller completion:nil];
}

- (void)userPressedSubmitButtonOnReportNavigationController:(AOReportNavigationController *)controller
{
  
}

@end
