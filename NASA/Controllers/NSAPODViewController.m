//
//  NSAPODViewController.m
//  NASA
//
//  Created by Ahmad on 6/11/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

#import "NSAPODViewController.h"

#import "MBProgressHUD.h"
#import "NYTExamplePhoto.h"
#import "NYTPhotosViewController.h"

@interface NSAPODViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation NSAPODViewController {
    
    NSURLSession *imageURLSession;
    MBProgressHUD *downloadHUD;
    MBProgressHUD *statusHUD;
    
    NSString *imageTitle;
    NSString *imageDescription;
    
}

- (void)viewDidLoad {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    imageURLSession = [NSURLSession sessionWithConfiguration:configuration delegate:(id)self delegateQueue:[NSOperationQueue mainQueue]];
    
    self.datePicker.maximumDate = [NSDate new];
    
    [super viewDidLoad];
    
}

- (IBAction)getButtonTapped:(UIButton *)sender {
    
    NSDate *date = self.datePicker.date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    [self getAPODOfDate:dateString];
    
}

-(void)getAPODOfDate:(NSString *)dateString {
    
    NSString *apiEndpoint = @"https://api.nasa.gov/planetary/apod";
    NSString *apiKey = @"vXGxajHgBEThvpLNOmjPBUs2VghXzxscJf2Uuqm5";
    
    NSString *urlString = [NSString stringWithFormat:@"%@?api_key=%@&date=%@",apiEndpoint,apiKey,dateString];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (!error) {
                
                [self handleAPODResponse:data];
                
            } else {
                
                NSLog(@"%@",error.localizedDescription);
                
            }
            
        });
        
    }] resume];
    
}

-(void)handleAPODResponse:(NSData *)data {
    
    NSError *jsonError;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    
    if (jsonError) {
        NSLog(@"Error in JSON");
        return;
    }
    
    NSString *urlString = dict[@"url"];
    
    if (!urlString) {
        statusHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        statusHUD.mode = MBProgressHUDModeText;
        statusHUD.labelText = @"No photos for this day, yet.";
        [statusHUD hide:YES afterDelay:3];
        return;
    }
    
    imageTitle = dict[@"title"];
    imageDescription = dict[@"explanation"];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    downloadHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    downloadHUD.mode = MBProgressHUDModeAnnularDeterminate;
    
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopDownload:)];
    //[downloadHUD addGestureRecognizer:tap];
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[imageURLSession downloadTaskWithRequest:urlRequest] resume];
    
}

-(void)showDownloadedImage:(NSData *)imageData {
    
    UIImage *image = [UIImage imageWithData:imageData];
    
    NYTExamplePhoto *examplePhoto = [[NYTExamplePhoto alloc] init];
    
    examplePhoto.image = image;
    
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:15]};
    NSDictionary *descriptionAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:13]};
    
    examplePhoto.attributedCaptionTitle = [[NSAttributedString alloc] initWithString:imageTitle attributes:titleAttributes];
    examplePhoto.attributedCaptionSummary = [[NSAttributedString alloc] initWithString:imageDescription attributes:descriptionAttributes];
    
    NYTPhotosViewController *nytPVC = [[NYTPhotosViewController alloc] initWithPhotos:@[examplePhoto]];
    
    [self presentViewController:nytPVC animated:YES completion:nil];
    
}

#pragma mark -

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    downloadHUD.progress = (float)totalBytesWritten/totalBytesExpectedToWrite;
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:location];
    downloadHUD.progress = 0;
    [downloadHUD hide:YES];
    [self showDownloadedImage:imageData];
    
}

@end
