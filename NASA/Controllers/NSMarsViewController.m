//
//  NSMarsViewController.m
//  NASA
//
//  Created by Ahmad on 6/12/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

#import "NSMarsViewController.h"
#import "NSMarsPhotosViewController.h"

@interface NSMarsViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation NSMarsViewController {
    
    NSDictionary *cameras;
    
    NSString *dateString;
    NSString *selectedCamera;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.datePicker.maximumDate = [NSDate new];
    
    cameras = @{
                @"Front Hazard Avoidance Camera" : @"FHAZ",
                @"Rear Hazard Avoidance Camera" : @"RHAZ",
                @"Mast Camera" : @"MAST",
                @"Chemistry and Camera Complex" : @"CHEMCAM",
                @"Mars Hand Lens Imager" : @"MAHLI",
                @"Mars Descent Imager" : @"MARDI",
                @"Navigation Camera" : @"NAVCAM"
                };
    
}

- (IBAction)getButtonTapped:(UIButton *)sender {
    
    NSDate *date = self.datePicker.date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    
    dateString = [dateFormatter stringFromDate:date];
    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera" message:@"Select one of the cameras to see photos of it" preferredStyle:UIAlertControllerStyleActionSheet];
//    
//    for (NSString *title in cameras.allKeys) {
//        
//        [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            
//            selectedCamera = [cameras[title] lowercaseString];
//            [self getListOfPhotos];
//            
//        }]];
//        
//    }
//    
//    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
//    
//    [self presentViewController:alert animated:YES completion:nil];
    
    [self getListOfPhotos];
    
}

-(void)getListOfPhotos {
    
    NSMarsPhotosViewController *photosVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotosVC"];
    
    NSString *apiKey = @"vXGxajHgBEThvpLNOmjPBUs2VghXzxscJf2Uuqm5";
    
    //photosVC.urlString = [NSString stringWithFormat:@"https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?earth_date=%@&camera=%@&api_key=%@",dateString,selectedCamera,apiKey];
    photosVC.urlString = [NSString stringWithFormat:@"https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?earth_date=%@&api_key=%@",dateString,apiKey];
    
    [self.navigationController pushViewController:photosVC animated:YES];
    
}


@end
