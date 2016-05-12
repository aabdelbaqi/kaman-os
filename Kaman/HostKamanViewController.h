//
//  HostKamanViewController.h
//  Kaman
//
//  Created by Moin' Victor on 12/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import "AutocompletionTableView.h"

#define kOFFSET_FOR_KEYBOARD 80.0

@interface HostKamanViewController : UIViewController <UIActionSheetDelegate,UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, AutocompletionTableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet TextFieldValidator *nameTextField;
@property (weak, nonatomic) IBOutlet TextFieldValidator *dateTextField;
@property (weak, nonatomic) IBOutlet TextFieldValidator *timeTextField;
@property (weak, nonatomic) IBOutlet TextFieldValidator *areaTextField;
@property (weak, nonatomic) IBOutlet TextFieldValidator *addressTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;

@property (weak, nonatomic) IBOutlet UIButton *imageSetButton1;
@property (weak, nonatomic) IBOutlet UIButton *imageSetButton2;
@property (weak, nonatomic) IBOutlet UIButton *imageSetButton3;
@property (weak, nonatomic) IBOutlet UIButton *imageSetButton4;


@property (weak, nonatomic) IBOutlet UIButton *imageClearButton1;
@property (weak, nonatomic) IBOutlet UIButton *imageClearButton2;
@property (weak, nonatomic) IBOutlet UIButton *imageClearButton3;
@property (weak, nonatomic) IBOutlet UIButton *imageClearButton4;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

//Add Outlet
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *descTextViewHeightConstraint;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *imageView1HeightConstraint;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *imageView2HeightConstraint;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *imageView3HeightConstraint;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *imageView4HeightConstraint;

@property (nonatomic) PFObject *kaman;
@end
