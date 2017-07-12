//
//  AppDelegate.h
//  Inside building
//
//  Created by Мария Тимофеева on 22.05.17.
//  Copyright © 2017 Мария Тимофеева. All rights reserved.
//

#import <UIKit/UIKit.h>
@import IndoorAtlas;
@interface AppDelegate : UIResponder <UIApplicationDelegate, IALocationManagerDelegate>
@property (nonatomic, strong) IALocationManager *manager;
@property (strong, nonatomic) UIWindow *window;


@end

