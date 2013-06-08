//
//  DestTerrainSystem.h
//  PWNDestructibleTerrain
//
//  Created by Paul Renton on 6/8/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TerrainProtocols.h"

@class DestTerrain;

@interface DestTerrainSystem : NSObject <DestructibleTerrainProtocols> {
    
    NSMutableDictionary * terrainPieces;
    
    CGSize levelSize;
    
    
} // end ivars

@property(atomic, strong) NSMutableDictionary * terrainPieces;

-(id)initWithGridSystem:(CGSize)levelSize;

-(id)createDestTerrainWithImage:(UIImage*) image withID:(NSInteger)terrainID;

-(id)createDestTerrainWithImageName:(NSString *)imageName withID:(NSInteger)terrainID;

@end
