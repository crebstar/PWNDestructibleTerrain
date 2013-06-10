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
-(NSMutableArray *)getTerrainCollisionList:(CGPoint)point;
-(NSMutableArray *)getTerrainCollisionList:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint;

@end

@implementation DestTerrainSystem

@synthesize terrainPieces;
@synthesize applyAtEachDraw;


-(void)dealloc {
    
    CCLOG(@"DestTerrainSystem-> Dealloc");
    
    self.terrainPieces = nil;
    
} // end dealloc

-(id)init {
    
    self = [super init];
    
    if (self != nil) {
        
        [self createTerrainDict];
        
    } // end if
    
    return self;
    
}

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

-(id)createDestTerrainWithImage:(UIImage*)image withID:(int)terrainID {
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
    
    NSNumber * key = [NSNumber numberWithInt:terrainID];
    [terrainPieces setObject:destructibleTerrain forKey:key];
    
    
    return destructibleTerrain;
    
} // end createDestTerrainWithImage

-(id)createDestTerrainWithImageName:(NSString *)imageName withID:(int)terrainID {
    /*
     For convenience if you don't want to create the UIImage yourself
     */
    
    UIImage * image = [UIImage imageNamed:imageName];
    
    DestTerrain * destTerrain = [self createDestTerrainWithImage:image withID:terrainID];
    
    return destTerrain;
    
} // end createDestTerrainWithImageName


#pragma mark Wrapper Functions
#pragma mark -

-(void)drawLineFrom:(CGPoint)startPoint endPoint:(CGPoint)endPoint withWidth:(float)lineWidth withColor:(ccColor4B)color {
    
    NSMutableArray * colList = [self getTerrainCollisionList:startPoint toEndPoint:endPoint];
    
    for (int index = 0; index < [colList count]; index++) {
        
        DestTerrain * dTer = [colList objectAtIndex:index];
        [dTer drawLineFrom:startPoint endPoint:endPoint withWidth:lineWidth withColor:color];
        
    } // end for
    
    colList = nil;
    
} // endDrawLineFrom

-(void)drawHorizontalLine:(float)xStart xEnd:(float)xEnd y:(float)yF withColor:(ccColor4B)colorToApply {
    
    
}

-(void)drawVerticalLine:(float)yStart yEnd:(float)yEnd x:(float)xF withColor:(ccColor4B)colorToApply {
    
    
    
}

-(void)drawVerticalLineFromPointToTopEdge:(float)yStart atX:(float)xF withColor:(ccColor4B)colorToApply {
    
    
    
}


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

#pragma mark Collisions
#pragma mark

// Single point collisions
-(NSMutableArray *)getTerrainCollisionList:(CGPoint)point {
    // TODO :: optimize this later
    // Currently O(n) where n is number of dest terrain objects
    
    NSMutableArray * colList = [[NSMutableArray alloc] init];
    CGRect rect = CGRectMake(point.x, point.y , 1.0f, 1.0f);
    
    for (NSNumber * key in self.terrainPieces) {
        
        DestTerrain * dTer = [self.terrainPieces objectForKey:key];
        
        if (CGRectIntersectsRect(rect, [dTer boundingBox])) {
            // Point intersects with the terrain
            [colList addObject:dTer];
            
        } // end if
        
        CCLOG(@"origin of given point %f, %f", rect.origin.x, rect.origin.y);
        CCLOG(@"origin of the bounding box %f, %f", [dTer boundingBox].origin.x, [dTer boundingBox].origin.y);
    } // end for
    
    if ([colList count] == 0) {
        CCLOG(@"DestTerrainSystem--> There are no terrain objects that intersect with the given point");
    } else {
        CCLOG(@"DestTerrainSystem--> There are %d terrain objects that intersect with the given point", [colList count]);
    }
    
    return colList;
    
} // getTerrainCollision

// Double point collisions
-(NSMutableArray *)getTerrainCollisionList:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint {
    // TODO :: optimize this later
    // Currently O(n) where n is number of dest terrain objects
    
    NSMutableArray * colList = [[NSMutableArray alloc] init];
    CGRect startRect = CGRectMake(startPoint.x, startPoint.y, 1.0f, 1.0f);
    CGRect endRect = CGRectMake(endPoint.x, endPoint.y, 1.0f, 1.0f);
    
    for (NSNumber * key in self.terrainPieces) {
        
        DestTerrain * dTer = [self.terrainPieces objectForKey:key];
        
        CGRect boundingBoxOfTerrain = [dTer boundingBox];
        
        if (CGRectIntersectsRect(startRect, boundingBoxOfTerrain) ||
            CGRectIntersectsRect(endRect, boundingBoxOfTerrain)) {
            // Start point intersects with terrain
            [colList addObject:dTer];
            
        } // end if
        
    } // end for
    
    if ([colList count] == 0) {
        CCLOG(@"DestTerrainSystem--> There are no terrain objects that intersect with the given points");
    } else {
        CCLOG(@"DestTerrainSystem--> There are %d terrain objects that intersect with the given points", [colList count]);
    }
    
    return colList;
    
} // endGetTerrainCollisionList


#pragma mark Helper Methods
#pragma mark -

-(void)createTerrainDict {
    if (!self.terrainPieces) {
        self.terrainPieces = [[NSMutableDictionary alloc] init];
    } // end if
} // end createTerrainDict

-(void)createGridSystem {
    
    // Pass for now
    
    
} // end crateGridsystem


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
