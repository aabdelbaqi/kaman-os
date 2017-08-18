//
//  TermsViewController.m
//  Say-QR
//
//  Created by Moin' Victor on 03/11/2015.
//  Copyright © 2015 SayMed. All rights reserved.
//

#import "TermsViewController.h"

@interface TermsViewController ()

@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:
     MyOrangeColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
     self.view.backgroundColor = MyBrownColor;
    
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Terms & Conditions"];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Close"
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(exit:)];
    [cancelBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = cancelBtn;

    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:self.showCommercial ? @"terms_commercial" :  @"terms" ofType:@"html"]];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(IBAction)exit:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
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
