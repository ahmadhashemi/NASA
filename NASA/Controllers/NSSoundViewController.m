//
//  NSSoundViewController.m
//  NASA
//
//  Created by Ahmad on 6/11/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

#import "NSSoundViewController.h"

#import "MBProgressHUD.h"

@interface NSSoundViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation NSSoundViewController {
    
    NSArray *dataSource;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    dataSource = [[NSArray alloc] init];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    dataSource = @[];
    [self.tableView reloadData];
    
    [searchBar resignFirstResponder];
    
    NSString *query = searchBar.text;
    
    [self searchForQuery:query];
    
}

-(void)searchForQuery:(NSString *)query {
    
    NSString *apiKey = @"vXGxajHgBEThvpLNOmjPBUs2VghXzxscJf2Uuqm5";
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.nasa.gov/planetary/sounds?q=%@&api_key=%@&limit=30",query,apiKey];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (!error) {
                
                [self handleSoundResponse:data];
                
            } else {
                
                NSLog(@"%@",error.localizedDescription);
                
            }
            
        });
        
    }] resume];
    
}

-(void)handleSoundResponse:(NSData *)data {
    
    NSError *jsonError;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    
    if (jsonError) {
        NSLog(@"JSON Error");
        return;
    }
    
    dataSource = dict[@"results"];
    
    [self.tableView reloadData];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *thisRow = dataSource[indexPath.row];
    
    NSString *urlString = thisRow[@"download_url"];
    
    NSURL *openURL = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] openURL:openURL];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *thisRow = dataSource[indexPath.row];
    
    cell.textLabel.text = thisRow[@"title"];
    id description = thisRow[@"description"];
    if ([description class] != [NSNull class]) {
        cell.detailTextLabel.text = description;
    } else {
        cell.detailTextLabel.text = nil;
    }
    
    return cell;
    
}

@end
