//
//  AddPictureViewController.h
//  PhotoGallery
//
//  Created by Nick Ambrose on 1/22/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AddPictureViewController : UIViewController

@property (nonatomic,weak) IBOutlet UIButton *choosePhotoBut;
@property (nonatomic,weak) IBOutlet UIButton *cancelBut;
@property (nonatomic,weak) IBOutlet UIButton *addBut;
@property (nonatomic,weak) IBOutlet UITextField *captionField;

@property (nonatomic,strong) UIImage *selectedImage;

-(IBAction)doCancel:(id)sender;
-(IBAction)doAdd:(id)sender;
-(IBAction)showCamera:(id)sender;
@end
