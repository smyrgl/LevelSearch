//
//  TGNewRecipeViewController.m
//  LevelSearchExample
//
//  Created by John Tumminaro on 4/13/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import "LSNewRecipeViewController.h"
#import "LSAppDelegate.h"
#import "Recipe.h"

@interface LSNewRecipeViewController ()

@property (nonatomic, weak) NSManagedObjectContext *context;

@end

@implementation LSNewRecipeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LSAppDelegate *delegate = (LSAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = delegate.managedObjectContext;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.nameField.text = @"";
    self.descriptionField.text = @"";
    self.ingredientsField.text = @"";
    self.saveButton.enabled = NO;
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonClick:(id)sender
{
    NSLog(@"Did click save button");
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recipe"];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", self.nameField.text];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
    request.sortDescriptors = @[sort];
    
    NSError *error;
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else if (results.count > 0) {
        NSLog(@"Recipe already exists");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Recipe with that name already exists" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        Recipe *newRecipe = [NSEntityDescription insertNewObjectForEntityForName:@"Recipe" inManagedObjectContext:self.context];
        newRecipe.name = self.nameField.text;
        newRecipe.recipeDescription = self.descriptionField.text;
        newRecipe.ingredients = self.ingredientsField.text;
        
        NSError *saveError;
        [self.context save:&saveError];
        if (saveError) {
            NSLog(@"Error saving %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            NSLog(@"New recipe saved");
            [self performSegueWithIdentifier:@"unwindToList" sender:self];
        }
    }
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.nameField.text.length > 0 && self.descriptionField.text.length > 0 && self.ingredientsField.text.length > 0) {
        self.saveButton.enabled = YES;
    } else {
        self.saveButton.enabled = NO;
    }
    
    return YES;
}

@end
