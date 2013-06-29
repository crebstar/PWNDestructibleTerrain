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
    
    // Stores altered terrain pieces if applyAfterDraw is NO
    NSMutableSet * alteredTerrain;
    
} // end ivars

@property(atomic, strong) NSMutableDictionary * terrainPieces;

// If YES then it applies texture changes after each draw method
// This can be hazardous to performance but convenient if you keep
// forgetting to call apply or just want it done automagically
@property(nonatomic, readwrite) BOOL applyAfterDraw;

-(id)createDestTerrainWithImage:(UIImage*) image withID:(int)terrainID;

-(id)createDestTerrainWithImageName:(NSString *)imageName withID:(int)terrainID;

// If applyAfterDraw is NO, this lets all pixel changes be applied to altered terrain pieces
-(void)applyTerrainChanges;

// Functions which determine which terrain to apply the effect too then make the appropriate call
// if a collision is present

-(void)drawLineFrom:(CGPoint)startPoint endPoint:(CGPoint)endPoint withWidth:(float)lineWidth withColor:(ccColor4B)color;

-(void)drawHorizontalLine:(float)xStart xEnd:(float)xEnd y:(float)yF withColor:(ccColor4B)colorToApply;

-(void)drawVerticalLine:(float)yStart yEnd:(float)yEnd x:(float)xF withColor:(ccColor4B)colorToApply;

-(void)drawVerticalLineFromPointToTopEdge:(float)yStart atX:(float)xF withColor:(ccColor4B)colorToApply;

-(void)drawCircle:(CGPoint)circleOrigin withRadius:(float)radius withColor:(ccColor4B)color;

-(void)drawSquare:(CGPoint)squareOrigin withRadius:(float)radius withColor:(ccColor4B)color;

-(void)createExplosion:(CGPoint)explosionOrigin withRadius:(float)radius withColor:(ccColor4B)color;

- (BOOL)pixelAt:(CGPoint) pt colorCache:(ccColor4B*)color;

-(CGPoint)getAverageSurfaceNormalOfAreaAt:(CGPoint)pt withSquareWidth:(int)area;

-(CGPoint)getSurfaceNormalAt:(CGPoint)pt withSquareWidth:(int)area;

-(void)collapseAllTerrain;

-(bool)collapseSinglePixel;

@end
