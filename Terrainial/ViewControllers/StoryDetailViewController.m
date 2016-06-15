//
//  StoryDetailViewController.m
//  Terennial
//
//  Created by student on 2/5/16.
//  Copyright © 2016 NMIL. All rights reserved.
//

#import "StoryDetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIImageView+AFNetworking.h>
#import "CNDataAccess.h"
#import "GCSVideoView.h"
#import "RoundGradientButton.h"
#import "Utils.h"
#import "AppDelegate.h"

@interface StoryDetailViewController ()<GCSVideoViewDelegate>
{
    GCSVideoView *_videoView;
    BOOL _isPaused;
    BOOL _shouldStop;
    BOOL _stopPlaying;
    AppDelegate *appDelegate;
}

@property (weak, nonatomic) IBOutlet UIView *videoSpaceView;
@property (weak, nonatomic) IBOutlet UIImageView *storyDetailImage;
@property (weak, nonatomic) IBOutlet UILabel *detailTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdByLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet RoundGradientButton *playButton;
@property (weak, nonatomic) IBOutlet RoundGradientButton *streamButton;
@property (weak, nonatomic) IBOutlet RoundGradientButton *downloadButton;
@property (weak, nonatomic) IBOutlet UILabel *videoSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet RoundGradientButton *playBtn;
@property (weak, nonatomic) IBOutlet RoundGradientButton *deleteBtn;

@end

@implementation StoryDetailViewController

#pragma mark - View Life cycle

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeVideoFromSuperView];
    self.story = nil;
    appDelegate.disableRotation=NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.title = @"Cronkite VR";
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self displayArticleContent];
    [self.view setNeedsLayout];
    self.progressView.hidden = YES;
    
    if (![self didFileExist]) {
        [self disablePlayAndDeleteBtn];
    }
    
    else{
        [self disableStreamAndDownloadBtn];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    appDelegate.disableRotation=YES;
}

#pragma mark - Disk space utils

-(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue]-(500*1024ll*1024ll);
//        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
//        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace/1024ll/1024ll;
}

- (uint64_t)freeDiskspace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    
    __autoreleasing NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue]-(500*1024ll*1024ll);
//        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
//        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}

#pragma mark - NSFileManager utils

- (NSURL *)documentsDirectoryURL
{
    NSError *error = nil;
    NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                        inDomain:NSUserDomainMask
                                               appropriateForURL:nil
                                                          create:NO
                                                           error:&error];
    if (error) {
        // Figure out what went wrong and handle the error.
    }
    
    return url;
}

-(NSString *)extractFileNameFromURL
{
    NSURL *url = [NSURL URLWithString:self.story.videoURL];
    NSString *filename = [[url path] lastPathComponent];
    return filename;
}

-(BOOL)removeFileFromPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename = [self extractFileNameFromURL];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError *error;
    
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        return success;
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    return NO;
}

-(BOOL)didFileExist
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *path = [self extractFileNameFromURL];
    NSString* foofile = [documentsPath stringByAppendingPathComponent:path];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
    return fileExists;
}

#pragma mark - Custom event handling

-(void)removeVideoFromSuperView
{
    if (_videoView) {
        [_videoView removeFromSuperview];
        _videoView=nil;
    }
}

-(void)disablePlayAndDeleteBtn
{
    self.playBtn.hidden = YES;
    self.deleteBtn.hidden = YES;
    self.streamButton.hidden = NO;
    self.downloadButton.hidden = NO;
}

-(void)disableStreamAndDownloadBtn
{
    self.streamButton.hidden = YES;
    self.downloadButton.hidden = YES;
    self.playBtn.hidden = NO;
    self.deleteBtn.hidden = NO;
}

-(void)enableAllButtons
{
    if (![self didFileExist]) {
        self.streamButton.hidden = NO;
        self.downloadButton.hidden = NO;

    }
    
    else{
        self.playBtn.hidden = NO;
        self.deleteBtn.hidden = NO;
    }
    
    
    self.durationLabel.hidden=NO;
    self.videoSizeLabel.hidden=NO;
}

