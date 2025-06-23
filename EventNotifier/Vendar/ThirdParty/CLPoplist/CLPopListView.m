
//  Created by Atchu on 1/14/15.
//  Copyright (c) 2014 Clamour. All rights reserved.
//

#import "CLPopListView.h"
#import "CLPopListTableViewCell.h"

#define POPLISTVIEW_SCREENINSET 40.
#define POPLISTVIEW_HEADER_HEIGHT 50.
#define RADIUS 5.
#define POPUPHEIGHT 150

@interface CLPopListView (private)
- (void)fadeIn;
- (void)fadeOut;
@end

@implementation CLPopListView {
    UITableView *_tableView;
    NSString *_title;
    NSArray *_options;
}

@synthesize allowScroll;
@synthesize selectedIndex;

#pragma mark - initialization & cleaning up
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions {
    CGRect rect = [[UIScreen mainScreen] applicationFrame]; // portrait bounds
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        rect.size = CGSizeMake(rect.size.height, rect.size.width);
    }
    if (self = [super initWithFrame:rect]) {
        if(self.frame.origin.y == 20) {
            CGRect frame = self.frame;
            frame.origin.y = 0;
            frame.size.height = frame.size.height + 20;
            self.frame = frame;
        }
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
        _title = [aTitle copy];
        _options = [aOptions copy];
        self.selectedItems=[NSMutableArray array];
        self.optionsArry=[NSMutableArray array];
        int height = [_options count] * POPLISTVIEW_SCREENINSET;
        if(height > rect.size.height - POPUPHEIGHT)
            height = rect.size.height - POPUPHEIGHT;
        CGRect bgRect = CGRectMake(POPLISTVIEW_SCREENINSET, POPLISTVIEW_SCREENINSET, rect.size.width - (POPLISTVIEW_SCREENINSET * 2), height + 8);
        
        _tableView = [[UITableView alloc] initWithFrame:bgRect];
        _tableView.center = self.center;
        _tableView.separatorColor = [UIColor colorWithWhite:0 alpha:.2];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self addSubview:_tableView];
    }
    return self;
}

- (id)initWithTitle:(NSString *)aTitle
            options:(NSArray *)aOptions
            handler:(void (^)(NSInteger anIndex))aHandlerBlock
{
    if(self = [self initWithTitle:aTitle options:aOptions])
        self.handlerBlock = aHandlerBlock;
   // //NSLog(@"aOptions %@",aOptions);
    [self.optionsArry addObjectsFromArray:aOptions];
    return self;
}

#pragma mark - Private Methods
- (void)fadeIn {
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void) orientationDidChange: (NSNotification *) not {
    CGRect rect = [[UIScreen mainScreen] applicationFrame]; // portrait bounds
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        rect.size = CGSizeMake(rect.size.height, rect.size.width);
    }
    [self setFrame:rect];
    [self setNeedsDisplay];
}

- (void)fadeOut {
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(orientationDidChange:)
        name: UIApplicationDidChangeStatusBarOrientationNotification object: nil];
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

