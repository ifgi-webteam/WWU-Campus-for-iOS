//
//  CPViewController.m
//  CampusPlan
//
//  Created by Benni on 06.02.13.
//  Copyright (c) 2013 Ifgi. All rights reserved.
//

#import "CPViewController.h"
#import "Reachability.h"

static NSString * const kWebAppUrl = @"http://app.uni-muenster.de"; // WebApp URL
static float const kFadeInOutAnimationDuration = 0.3; // Animation Duration for fading in and out

@interface CPViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView; // Shows the WebApp
@property (weak, nonatomic) IBOutlet UITextView *statusTextView; // Shows status messages
@end

@implementation CPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Add an observer to vertically center the status text
	[self.statusTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
	
	// Reachability object for testing of internet connection
	Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
	
	// This block is performed when internet is available
	reachability.reachableBlock = ^(Reachability*reach)
	{
		// Execute on main thread
		dispatch_async(dispatch_get_main_queue(), ^
		{
			// Init the WebApp URL, put it in a request and load the request in the webView
			NSURL *url = [NSURL URLWithString:kWebAppUrl];
			NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
			[self.webView loadRequest:urlRequest];
			
			// Set a meaningful loading message in the status text view
			self.statusTextView.text = NSLocalizedString(@"kInitStatusMessage", @"");
		});
	};
	
	// This block is performed when internet is available
	reachability.unreachableBlock = ^(Reachability*reach)
	{
		// Execute on main thread
		dispatch_async(dispatch_get_main_queue(), ^
		{
			// Animate the webview out and the status text view in
			[UIView animateWithDuration:kFadeInOutAnimationDuration animations:^
			 {
				 self.statusTextView.hidden = NO;
				 self.statusTextView.alpha = 1.0;
				 self.webView.alpha = 0.0;
			 }];
			
			// Set a meaningful loading message in the status text view
			self.statusTextView.text = NSLocalizedString(@"kNoInternetConnection", @"");
		});
	};
	
	[reachability startNotifier];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"contentSize"] && [object isEqual:self.statusTextView])
	{
		// Calculate the new center for the contentOffset
		CGFloat topCorrect = MAX((self.statusTextView.bounds.size.height - self.statusTextView.contentSize.height) / 2.0, 0.0);
		self.statusTextView.contentOffset = CGPointMake(0.0, -topCorrect);
	}
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// Show the network activity indicator in the status bar
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// Hide the network activity indicator in the status bar
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	// Hide the status text view in case its visible and animate the web view in
	[UIView animateWithDuration:kFadeInOutAnimationDuration animations:^
	 {
		 self.webView.alpha = 1.0;
		 self.statusTextView.alpha = 0.0;
	 }completion:^(BOOL finished)
	 {
		 self.statusTextView.hidden = YES;
	 }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// Hide the network activity indicator in the status bar
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		[[UIApplication sharedApplication] openURL:[request URL]];
		
		return NO;
	}
	
	return YES;
}

@end
