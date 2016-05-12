//
//  MenuViewController.m
//  Kaman
//
//  Created by Moin' Victor on 19/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "MenuViewController.h"
#import "Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ParallaxHeaderView.h"
#import "UIImage+ImageEffects.h"
#import "SWRevealViewController.h"
#import "ProfileViewController.h"
#import "Session.h"

@interface MenuViewController ()

@end
UIImage * originalImage;
@implementation MenuViewController
UIImageView * imageView;
NSArray * menu_icons, *menu_items;
UILabel *nameLabel;
ParallaxHeaderView *headerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    menu_icons = @[@"discovery-prefs",
                   @"settings",
                   @"dancing",
                   @"share",
                   @"rate-star"];
    menu_items = @[@"Discovery Preference",
                   @"App Settings",
                   @"Host A Kaman",
                   @"Share Kaman",
                   @"Rate Us",
                   ];
    
    /*
    UIView * progressHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 180)];
   // [progressHeader setBackgroundColor:MyGreyColor];
    
    UIActivityIndicatorView  *av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    av.center = CGRectMake(round((progressHeader.frame.size.width - 25) / 2), round((progressHeader.frame.size.height - 25) / 2), 25,25);
    av.tag  = 1;
    [progressHeader addSubview:av];
    [av startAnimating];

    self.tableView.tableHeaderView = progressHeader;
     */
    [self setHeaderParallaxView];
    [self setProfile];
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.backgroundColor = MenuBgBlack;
 }


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)setHeaderParallaxView
{
    headerView = [ParallaxHeaderView parallaxHeaderViewWithImage:[UIImage imageNamed:@"login-bg"] forSize:CGSizeMake(300, 180)];;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 50, 64, 64)];
    // ParallaxHeaderView *headerView = [ParallaxHeaderView parallaxHeaderViewWithSubView:imageView];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myProfile:)];
    singleTap.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:singleTap];
    imageView.tag = 1000;
    [Utils setUIView:imageView backgroundColor:MyGreyColor andRoundedByRadius:imageView.frame.size.height/2 withBorderColor:[UIColor whiteColor]];
    
    [imageView setImage:[UIImage imageNamed:@"person"]];
    [headerView addSubview:imageView];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 60, 150, 20)];
    [nameLabel setFont:[UIFont systemFontOfSize:20]];
    [nameLabel setTextColor:[UIColor whiteColor]];
    nameLabel.tag = 1000;
    [headerView addSubview:nameLabel];
    
    UIButton *viewProfileBtn = [[UIButton alloc] initWithFrame:CGRectMake(90, 85, 150, 20)];
    [viewProfileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [viewProfileBtn setTitle:@"View Profile" forState:UIControlStateNormal];
    [viewProfileBtn setBackgroundColor:[UIColor clearColor]];
    viewProfileBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    viewProfileBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    viewProfileBtn.tag = 1000;
    [viewProfileBtn addTarget:self action:@selector(myProfile:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:viewProfileBtn];
    
    [self.tableView setTableHeaderView:headerView];
}

-(void)setProfile
{
    if([[PFUser currentUser] displayName])
        [nameLabel setText:[[PFUser currentUser] displayName]];
    else
        [nameLabel setText:@""];
    
    
    if([[PFUser currentUser] profileImageURL]) {
         [imageView  sd_setImageWithURL:[NSURL URLWithString:[[PFUser currentUser] profileImageURL]]
                      placeholderImage:[UIImage imageNamed:@"person"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 [headerView setHeaderImage:image];
                                 [(ParallaxHeaderView *)self.tableView.tableHeaderView refreshBlurViewForNewImage];
                                 
                                 
                             }];
    } else {
        [imageView setImage:[UIImage imageNamed:@"person"]];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  //  [self setHeaderParallaxView];
    [self setProfile];
    if([self.tableView.tableHeaderView isKindOfClass:[ParallaxHeaderView class]]) {
        [(ParallaxHeaderView *)self.tableView.tableHeaderView refreshBlurViewForNewImage];
        // pass the current offset of the UITableView so that the ParallaxHeaderView layouts the subViews.
        [(ParallaxHeaderView *)self.tableView.tableHeaderView layoutHeaderViewForScrollViewOffset:self.tableView.contentOffset];
    }
    [self.tableView reloadData];
}



#pragma mark UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView && self.tableView.tableHeaderView)
    {
        if([self.tableView.tableHeaderView isKindOfClass:[ParallaxHeaderView class]]) {
            // pass the current offset of the UITableView so that the ParallaxHeaderView layouts the subViews.
            [(ParallaxHeaderView *)self.tableView.tableHeaderView layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
        }
        
      }
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
     UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
      NSLog(@"We are headed for %@",[destViewController class]);
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        /*
        if([segue.identifier isEqualToString:@"my_profile"]) {
            ProfileViewController *destViewController = (ProfileViewController*)segue.destinationViewController;
            destViewController.user = [PFUser currentUser];

        }
        */
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController pushViewController:dvc animated: YES];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
    }
    
}

-(IBAction)myProfile:(id)sender
{
      [self performSegueWithIdentifier:@"my_profile" sender:nil];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"discovery_settings" sender:nil];
            break;
        case 1:
            [self performSegueWithIdentifier:@"app_settings" sender:nil];
            break;
        case 2:
            [self performSegueWithIdentifier:@"go_host_kaman" sender:nil];
            break;
        case 3:
            [self performSegueWithIdentifier:@"go_share" sender:nil];
            break;
        case 4:
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"itms-apps://itunes.com/app/Kaman"]];
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.textLabel.text = [menu_items objectAtIndex:indexPath.row];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [cell.imageView setImage:[UIImage imageNamed:[menu_icons objectAtIndex:indexPath.row]]];
    cell.backgroundColor = MenuBgBlack;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [menu_items count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
