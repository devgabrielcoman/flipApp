//
//  UITableView+AnimationControl.m
//  UITableView-AnimationControl
//
//  Created by David Román Aguirre on 04/01/14.
//  Copyright (c) 2014 David Román Aguirre. All rights reserved.
//

#import "UITableView+AnimationControl.h"

@implementation UITableView (AnimationControl)

- (void)beginSmartUpdatesForDuration:(NSTimeInterval)duration {
    [UIView beginAnimations:@"UITableView+AnimationControl Animations ID" context:nil];
    [UIView setAnimationDuration:duration > 0 ? duration : 0.25];
    [CATransaction begin];
    [self beginUpdates];
}

- (void)endSmartUpdates {
    [self endUpdates];
    [CATransaction commit];
    [UIView commitAnimations];
}

- (void)performDataSourceAction:(void (^)(void))action completion:(void (^)(void))completion {
    [CATransaction setCompletionBlock:completion];
    action();
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } completion:completion];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self insertSections:sections withRowAnimation:animation];
    } completion:completion];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } completion:completion];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self deleteSections:sections withRowAnimation:animation];
    } completion:completion];
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } completion:completion];
}

- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self reloadSections:sections withRowAnimation:animation];
    } completion:completion];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    } completion:completion];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self moveSection:section toSection:newSection];
    } completion:completion];
}

@end
