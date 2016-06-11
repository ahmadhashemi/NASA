//
//  NSMenuViewController.m
//  NASA
//
//  Created by Ahmad on 6/11/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

#import "NSMenuViewController.h"

#import <SafariServices/SafariServices.h>

@interface NSMenuViewController ()

@end

@implementation NSMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)marsTrekButtonTapped:(UIButton *)sender {
    
    NSString *urlString = @"http://marstrek.jpl.nasa.gov/";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
}

- (IBAction)vestaTrekButtonTapped:(UIButton *)sender {
    
    NSString *urlString = @"http://vestatrek.jpl.nasa.gov/";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
}

@end
