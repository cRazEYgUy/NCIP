#import "NCIPViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>

NSBundle *bundle = nil;

@implementation NCIPViewController

+ (void)initialize {
	bundle = [[NSBundle bundleForClass:self.class] retain];
}

- (void)loadView {
	[super loadView];

	/*
	 Set up UI here. Called when SpringBoard is launching.
	 Access resources from your bundle via the private method
	 +[UIImage imageNamed:inBundle:], passing in the bundle
	 variable set above.
	*/
    //self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];

	self.ipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,40)];
	self.ipLabel.textColor = [UIColor whiteColor];
	self.ipLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
	self.ipLabel.textAlignment = NSTextAlignmentCenter;
	self.ipLabel.adjustsFontSizeToFitWidth = NO;
	self.ipLabel.numberOfLines = 2;
	self.ipLabel.backgroundColor = [UIColor clearColor];

	if ([self fetchSSIDInfo]) {
        if (![[self getIPAddress] isEqualToString:@"error"])
        {
            self.ipLabel.text = [NSString stringWithFormat:@"%@    %@",(NSString *)[self fetchSSIDInfo],[self getIPAddress]];
        } else {
            self.ipLabel.text = [NSString stringWithFormat:@"%@    Not Connected",(NSString *)[self fetchSSIDInfo]];
        }
    } else {
        self.ipLabel.text = @"No WiFi";
    }
    
	[self.view addSubview:self.ipLabel];
}

- (CGSize)preferredViewSize {
	// Provide a height by modifying the second parameter.
	return CGSizeMake([super preferredViewSize].width, 50.f);
}

- (void)hostDidPresent {
	[super hostDidPresent];
	// Notification Center was opened.
    if ([self fetchSSIDInfo]) {
        if (![[self getIPAddress] isEqualToString:@"error"])
        {
            self.ipLabel.text = [NSString stringWithFormat:@"%@    %@",(NSString *)[self fetchSSIDInfo],[self getIPAddress]];
        } else {
            self.ipLabel.text = [NSString stringWithFormat:@"%@    Not Connected",(NSString *)[self fetchSSIDInfo]];
        }
    } else {
        self.ipLabel.text = @"No WiFi";
    }
	//self.ipLabel.text = [NSString stringWithFormat:@"%@    %@",(NSString *)[self fetchSSIDInfo],[self getIPAddress]];
}

- (void)hostDidDismiss {
	[super hostDidDismiss];
	// Notification Center was closed.
}

- (NSString *)getIPAddress {

    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];

                }

            }

            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;

}

- (id)fetchSSIDInfo
{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    //NSDictionary *info = (NSDictionary *)CNCopyCurrentNetworkInfo((CFStringRef)[ifs objectAtIndex:0]);
    return [(NSDictionary *)CNCopyCurrentNetworkInfo((CFStringRef)[ifs objectAtIndex:0]) valueForKey:@"SSID"];
    /*for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        if (info && [info count]) {
            break;
        }
        [info release];
    }*/
    [ifs release];
    //return [info autorelease];
}

@end
