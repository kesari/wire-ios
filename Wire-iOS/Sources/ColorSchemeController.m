// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


#import "ColorSchemeController.h"
#import "ColorScheme.h"
#import "Settings.h"
#import "zmessaging+iOS.h"
#import "CASStyler+Variables.h"
#import "UIColor+WAZExtensions.h"



NSString * const ColorSchemeControllerDidApplyColorSchemeChangeNotification = @"ColorSchemeControllerDidApplyColorSchemeChangeNotification";



@interface ColorSchemeController () <ZMUserObserver>

@property (nonatomic) id <ZMUserObserverOpaqueToken> userObserverToken;

@end

@implementation ColorSchemeController


#pragma mark - SettingsColorSchemeDidChangeNotification

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [ZMUser removeUserObserverForToken:self.userObserverToken];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.userObserverToken = [ZMUser addUserObserver:self forUsers:@[[ZMUser selfUser]] inUserSession:[ZMUserSession sharedSession]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsColorSchemeDidChange:) name:SettingsColorSchemeChangedNotification object:nil];
    }
    
    return self;
}

- (void)notifyColorSchemeChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ColorSchemeControllerDidApplyColorSchemeChangeNotification object:self];
}

#pragma mark - ZMUserObserver

- (void)userDidChange:(UserChangeInfo *)note
{
    if (! note.accentColorValueChanged) {
        return;
    }
    
    [[CASStyler defaultStyler] applyDefaultColorSchemeWithAccentColor:[UIColor accentColor]];
    [self notifyColorSchemeChange];
}

#pragma mark - SettingsColorSchemeDidChangeNotification

- (void)settingsColorSchemeDidChange:(NSNotification *)notification
{
    [[CASStyler defaultStyler] applyDefaultColorSchemeWithVariant:(ColorSchemeVariant)[[Settings sharedSettings] colorScheme]];
    [self notifyColorSchemeChange];
}

@end