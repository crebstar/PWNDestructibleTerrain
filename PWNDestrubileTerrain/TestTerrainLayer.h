//
//  TestTerrainLayer.h
//  PWNDestructibleTerrain
//
//  Created by Paul Renton on 6/8/13.
//
//

#import "CCLayer.h"
#import "cocos2d.h"


@class DestTerrainSystem;

@interface TestTerrainLayer : CCLayer  {
    
    DestTerrainSystem * destTerrainSystem;
    BOOL isRetina;
    
    ccColor4B currentColor;
    double lastDigTime;
    CGPoint activeLocation;
    
    CCSprite * tankSprite;
    CCSprite * tankCol;
    
} // end ivars

@property(atomic, strong) DestTerrainSystem * destTerrainSystem;

@property(nonatomic, readwrite) BOOL isRetina;


@end
