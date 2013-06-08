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

#pragma mark Overrides
#pragma mark -

-(void)setPosition:(CGPoint)position {
    // Overrides position setter
    // Intercepts setting of position and updates the system with the new position
    
    if (delegate) {
        [delegate updatePositionWithSystem:position];
        CCLOG(@"DestTerrain-> Updating position to DestTerrainSystem");
    } else {
        CCLOG(@"DestTerrain-> Cannot update position to DestTerrainSystem as delegate is nil");
    } // end if
    
    [super setPosition:position];
    
} // end setPosition

@end
