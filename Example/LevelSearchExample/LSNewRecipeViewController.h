//
//  TGNewRecipeViewController.h
//  LevelSearchExample
//
//  Created by John Tumminaro on 4/13/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSNewRecipeViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionField;
@property (weak, nonatomic) IBOutlet UITextField *ingredientsField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)saveButtonClick:(id)sender;

@end