#pragma mark - Tableview datasource & delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    _tableView.scrollEnabled = self.allowScroll;
    return _options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentity = @"PopListViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (!cell)
        cell = [[CLPopListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
    
    if ([_options[indexPath.row] respondsToSelector:@selector(objectForKey:)]) {
       // cell.imageView.image = _options[indexPath.row][@""];
        cell.textLabel.text = _options[indexPath.row][@"name"];
    } else
        cell.textLabel.text = _options[indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if ([_options[indexPath.row] respondsToSelector:@selector(objectForKey:)]) {
    if([self.selectedItems containsObject:_options[indexPath.row][@"id"]])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    }
    
    
    if(self.selectedIndex == indexPath.row && self.allowScroll) {
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor grayColor];
    if([cell.textLabel.text isEqualToString:@"Cancel"]) {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.textLabel.numberOfLines=0;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.allowScroll) {
        
        UITableViewCell *pTblCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
        pTblCell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell *tblCell = [tableView cellForRowAtIndexPath:indexPath];
        tblCell.accessoryType = UITableViewCellAccessoryCheckmark;
        if([tblCell.textLabel.text isEqualToString:@"Cancel"]) {
            tblCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // tell the delegate the selection
    if ([_delegate respondsToSelector:@selector(leveyPopListView:didSelectedIndex:)])
        [_delegate leveyPopListView:self didSelectedIndex:[indexPath row]];
    
    if (_handlerBlock)
        _handlerBlock(indexPath.row);
    
    // dismiss self
    [self fadeOut];
}

#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // tell the delegate the cancellation
    if ([_delegate respondsToSelector:@selector(leveyPopListViewDidCancel)])
        [_delegate leveyPopListViewDidCancel];
    
    // dismiss self
    [self fadeOut];
}

#pragma mark - DrawDrawDraw
- (void)drawRect:(CGRect)rect {
    int bgHeight = ([_options count] + 1) * POPLISTVIEW_SCREENINSET;
    if(bgHeight > rect.size.height - POPUPHEIGHT)
        bgHeight = rect.size.height - POPUPHEIGHT;
    int hPadding = 27;
    if([_options indexOfObject:@"Cancel"] == ([_options count] - 1))
        hPadding = 15;
    CGRect bgRect = CGRectMake(0, POPLISTVIEW_SCREENINSET, rect.size.width - (POPLISTVIEW_SCREENINSET * 2), bgHeight + hPadding);
    CGRect titleRect = CGRectMake(POPLISTVIEW_SCREENINSET + 10, POPLISTVIEW_SCREENINSET + 10 + 5,
                                  rect.size.width -  2 * (POPLISTVIEW_SCREENINSET + 10), 30);
    CGRect separatorRect = CGRectMake(POPLISTVIEW_SCREENINSET, POPLISTVIEW_SCREENINSET + POPLISTVIEW_HEADER_HEIGHT - 2,
                                      rect.size.width - 2 * POPLISTVIEW_SCREENINSET, 1);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw the background with shadow
    [[UIColor colorWithWhite:0 alpha:.75] setFill];
    
    CGColorRef strokeColor = [UIColor colorWithRed:210/255.0f green:210/255.0f blue:210/255.0f alpha:1].CGColor;// yadda
    
    float x = POPLISTVIEW_SCREENINSET;
    float y = _tableView.frame.origin.y - titleRect.size.height - 10;
    float width = bgRect.size.width;
    float height = bgRect.size.height;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x, y + RADIUS);
    CGPathAddArcToPoint(path, NULL, x, y, x + RADIUS, y, RADIUS);
    CGPathAddArcToPoint(path, NULL, x + width, y, x + width, y + RADIUS, RADIUS);
    CGPathAddArcToPoint(path, NULL, x + width, y + height, x + width - RADIUS, y + height, RADIUS);
    CGPathAddArcToPoint(path, NULL, x, y + height, x, y + height - RADIUS, RADIUS);
    CGPathCloseSubpath(path);
    
    CGContextSetStrokeColor(ctx, CGColorGetComponents(strokeColor));
    CGContextSetLineJoin(ctx, kCGLineJoinMiter);
    CGContextSetLineWidth(ctx, 1);
    
    CGContextAddPath(ctx, path);
    [[UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1] setFill];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    CGContextFillPath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextStrokePath(ctx);
    
    CGPathRelease(path);
    
    if(![_title isEqualToString:@""]) {
        // Draw the title and the separator with shadow
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0.5f, [UIColor lightGrayColor].CGColor);
        [[UIColor colorWithRed:0.020 green:0.549 blue:0.961 alpha:1.] setFill];
        titleRect.origin.y = _tableView.frame.origin.y - titleRect.size.height;
        [_title drawInRect:titleRect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0]}];
        
        separatorRect.origin.y = _tableView.frame.origin.y - separatorRect.size.height;
        CGContextFillRect(ctx, separatorRect);
    }
    if(_options && [_options count] > self.selectedIndex) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

@end
