
//Created by Atchu on 1/14/15.
//  Copyright (c) 2014 Clamour. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol CLPopListViewDelegate;
@interface CLPopListView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<CLPopListViewDelegate> delegate;
@property (copy, nonatomic) void(^handlerBlock)(NSInteger anIndex);
@property (nonatomic) BOOL allowScroll;
@property (nonatomic, readwrite) int selectedIndex;
@property (strong, nonatomic) NSMutableArray *selectedItems;
@property (strong, nonatomic) NSMutableArray *optionsArry;
// The options is a NSArray, contain some NSDictionaries, the NSDictionary contain 2 keys, one is "img", another is "text".
-(id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions;
-(id)initWithTitle:(NSString *)aTitle
            options:(NSArray *)aOptions
            handler:(void (^)(NSInteger))aHandlerBlock;

// If animated is YES, PopListView will be appeared with FadeIn effect.
-(void)showInView:(UIView *)aView animated:(BOOL)animated;
@end

@protocol CLPopListViewDelegate <NSObject>
-(void)leveyPopListView:(CLPopListView *)popListView didSelectedIndex:(NSInteger)anIndex;
@optional
-(void)leveyPopListViewDidCancel;
@end