-(void)disableAllButtons
{
    if (![self didFileExist]) {
        self.streamButton.hidden = YES;
        self.downloadButton.hidden = YES;
        
    }
    
    else{
        self.playBtn.hidden = YES;
        self.deleteBtn.hidden = YES;
    }
    
    self.durationLabel.hidden=YES;
    self.videoSizeLabel.hidden=YES;
}

-(void)displayArticleContent{
    NSURL *url = [NSURL URLWithString:self.story.imageURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    UIImage *placeholderImage = [UIImage imageNamed:@"cronkite"];
    self.storyDetailImage.image = placeholderImage;
    
    [self.storyDetailImage setImageWithURLRequest:request
                                 placeholderImage:placeholderImage
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              
                                              self.storyDetailImage.image = image;
                                              [self.view setNeedsLayout];
                                              
                                          } failure:nil];
    
    
    
    self.detailTitleLabel.text = self.story.title;
    //    self.createdByLabel.text = self.storyDetailDict[@""];
    self.detailDescriptionLabel.text = self.story.longDescription;
    self.durationLabel.text = [NSString stringWithFormat:@"%@ m",self.story.duration];
    self.videoSizeLabel.text = [NSString stringWithFormat:@"%@ MB",self.story.videoSize];
    [self.playButton newButton];
    [self.streamButton newButton];
    [self.downloadButton newButton];
    [self.playBtn newButton];
    [self.deleteBtn newButton];
    
    _shouldStop = YES;
    //    [_videoView loadFromUrl:[[NSURL alloc] initFileURLWithPath:videoPath]];
}

-(void)getLatestStories
{
    CNDataAccess *dataAccess = [CNDataAccess sharedInstance];
    [dataAccess getCurrentCronkiteNewsInURL:[NSURL URLWithString:CRONKITENEWS_URL] success:^(StoriesModel *stories) {
        
        self.story = stories.articles[0];
        [self displayArticleContent];
        [self.view setNeedsLayout];
        //        [self.storiesTableView reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"Error : %@",error.localizedDescription);
    }];
    
}


