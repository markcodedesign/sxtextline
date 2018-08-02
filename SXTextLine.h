//
//  SXTextLine.h
//  Kana Legends
//
//  Created by Lemark on 10/12/15.
//  Copyright © 2015 Kamidojin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SXTextLine : SKLabelNode
-(void)setTextLine:(NSString*)textLine;
-(void)setTextSpeed:(NSUInteger)speed;
-(void)setTextLineWithSeparator:(NSString*)separator textLine:(NSString *)textLine;
-(void)setTextColor:(UIColor*)color;

-(void)clean;

-(NSUInteger)getWordCount;
-(void)reset;
-(BOOL)isDisplayFinish;
-(void)display;
-(void)updateTime:(NSTimeInterval)time;
-(void)setSyncCallback:(void (^)(void))callback;
-(void(^)(void))getSyncCallback;


@end
