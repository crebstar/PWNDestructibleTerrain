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
    
    // Set this to true to override the DestTerrainSystem applyAfterDraw BOOL property
    BOOL applyAfterDraw;
    
} // end ivars

@property(atomic, strong) CCMutableTexture2D * mutableTerrainTexture;
@property(atomic, readonly) NSInteger terID;

@property(nonatomic) id <DestructibleTerrainProtocols> delegate;

@property(nonatomic, readwrite) BOOL applyAfterDraw;

-(id)initWithIntID:(NSInteger)terrainID withImage:(UIImage*)image;


/*
 Convenience wrapper functions. Handles conversion of points from Cocos2D to point system used by CCMutableTexture2D.
 After the conversion it calls the appropriate functions
 */

-(void)drawLineFrom:(CGPoint)startPoint endPoint:(CGPoint)endPoint withWidth:(float)lineWidth withColor:(ccColor4B)color;

-(void)drawHorizontalLine:(float)xStart xEnd:(float)xEnd y:(float)yF withColor:(ccColor4B)colorToApply;

-(void)drawVerticalLine:(float)yStart yEnd:(float)yEnd x:(float)xF withColor:(ccColor4B)colorToApply;

-(void)drawVerticalLineFromPointToTopEdge:(float)yStart atX:(float)xF withColor:(ccColor4B)colorToApply;

-(void) drawCircle:(CGPoint)circleOrigin withRadius:(float)radius withColor:(ccColor4B)color;

-(void) drawSquare:(CGPoint)squareOrigin withRadius:(float)radius withColor:(ccColor4B)color;

@end
