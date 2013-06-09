//
//  TerrainTestScene.m
//  PWNDestructibleTerrain
//
//  Created by Paul Renton on 6/8/13.
//
//

#import "TerrainTestScene.h"

#import "TestTerrainLayer.h"

@implementation TerrainTestScene


-(id)init {
    
    self = [super init];
    
    if (self != nil) {
        
        testLayer = [TestTerrainLayer node];
        [self addChild:testLayer z:1];
        
    } // end if
    
    return self;
    
    
}

@end
