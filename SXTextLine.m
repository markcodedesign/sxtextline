//
//  SXTextLine.m
//  Kana Legends
//
//  Created by Lemark on 10/12/15.
//  Copyright © 2015 Kamidojin. All rights reserved.
//
#import "DebuggingAndTestingDefines.h"

@import AVFoundation
#import "Helper.h"
#import "SXTextLine.h"

@implementation SXTextLine{
    NSString *_textLine;
    NSUInteger _textLineLength;
    
    NSUInteger _speed;
    NSUInteger _nextChar;
    NSUInteger _nextLine;
    NSUInteger _wordCount;
    NSUInteger _spaceCount;
    
    BOOL _displayFinish;
    BOOL _executeCallback;

    
    NSTimeInterval _time;
    
    NSMutableArray *_textLineArray;
    NSMutableArray *_paragraphCallback;
    
    void (^callbackBlock)(void);
}

#ifdef DEBUG
-(void)dealloc{
    DebugLog(@"DEALLOCATING SXTextLine")
}
#endif

-(void)clean{
    callbackBlock = nil;
    
    if(_textLineArray)
    {
        [_textLineArray removeAllObjects];
        _textLineArray = nil;
    }
    
    if(_paragraphCallback)
    {
        [_paragraphCallback removeAllObjects];
        _paragraphCallback = nil;
    }
}

-(void)reset{
    _nextLine = 0;
    _nextChar = 0;
    _time = 0;
    _displayFinish = NO;
    
    [self setText:@""];

    for(SXTextLine *tl in _textLineArray){
        if(![tl isEqual:self])
            [tl reset];
    }

}

-(void)setTextLineWithSeparator:(NSString*)separator textLine:(NSString *)textLine{
    NSArray *textSubstrings = [textLine componentsSeparatedByString:separator];
    
    for(NSString *string in textSubstrings){
        _wordCount += [[string componentsSeparatedByString:@" "] count];
    }
    
    _spaceCount = _wordCount - 1;
    
    for(int i=0;i<textSubstrings.count;i++){
        if(i==0 && _textLine == nil)
            [self setTextLine:textSubstrings[i]];
        else
            [self addTextLine:textSubstrings[i]];
    }
}

-(void)setTextLine:(NSString*)textLine{
    _textLine = textLine;
    _textLineLength = _textLine.length;
}

-(void)setTextSpeed:(NSUInteger)speed{
    _speed = speed;
}

-(void)setTextColor:(UIColor*)color{
    [self setFontColor:color];
    
    if(_textLineArray)
    {
        for(SXTextLine *text in _textLineArray)
        {
            [text setFontColor:color];
        }
    }
}

-(void)setSyncCallback:(void(^)(void))callback{
    callbackBlock = callback;
    _executeCallback = YES;
}

-(void(^)(void))getSyncCallback{
    return callbackBlock;
}

-(NSUInteger)getWordCount{
    return _wordCount;
}

-(BOOL)isDisplayFinish{
    return _displayFinish;
}

-(void)addTextLine:(NSString*)textLine{
    CGPoint position;
    SXTextLine *temp;
    SXTextLine *newLine;
    
    if(!_textLineArray){
        _textLineArray = [NSMutableArray array];

        [_textLineArray addObject:self];
    }
    
    temp = _textLineArray.lastObject;
    
    position = CGPointMake(temp.position.x, temp.position.y-temp.fontSize);
    
    newLine = [SXTextLine labelNodeWithFontNamed:self.fontName];
    [newLine setText:@""];
    [newLine setFontSize:self.fontSize];
    [newLine setFontColor:self.fontColor];
    [newLine setZPosition:self.zPosition];
    
    [newLine setTextLine:textLine];
    [newLine setTextSpeed:_speed];
    [newLine setSyncCallback:[self getSyncCallback]];

    if(_textLineArray.count == 1)
        [newLine setPosition:[self convertPoint:position fromNode:newLine]];
    else
        [newLine setPosition:position];

    
    [self addChild:newLine];

    [_textLineArray addObject:newLine];

}

-(void)updateTime:(NSTimeInterval)time{
    _time += time;
}

-(void)display{
    
    if(_time >= _speed){
        
        if(_nextChar < _textLineLength){
            
            unichar charCode = [_textLine characterAtIndex:_nextChar++];
            
            if(_executeCallback){
                callbackBlock();
                _executeCallback = NO;
                
            }else if(charCode == 32){
                _executeCallback = YES;
            }
            
            [self setText:[self.text stringByAppendingFormat:@"%c",charCode]];
            
        }else{
            _displayFinish = YES;
            
            if(_textLineArray)
            {
                if(_nextLine < _textLineArray.count)
                {
                    SXTextLine *temp = _textLineArray[_nextLine];
                    if([temp isDisplayFinish])
                    {
                        _nextLine++;
                    }
                    else
                    {
                        [temp updateTime:_time];
                        [temp display];
                    }
                }
            }
        }
        
        _time = 0;

    }
}


@end
