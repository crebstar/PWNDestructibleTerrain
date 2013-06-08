//
//  DestTerrain.h
//  PWNDestructibleTerrain
//
//  Created by Crebstar on 6/8/13.
//
//

#import "CCSprite.h"
#import "cocos2d.h"
#import "TerrainProtocols.h"

@class CCMutableTexture2D;

@interface DestTerrain : CCSprite {
    
    CCMutableTexture2D * mutableTerrainTexture;
    NSInteger terID;
    
    id <DestructibleTerrainProtocols> delegate;
    
} // end ivars

@property(atomic, strong) CCMutableTexture2D * mutableTerrainTexture;
@property(atomic, readonly) NSInteger terID;

@property(nonatomic) id <DestructibleTerrainProtocols> delegate;

-(id)initWithIntID:(NSInteger)terrainID withImage:(UIImage*)image;

@end