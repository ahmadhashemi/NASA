//
//  NSMarsPhotosViewController.m
//  NASA
//
//  Created by Ahmad on 6/12/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

#import "NSMarsPhotosViewController.h"

#import "MBProgressHUD.h"
#import "NYTExamplePhoto.h"
#import "NYTPhotosViewController.h"

@interface NSMarsPhotosViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NSMarsPhotosViewController {
    
    NSArray *dataSource;
    
    NSURLSession *imageURLSession;
    MBProgressHUD *downloadHUD;
    MBProgressHUD *failHUD;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    imageURLSession = [NSURLSession sessionWithConfiguration:configuration delegate:(id)self delegateQueue:[NSOperationQueue mainQueue]];
    
    [self fillDataSource];
    
}

-(void)fillDataSource {
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (!error) {
                
                [self handlePhotosResponse:data];
                
            } else {
                
                NSLog(@"%@",error.localizedDescription);
                
            }
            
        });
        
    }] resume];

    
}

-(void)handlePhotosResponse:(NSData *)data {
    
    NSError *jsonError;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    
    if (jsonError) {
        NSLog(@"JSON Error");
        return;
    }
    
    dataSource = dict[@"photos"];
    
    if (dataSource.count == 0) {
        failHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        failHUD.mode = MBProgressHUDModeText;
        failHUD.labelText = @"No photos for this day, yet.";
        [failHUD hide:YES afterDelay:3];
    }
    
    [self.tableView reloadData];
    
}

-(void)showDownloadedImage:(NSData *)imageData {
    
    UIImage *image = [UIImage imageWithData:imageData];
    
    NYTExamplePhoto *examplePhoto = [[NYTExamplePhoto alloc] init];
    
    examplePhoto.image = image;
    
    NYTPhotosViewController *nytPVC = [[NYTPhotosViewController alloc] initWithPhotos:@[examplePhoto]];
    
    [self presentViewController:nytPVC animated:YES completion:nil];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *thisRow = dataSource[indexPath.row];
    
    NSString *title = [thisRow[@"img_src"] lastPathComponent];
    cell.textLabel.text = title;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *thisRow = dataSource[indexPath.row];
    
    NSString *urlString = thisRow[@"img_src"];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    downloadHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    downloadHUD.mode = MBProgressHUDModeAnnularDeterminate;
    
    [[imageURLSession downloadTaskWithRequest:urlRequest] resume];
    
}

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
