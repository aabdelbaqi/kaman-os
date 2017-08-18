//
//  EditAccountViewController.h
//  Kaman
//
//  Created by Moin' Victor on 22/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditAccountViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *changeImageButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseImageButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *genderTextfield;
@property (weak, nonatomic) IBOutlet UITextField *dobTextfield;
@end
