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

@property(nonatomic, readwrite) BOOL applyAfterDraw;

-(id)initWithGridSystem:(CGSize)levelSize;

-(id)createDestTerrainWithImage:(UIImage*) image withID:(int)terrainID;

-(id)createDestTerrainWithImageName:(NSString *)imageName withID:(int)terrainID;

// Functions which determine which terrain to apply the effect too then make the appropriate call
// if a collision is present

-(void)drawLineFrom:(CGPoint)startPoint endPoint:(CGPoint)endPoint withWidth:(float)lineWidth withColor:(ccColor4B)color;

-(void)drawHorizontalLine:(float)xStart xEnd:(float)xEnd y:(float)yF withColor:(ccColor4B)colorToApply;

-(void)drawVerticalLine:(float)yStart yEnd:(float)yEnd x:(float)xF withColor:(ccColor4B)colorToApply;

-(void)drawVerticalLineFromPointToTopEdge:(float)yStart atX:(float)xF withColor:(ccColor4B)colorToApply;

-(void) drawCircle:(CGPoint)circleOrigin withRadius:(float)radius withColor:(ccColor4B)color;

-(void) drawSquare:(CGPoint)squareOrigin withRadius:(float)radius withColor:(ccColor4B)color;

@end
