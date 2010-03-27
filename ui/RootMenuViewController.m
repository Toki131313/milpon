//
//  RootMenuViewController.m
//  Milpon
//
//  Created by Motohiro Takayama on 3/26/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "RootMenuViewController.h"
#import "OverviewViewController.h"
#import "TaskCollection.h"
#import "TaskCollectionViewController.h"
#import "AppDelegate.h"
#import "ReviewViewController.h"
#import "RTMSynchronizer.h"
#import "Reachability.h"
#import "ProgressView.h"
#import "RefreshingViewController.h"

@implementation RootMenuViewController

enum sec_zero {
   SEC_ZERO_OVERVIEW,
   SEC_ZERO_LIST,
   SEC_ZERO_TAG,
   SEC_ZERO_COUNT
};

enum sec_one {
   SEC_ONE_FEEDBACK,
   SEC_ONE_REFRESH,
   SEC_ONE_COUNT
};

- (id) initWithCoder:(NSCoder *)aDecoder
{
   if (self = [super initWithCoder:aDecoder]) {
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchAll) name:@"fetchAll" object:nil];
   }
   return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
   [super viewDidLoad];

   self.title = NSLocalizedString(@"Milpon", @"");
   self.tableView.scrollEnabled = NO;
   
   CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
   pv = [[ProgressView alloc] initWithFrame:CGRectMake(appFrame.origin.x, appFrame.size.height, appFrame.size.width, 100)];
   pv.tag = PROGRESSVIEW_TAG;
   AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
   [ad.window addSubview:pv];
   
   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

   refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
   UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:app action:@selector(addTask)];
   UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
   UIBarButtonItem *tightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
   tightSpace.width = 20.0f;
   UIBarButtonItem *overviewButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_calendar.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
   UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_list.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
   UIBarButtonItem *tagButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_tag.png"] style:UIBarButtonItemStylePlain target:nil action:nil];

   self.toolbarItems = [NSArray arrayWithObjects:refreshButton, flexibleSpace, overviewButton, tightSpace, listButton, tightSpace, tagButton, flexibleSpace, addButton, nil];
   [self.navigationController setToolbarHidden:NO animated:YES];
   [addButton release];
   [overviewButton release];
   [tightSpace release];
   [flexibleSpace release];
   [refreshButton release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   if (section == 0) return SEC_ZERO_COUNT;
   if (section == 1) return SEC_ONE_COUNT;
   NSAssert(NO, @"not reach here");
   return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"RootMenuCell";

   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
   }

   if (indexPath.section == 0) {
      switch (indexPath.row) {
         case SEC_ZERO_OVERVIEW: {
         cell.textLabel.text =  NSLocalizedString(@"Overview", @"");
         cell.imageView.image = [[[UIImage alloc] initWithContentsOfFile:
                        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_calendar.png"]] autorelease];
         break;
      }
      case SEC_ZERO_LIST: {
         cell.textLabel.text =  NSLocalizedString(@"List", @"");

         cell.imageView.image = [[[UIImage alloc] initWithContentsOfFile:
                        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_list.png"]] autorelease];
         break;
      }
      case SEC_ZERO_TAG: {
         cell.textLabel.text =  NSLocalizedString(@"Tag", @"");
         cell.imageView.image = [[[UIImage alloc] initWithContentsOfFile:
                        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_tag.png"]] autorelease];

         break;
      }
      default:
         break;
      }
   } else {
      switch (indexPath.row) {
      case SEC_ONE_FEEDBACK:
         cell.textLabel.text = NSLocalizedString(@"SendFeedback", @"");
         break;
      case SEC_ONE_REFRESH:
         cell.textLabel.text = NSLocalizedString(@"RefreshAll", @"");
         break;
      default:
         break;
      }
   }

   return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   UIViewController *vc = nil;

   if (indexPath.section == 0) {
      switch (indexPath.row) {
      case SEC_ZERO_OVERVIEW:
         vc = [[OverviewViewController alloc] initWithStyle:UITableViewStylePlain];
         break;
      case SEC_ZERO_LIST: {
         vc = [[TaskCollectionViewController alloc] initWithStyle:UITableViewStylePlain];
         ListTaskCollection *collector = [[ListTaskCollection alloc] init];
         [(TaskCollectionViewController *)vc setCollector:collector];

         //vc.title = @"List";
         UIImageView *iv = [[UIImageView alloc] initWithImage:[[[UIImage alloc] initWithContentsOfFile:
                        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_list.png"]] autorelease]];
         vc.navigationItem.titleView = iv;

         [collector release];
         break;
      }
      case SEC_ZERO_TAG: {
         vc = [[TaskCollectionViewController alloc] initWithStyle:UITableViewStylePlain];
         TagTaskCollection *collector = [[TagTaskCollection alloc] init];
         [(TaskCollectionViewController *)vc setCollector:collector];
         //vc.title = @"Tag";
         UIImageView *iv = [[UIImageView alloc] initWithImage:[[[UIImage alloc] initWithContentsOfFile:
                                                                [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_tag.png"]] autorelease]];
         vc.navigationItem.titleView = iv;

         [collector release];   
         break;
      }
      default:
         break;
      }
   } else {
      switch (indexPath.row) {
      case SEC_ONE_FEEDBACK: {
        // TODO: use in-app mail
        NSString *subject = [NSString stringWithFormat:@"subject=Milpon Feedback"];
        NSString *mailto = [NSString stringWithFormat:@"mailto:mootoh@gmail.com?%@", [subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURL *url = [NSURL URLWithString:mailto];
        [[UIApplication sharedApplication] openURL:url];
        return;
      }
      case SEC_ONE_REFRESH: {
         [self showFetchAllModal];
         return;
      }
      default:
         break;
      }
   }

   NSAssert(vc != nil, @"should be set some ViewController.");

   [self.navigationController pushViewController:vc animated:YES];
   [vc release];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   return section == 0 ? NSLocalizedString(@"Task", @"") : NSLocalizedString(@"More", @"");
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

- (void)dealloc
{
   [super dealloc];
}

#pragma mark Private

- (IBAction) fetchAll
{
   AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   RTMSynchronizer *syncer = [[RTMSynchronizer alloc] init:ad.auth];
   [syncer replaceLists];
   [syncer replaceTasks];
   
   [syncer release];
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   [[NSNotificationCenter defaultCenter] postNotificationName:@"didFetchAll" object:nil];
}

- (BOOL) is_reachable
{
#ifndef LOCAL_DEBUG
   Reachability *reach = [Reachability sharedReachability];
   reach.hostName = @"api.rememberthemilk.com";
   NetworkStatus stat =  [reach internetConnectionStatus];
   reach.networkStatusNotificationsEnabled = NO;
   if (stat == NotReachable) {
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not Connected"
                                                   message:@"Not connected to the RTM site. Sync when you are online."
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
      [av show];
      [av release];
      return NO;
   }
#endif // LOCAL_DEBUG
   return YES;
}

- (IBAction) refresh
{
   if (! [self is_reachable]) return;
   
   refreshButton.enabled = NO;
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   [self showDialog];
   
   [self performSelectorInBackground:@selector(uploadOperation) withObject:nil];
}

- (void) uploadOperation
{
   AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
   RTMSynchronizer *syncer = [[RTMSynchronizer alloc] init:ad.auth];
   
   [syncer uploadPendingTasks:pv];
   [syncer syncModifiedTasks:pv];
   [syncer syncTasks:pv];
   [syncer release];
   
   [self performSelectorOnMainThread:@selector(refreshView) withObject:nil waitUntilDone:YES];
   [self performSelectorOnMainThread:@selector(hideDialog) withObject:nil waitUntilDone:YES];
   [[NSNotificationCenter defaultCenter] postNotificationName:@"didRefresh" object:nil];
}

- (void) refreshView
{
   UIViewController *vc = self.navigationController.topViewController;
   if ([vc conformsToProtocol:@protocol(ReloadableTableViewControllerProtocol)]) {
      UITableViewController<ReloadableTableViewControllerProtocol> *tvc = (UITableViewController<ReloadableTableViewControllerProtocol> *)vc;
      [tvc reloadFromDB];
      [tvc.tableView reloadData];
   }
}

- (void) showFetchAllModal
{
   RefreshingViewController *vc = [[RefreshingViewController alloc] initWithNibName:@"RefreshingViewController" bundle:nil];
   vc.rootMenuViewController = self;
   [self.view.window addSubview:vc.view];
   [vc.view setNeedsDisplay];
}

- (IBAction) showDialog
{
   CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
   pv.alpha = 0.0f;
   pv.backgroundColor = [UIColor blackColor];
   pv.opaque = YES;
   pv.message = @"Syncing...";
   
   // animation part
   [UIView beginAnimations:nil context:NULL]; {
      [UIView setAnimationDuration:0.20f];
      [UIView setAnimationDelegate:self];
      
      pv.alpha = 0.8f;
      pv.frame = CGRectMake(appFrame.origin.x, appFrame.size.height-80, appFrame.size.width, 100);
   } [UIView commitAnimations];
}

- (IBAction) hideDialog
{
   CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
   pv.message = @"Synced.";
   
   // animation part
   [UIView beginAnimations:nil context:NULL]; {
      [UIView setAnimationDuration:0.20f];
      [UIView setAnimationDelegate:self];
      
      pv.alpha = 0.0f;
      pv.frame = CGRectMake(appFrame.origin.x, appFrame.size.height, appFrame.size.width, 100);
   } [UIView commitAnimations];
   
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   refreshButton.enabled = YES;
   AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
   [ad.window setNeedsDisplay];
}

@end
