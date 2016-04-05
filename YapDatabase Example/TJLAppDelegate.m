//
//  TJLAppDelegate.m
//  YapDatabase Example
//
//  Created by Terry Lewis II on 2/2/14.
//  Copyright (c) 2014 Blue Plover Productions LLC. All rights reserved.
//

NSString *const TJLTableViewViewName = @"TableViewViewName";
NSString *const TJLTableViewCollectionName = @"TableViewModelCollection";

#import "TJLAppDelegate.h"
#import <YapDatabase/YapDatabase.h>
#import <YapDatabase/YapDatabaseView.h>
#import "TJLTestModel.h"

@implementation TJLAppDelegate
- (YapDatabase *)sharedYapDatabase {
    static YapDatabase *_sharedYapDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedYapDatabase = [[YapDatabase alloc]initWithPath:self.filePath];
        _sharedYapDatabase.connectionPoolLifetime = 2;
    });

    return _sharedYapDatabase;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.database = self.sharedYapDatabase;
    self.databaseView = [self setupDatabaseView];
    [self.database registerExtension:self.databaseView withName:TJLTableViewViewName];
    YapDatabaseConnection *connection = [self.database newConnection];

    [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeAllObjectsInAllCollections];
    }];
    [self writeInDb];
    [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(writeInDb) userInfo:nil repeats:YES];

    return YES;
}

- (void)writeInDb {
    YapDatabaseConnection *connection = [self.database newConnection];

    [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        for(NSInteger i = 0; i < 20; i++) {
            TJLTestModel *model = [[TJLTestModel alloc]
                                   initWithName:[NSString stringWithFormat:@"joe%u", arc4random_uniform(100)]
                                   subtitle:[NSString stringWithFormat:@"bob%u", arc4random_uniform(100)]];
            [transaction
             setObject:model
             forKey:[NSString stringWithFormat:@"%u", i]
             inCollection:TJLTableViewCollectionName];
        }
    }];
}

- (void)writeInDb2 {
    YapDatabaseConnection *connection = [self.database newConnection];

    [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        for(NSInteger i = 0; i < 20; i++) {
            TJLTestModel *model = [[TJLTestModel alloc]
                                   initWithName:[NSString stringWithFormat:@"joe%u", arc4random_uniform(100)]
                                   subtitle:[NSString stringWithFormat:@"bob%u", arc4random_uniform(100)]];
            [transaction
             setObject:model
             forKey:[NSString stringWithFormat:@"%u", i]
             inCollection:TJLTableViewCollectionName];
        }
    }];
}



- (NSString *)filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"database.sqlite"];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (YapDatabaseView *)setupDatabaseView {
    YapDatabaseViewGrouping *viewGrouping = [YapDatabaseViewGrouping withKeyBlock:^NSString * _Nullable(YapDatabaseReadTransaction * _Nonnull transaction, NSString * _Nonnull collection, NSString * _Nonnull key) {
        return @"name";
    }];

    YapDatabaseViewSorting *viewSorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(YapDatabaseReadTransaction * _Nonnull transaction, NSString * _Nonnull group, NSString * _Nonnull collection1, NSString * _Nonnull key1, TJLTestModel *_Nonnull object1, NSString * _Nonnull collection2, NSString * _Nonnull key2, TJLTestModel *_Nonnull object2) {
        NSUInteger minLength = MIN(object1.name.length, object2.name.length);
        return [object1.name compare:object2.name options:NSNumericSearch range:NSMakeRange(0, minLength)];
    }];

//    sortingBlockType = YapDatabaseBlockTypeWithObject;
//    sortingBlock = ^(NSString *group, NSString *collection1, NSString *key1, TJLTestModel *obj1,
//            NSString *collection2, NSString *key2, TJLTestModel *obj2) {
//        return [obj1.name compare:obj2.name options:NSNumericSearch range:NSMakeRange(0, obj1.name.length)];
//    };

    YapDatabaseView *databaseView = [[YapDatabaseView alloc] initWithGrouping:viewGrouping sorting:viewSorting];
    return databaseView;
}

@end
