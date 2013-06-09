//
//  DestTerrain.m
//  PWNDestructibleTerrain
//
//  Created by Paul Renton on 6/8/13.
//
//

#import "DestTerrain.h"
#import "CCMutableTexture2D.h"


@interface DestTerrain ()
// Private Functions

@end

@implementation DestTerrain 
    
@synthesize mutableTerrainTexture;
@synthesize terID;
@synthesize delegate;

-(id)initWithIntID:(NSInteger)terrainID withImage:(UIImage*)image {
    // Should be the only init method one uses
    
    self.mutableTerrainTexture = [CCMutableTexture2D textureWithImage:image];
    
    self = [DestTerrain spriteWithTexture:mutableTerrainTexture];
    
    if (self != nil) {
        
        // Cache id for convenient access if need be
        terID = terrainID;
        
    } // end if
    
    return self;
    
} // end initWithIntID


-(void)drawLineFrom:(CGPoint)startPoint endPoint:(CGPoint)endPoint withWidth:(float)lineWidth withColor:(ccColor4B)color {
    /*
     A layer of abstraction from CCMutableTexture2D. This function handles the conversion of Cocos2D coordinates to the
     coordinate system used by the CCMutableTexture2D (Where positive y heads south). It will convert the Cocos2D points
     to points usable by CCMutableTexture2D then call the appropriate drawLine method of the CCMutableTexture for the sprite
     
     Note: Important to remember all dest terrain sprites have an anchor point of 0,0
     TODO :: Consider doing a simple colission check to inform users if they are even drawing on correct terrain sprite
     */
        
    CGPoint localStartPoint; // Localize the startPoint parameter to be within coordinate system of the texture
    CGPoint localEndPoint; // Localize the endPoint parameter to be within the coordinate system of the texture
    
    float yStart = (self.contentSize.height - (startPoint.y - self.position.y));
    float yEnd = (self.contentSize.height - (endPoint.y - self.position.y));

    localStartPoint = ccp(startPoint.x, yStart);
    
    localEndPoint = ccp(endPoint.x, yEnd);
    
    CCMutableTexture2D * terrainTexture = (CCMutableTexture2D *) [self texture];
    
    [terrainTexture drawLineFrom:localStartPoint to:localEndPoint withLineWidth:lineWidth andColor:color];
    
    [terrainTexture apply];
    
} // endDrawLineFrom

#pragma mark Overrides
#pragma mark -

-(void)setPosition:(CGPoint)position {
    // Overrides position setter
    // Intercepts setting of position and updates the system with the new position
    
    if (delegate) {
        [delegate updatePositionWithSystem:position terID:self.terID];
        CCLOG(@"DestTerrain-> Updating position to DestTerrainSystem");
    } else {
        CCLOG(@"DestTerrain-> Cannot update position to DestTerrainSystem as delegate is nil");
    } // end if
    
    [super setPosition:position];
    
} // end setPosition

@end