-(void)downloadImage
{
    // Use the default session configuration for the manager (background downloads must use the delegate APIs)
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // Use AFNetworking's NSURLSessionManager to manage a NSURLSession.
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // Create the image URL from some known string.
//    NSURL *imageURL = [NSURL URLWithString:@"http://www.google.com/images/srpr/logo3w.png"];
    NSURL *imageURL = [NSURL URLWithString:self.story.videoURL];
    // Create a request object for the given URL.
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    // Create a pointer for a NSProgress object to be used to determining download progress.
    NSProgress *progress;
    
    // Create the callback block responsible for determining the location to save the downloaded file to.
    NSURL *(^destinationBlock)(NSURL *targetPath, NSURLResponse *response) = ^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        // Get the path of the application's documents directory.
        NSURL *documentsDirectoryURL = [self documentsDirectoryURL];
        NSURL *saveLocation = nil;
        
        // Check if the response contains a suggested file name
        if (response.suggestedFilename) {
            // Append the suggested file name to the documents directory path.
            saveLocation = [documentsDirectoryURL URLByAppendingPathComponent:response.suggestedFilename];
        } else {
            // Append the desired file name to the documents directory path.
            saveLocation = [documentsDirectoryURL URLByAppendingPathComponent:@"AFNetworking.png"];
        }
        
        return saveLocation;
    };
    
    // Create the completion block that will be called when the image is done downloading/saving.
    void (^completionBlock)(NSURLResponse *response, NSURL *filePath, NSError *error) = ^void (NSURLResponse *response, NSURL *filePath, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // There is no longer any reason to observe progress, the download has finished or cancelled.
            [progress removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
            [self.progressView setProgress:1.0f];
            [self.progressView setHidden:YES];
            
            if (error) {
                NSLog(@"%@",error.localizedDescription);
                // Something went wrong downloading or saving the file. Figure out what went wrong and handle the error.
            } else {
                // Get the data for the image we just saved.
                _shouldStop=NO;
                [self disableStreamAndDownloadBtn];
            }
        });
    };
    
        if ([self freeDiskspace] > [self.story.videoSize intValue]) {
            self.progressView.hidden = NO;
            NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
                [self.progressView setProgress:downloadProgress.fractionCompleted];
                
//                NSLog(@"Progress : %@",downloadProgress.localizedDescription);
            } destination:destinationBlock completionHandler:completionBlock];
            
            // Start the download task.
            [task resume];
            
            // Begin observing changes to the download task's progress to display to the user.
            [progress addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
        }
        
        else{
            [Utils alertWithTitle:@"Error" message:@"No Free Space Available. Please free up some space and try again." cancelButton:@"OK"];
        }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // We only care about updates to fractionCompleted
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))]) {
        NSProgress *progress = (NSProgress *)object;
        // localizedDescription gives a string appropriate for display to the user, i.e. "42% completed"
        self.progressLabel.text = progress.localizedDescription;
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - GCSVideoViewDelegate

- (void)widgetViewDidTap:(GCSWidgetView *)widgetView {
    if (_isPaused) {
        [_videoView resume];
    } else {
        [_videoView pause];
    }
    _isPaused = !_isPaused;
}

- (void)videoView:(GCSVideoView*)videoView didUpdatePosition:(NSTimeInterval)position {
    // Rewind to beginning of the video when it reaches the end.
    if (position == videoView.duration) {
        _isPaused = YES;
        [_videoView seekTo:0];
    }
}

#pragma mark - Button event handling

-(void)addVideoView
{
    _videoView = [[GCSVideoView alloc]
                  initWithFrame:CGRectMake(0, 0, self.videoSpaceView.bounds.size.width, self.videoSpaceView.bounds.size.height)];
    _videoView.delegate = self;
    _videoView.enableFullscreenButton = YES;
    _videoView.enableCardboardButton = YES;
    
    [self.videoSpaceView addSubview:_videoView];
    _isPaused = YES;
}

- (IBAction)streamBtnlicked:(id)sender {
    
    if (_shouldStop) {
        appDelegate.disableRotation = NO;
        [self addVideoView];
        
        NSString *videoPath = self.story.videoURL;
        [_videoView loadFromUrl:[NSURL URLWithString:videoPath]];
        [_streamButton setTitle:@"Stop" forState:UIControlStateNormal];
        _shouldStop = NO;
    }
    
    else{
        appDelegate.disableRotation = YES;
        _shouldStop = YES;
        
        [self removeVideoFromSuperView];
        
        [_streamButton setTitle:@"Stream" forState:UIControlStateNormal];
    }
    
}

- (IBAction)downloadBtnClicked:(id)sender {
    
    if ([self freeDiskspace] > [self.story.videoSize intValue]) {
        [self downloadImage];
    }
    
    else{
        [Utils alertWithTitle:@"Error" message:@"No Free Space Available. Please free up some space and try again." cancelButton:@"OK"];
    }
    
}

- (IBAction)playBtnClicked:(id)sender {
    
    if(_stopPlaying)
    {
        appDelegate.disableRotation = YES;
        _stopPlaying = NO;
        
        [self removeVideoFromSuperView];
        
        [_playBtn setTitle:@"Play" forState:UIControlStateNormal];
    }
    
    else
    {
        appDelegate.disableRotation = NO;
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *path = [self extractFileNameFromURL];
        NSString* foofile = [documentsPath stringByAppendingPathComponent:path];
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
        
        if(fileExists)
        {
            [self addVideoView];
            
            NSString *path = [self extractFileNameFromURL];
            NSURL *endURL = [[self documentsDirectoryURL] URLByAppendingPathComponent:path];
            
            [_videoView loadFromUrl:endURL];
            [_playBtn setTitle:@"Stop" forState:UIControlStateNormal];
            _stopPlaying = YES;
        }
        
    }
    
}

- (IBAction)deleteBtnClicked:(id)sender {
    [self removeFileFromPath];
    [self disablePlayAndDeleteBtn];
}

#pragma mark - View Layout handling events

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    _videoView.frame = CGRectMake(0,
                                  0,
                                  CGRectGetWidth(self.view.bounds),
                                  self.videoSpaceView.bounds.size.height);
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // do something before rotation
    if (toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation==UIInterfaceOrientationLandscapeRight) {
            [self disableAllButtons];
    }
    
    else{
        [self enableAllButtons];
        
    }
}

#pragma mark - Memory warning handling events

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
