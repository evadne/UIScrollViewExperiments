//
//  UISVRLERootViewController.m
//  UIScrollView-RunLoopExperiments
//
//  Created by Evadne Wu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UISVRLERootViewController.h"


@interface UISVRLERootViewController ()

@property (nonatomic, readwrite, assign) CFRunLoopObserverRef rlObserver;

- (void) scheduleRefresh;

@end

@implementation UISVRLERootViewController
@dynamic tableView;
@synthesize rlObserver;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (!self)
		return nil;

	self.rlObserver = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
	
#if 1
	
		NSLog(@"Run loop activity %lu (%@)", activity, ((^ (CFRunLoopActivity anActivity) {

			switch (anActivity) {
				
				case kCFRunLoopEntry:
					return @"kCFRunLoopEntry";
				
				case kCFRunLoopBeforeTimers:
					return @"kCFRunLoopBeforeTimers";
				
				case kCFRunLoopBeforeSources:
					return @"kCFRunLoopBeforeSources";
				
				case kCFRunLoopBeforeWaiting:
					return @"kCFRunLoopBeforeWaiting";
				
				case kCFRunLoopAfterWaiting:
					return @"kCFRunLoopAfterWaiting";
				
				case kCFRunLoopExit:
					return @"kCFRunLoopExit";
				
				case kCFRunLoopAllActivities:
					return @"kCFRunLoopAllActivities";
			
			};
			
			return @"(Unknown)";
		
		})(activity)));

#endif
		
	});

	CFRunLoopAddObserver(CFRunLoopGetMain(), self.rlObserver, kCFRunLoopDefaultMode);
	
	[self scheduleRefresh];
	
	return self;

}

- (void) scheduleRefresh {

	//	This is the old way, things are done on main queue but not always when it’s appropriate
	//	Let’s simulate network operation
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^ {
	
		CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopDefaultMode, ^{
		
			if (![self isViewLoaded])
				return;
			
			[self.tableView reloadData];
			
			NSLog(@"back to default mode, time to do work");
			
		});
		
		[self scheduleRefresh];
			
	});

}

- (void) dealloc {

	if (rlObserver) {
	
		CFRunLoopRemoveObserver(CFRunLoopGetMain(), rlObserver, kCFRunLoopDefaultMode);
		CFRunLoopObserverInvalidate(rlObserver);
		rlObserver = nil;
	
	}

}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {

	NSLog(@"%s %@", __PRETTY_FUNCTION__, scrollView);

}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return 200;

}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
	
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	
	}
	
	cell.textLabel.text = [indexPath description];
	
	return cell;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
