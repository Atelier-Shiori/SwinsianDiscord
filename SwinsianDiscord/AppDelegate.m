//
//  AppDelegate.m
//  SwinsianDiscord
//
//  Created by 小鳥遊六花 on 6/12/18.
//  Copyright © 2018 Moy IT Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import "DiscordManager.h"
#import "PFAboutWindowController.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSMenuItem *togglerichpresence;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong) NSStatusItem *statusItem;
@property (strong) NSImage *statusImage;
@property (strong) DiscordManager *dm;
@property (strong) PFAboutWindowController *aboutWindowController;
@end

@implementation AppDelegate

+ (void)initialize
{
    //Create a Dictionary
    NSMutableDictionary * defaultValues = [NSMutableDictionary dictionary];
    
    // Defaults
    defaultValues[@"startrichpresence"] = @NO;
    //Register Dictionary
    [[NSUserDefaults standardUserDefaults]
     registerDefaults:defaultValues];
}

- (void) awakeFromNib {
    
    //Create the NSStatusBar and set its length
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    //Allocates and loads the images into the application which will be used for our NSStatusItem
    _statusImage = [NSImage imageNamed:@"menubaricon"];
    
    //Yosemite Dark Menu Support
    [_statusImage setTemplate:YES];
    
    //Sets the images in our NSStatusItem
    _statusItem.image = _statusImage;
    
    //Tells the NSStatusItem what menu to load
    _statusItem.menu = _statusMenu;
    
    //Sets the tooptip for our item
    [_statusItem setToolTip:NSLocalizedString(@"SwinsainDiscord",nil)];
    
    //Enables highlighting
    [_statusItem setHighlightMode:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.dm = [DiscordManager new];
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"startrichpresence"]) {
        [_dm startDiscordRPC];
        _togglerichpresence.title = @"Stop Rich Presence";
    }
    
    // Set Notification center
    NSDistributedNotificationCenter *center =
    [NSDistributedNotificationCenter defaultCenter];
    [center addObserver: self
               selector: @selector(trackPlaying:)
                   name: @"com.swinsian.Swinsian-Track-Playing"
                 object: nil];
    [center addObserver: self
               selector: @selector(trackPaused:)
                   name: @"com.swinsian.Swinsian-Track-Paused"
                 object: nil];
    [center addObserver: self
               selector: @selector(trackStopped:)
                   name: @"com.swinsian.Swinsian-Track-Stopped"
                 object: nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)showabout:(id)sender {
    // Properly show the about window in a menu item application
    [NSApp activateIgnoringOtherApps:YES];
    if (!_aboutWindowController) {
        _aboutWindowController = [PFAboutWindowController new];
    }
    (self.aboutWindowController).appURL = [[NSURL alloc] initWithString:@"https://malupdaterosx.moe/hachidori/"];
    NSMutableString *copyrightstr = [NSMutableString new];
    NSDictionary *bundleDict = [NSBundle mainBundle].infoDictionary;
    [copyrightstr appendFormat:@"%@",bundleDict[@"NSHumanReadableCopyright"]];
    (self.aboutWindowController).appCopyright = [[NSAttributedString alloc] initWithString:copyrightstr
                                                                                attributes:@{
                                                                                             NSForegroundColorAttributeName:[NSColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f],
                                                                                             NSFontAttributeName:[NSFont fontWithName:[NSFont systemFontOfSize:12.0f].familyName size:11]}];
    
    [self.aboutWindowController showWindow:nil];
}

- (IBAction)togglerichpresence:(id)sender {
    if (_dm.getStarted) {
        [_dm shutdownDiscordRPC];
        _togglerichpresence.title = @"Start Rich Presence";
    }
    else {
        [_dm startDiscordRPC];
        _togglerichpresence.title = @"Stop Rich Presence";
    }
}
- (void)trackPlaying:(NSNotification *)myNotification {
    if (_dm.getStarted) {
        NSDictionary *userInfo = myNotification.userInfo;
        [self.dm UpdatePresence:[NSString stringWithFormat:@"by %@ \n- %@",userInfo[@"artist"],userInfo[@"album"]] withDetails:userInfo[@"title"]];
    }
    
}
- (void)trackPaused:(NSNotification *)myNotification {
    if (_dm.getStarted) {
        NSDictionary *userInfo = myNotification.userInfo;
        [self.dm UpdatePresence:[NSString stringWithFormat:@"by %@ \n-  %@",userInfo[@"artist"],userInfo[@"album"]] withDetails:userInfo[@"title"]];
    }
}
- (void)trackStopped:(NSNotification *)myNotification {
    if (_dm.getStarted) {
        [_dm removePresence];
    }
}
@end
