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
    
    // If YES then it applies texture changes after each draw method
    // This can be hazardous to performance but convenient if you keep
    // forgetting to call apply or just want it done automagically
    BOOL applyAtEachDraw;
    
    
} // end ivars

@property(atomic, strong) NSMutableDictionary * terrainPieces;

@property(nonatomic, readwrite) BOOL applyAtEachDraw;

-(id)initWithGridSystem:(CGSize)levelSize;

-(id)createDestTerrainWithImage:(UIImage*) image withID:(NSInteger)terrainID;

-(id)createDestTerrainWithImageName:(NSString *)imageName withID:(NSInteger)terrainID;

@end
