//
//  DestTerrainSystem.m
//  PWNDestructibleTerrain
//
//  Created by Crebstar on 6/8/13.
//
//

#import "DestTerrainSystem.h"
#import "DestTerrain.h"
#import "CCMutableTexture2D.h"

@interface DestTerrainSystem ()
// Private Functions
-(void)createTerrainDict;
-(void)createGridSystem;

@end

@implementation DestTerrainSystem

@synthesize terrainPieces;


-(void)dealloc {
    
    CCLOG(@"DestTerrainSystem-> Dealloc");
    
    self.terrainPieces = nil;
    
} // end dealloc

-(id)initWithGridSystem:(CGSize)levelSize {
    // Only Init function for now
    self = [super init];
    
    if (self != nil) {
        CCLOG(@"DestTerrainSystem-> Init");
        
        self->levelSize = levelSize;
        [self createTerrainDict];
        [self createGridSystem]; // Will optmize later 
        
    } // end if
    
    return self;
    
} // end constructor

#pragma mark Factory Methods
#pragma mark -

-(id)createDestTerrainWithImage:(UIImage*)image withID:(NSInteger)terrainID {
    /*
     Creates a destructible terrain sprite with a given image with integerID
     Best practice would be to use an enumeration or constant integer for easy
     reference of the terrain created. All created destructible terrains are stored
     in the terrainPieces dictionary
     */
    
    CCMutableTexture2D * mutableTexture = [CCMutableTexture2D textureWithImage:image];
    
    DestTerrain * destructibleTerrain = [DestTerrain spriteWithTexture:mutableTexture];
    
    [destructibleTerrain setDelegate:self];
    [destructibleTerrain setAnchorPoint:ccp(0,0)]; // Default (Simplifies calculation)
    
    return destructibleTerrain;
    
} // end createDestTerrainWithImage

-(id)createDestTerrainWithImageName:(NSString *)imageName withID:(NSInteger)terrainID {
    /*
     For convenience if you don't want to create the UIImage yourself
     */
    
    UIImage * image = [UIImage imageNamed:imageName];
    
    DestTerrain * destTerrain = [self createDestTerrainWithImage:image withID:terrainID];
    
    return destTerrain;
    
} // end createDestTerrainWithImageName




#pragma mark Delegate Methods
#pragma mark -

-(void)updatePositionWithSystem:(CGPoint)positionOfTerrain terID:(NSInteger)terrainID {
    
    // pass for now
    
}

-(BOOL)shouldApplyAfterEachDraw {
    // If YES then it applies texture changes after each draw method
    // This can be hazardous to performance but convenient if you keep
    // forgetting to call apply or just want it done automagically
    
    return applyAtEachDraw;
    
} // end shouldApplyAfterEachDraw

#pragma mark Helper Methods
#pragma mark -

-(void)createTerrainDict {
    if (!self.terrainPieces) {
        self.terrainPieces = [[NSMutableDictionary alloc] init];
    } // end if
} // end createTerrainDict

-(void)createGridSystem {
    
    // Pass for now
    
    
}

#pragma mark Mutators
#pragma mark -

-(void)setApplyAtEachDraw:(BOOL)applyAtEachDraw {
    
    if (applyAtEachDraw) {
        CCLOG(@"Warning setting applyAtEachDraw to true will call the apply method of"
              "CCMutableTexture for each terrain whose pixel values were modified."
              "If performance becomes an issue, this should be called manually.");
    } else {
        CCLOG(@"applyAtEachDraw is set to false. You must call the apply method for each"
              "terrain's texture that you have modified before it will take effect."
              "For best performance, minimize the calls to apply");
    } // end if

    // Must assign directly to prevent infinite loop :)
    self->applyAtEachDraw = applyAtEachDraw;
    
} // end setApplyAtEachDraw

@end
