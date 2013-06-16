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

#import "TerCollisionHelper.h"
#import "TerCollisionEvent.h"

@interface DestTerrainSystem ()
// Private Functions
-(void)createTerrainDict;
-(void)createGridSystem;
-(DestTerrain *)getTerrainCollision:(CGPoint)point;
-(NSMutableArray *)getTerrainCollisionList:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint;

@end

@implementation DestTerrainSystem

@synthesize terrainPieces;
@synthesize applyAfterDraw;


-(void)dealloc {
    
    CCLOG(@"DestTerrainSystem-> Dealloc");
    
    self.terrainPieces = nil;
    
} // end dealloc

-(id)init {
    
    self = [super init];
    
    if (self != nil) {
        
        [self createTerrainDict];
        
        /*
        CGPoint startPoint = ccp(0,0);
        CGPoint endPoint  = ccp(20,20);
        
        LineSegment lineOne = createLineSegment(startPoint, endPoint);
        
        CGPoint secPoint  = ccp(20,10);
        CGPoint secPointEnd = ccp(12,25);
       
        // This will intersect with lineOne
        LineSegment lineTwo = createLineSegment(secPoint, secPointEnd);
        
        CGPoint  colPoint = ccp(0,0);
        bool intOpt = getLineIntersectionPoint(lineOne, lineTwo, &colPoint);
        
        if (intOpt) {
            
            CCLOG(@"The lines intersected and intersect at %f, %f", colPoint.x, colPoint.y);
        } else {
            CCLOG(@"The lines do not intersect");
        } // end if

        */ 
       
        
        /*
        bool inter = doLineBoundingBoxesIntersect(lineOne, lineTwo);
        
        if (inter) {
            CCLOG(@"The line bounding boxes intersect");
        } else {
            CCLOG(@"The line bounding boxes do NOT intersect");
        } // end if 
        
        bool right = isPointRightOfLine(lineOne, secPoint);
        
        if (right) {
            CCLOG(@"Point is to the right of the line");
        } else {
            CCLOG(@"Point is to the left of the line");
        }
        
        bool onLine = isPointOnLine(lineOne, ccp(10,10));
        
        if (onLine) {
            CCLOG(@"The point is on the line");
        } else {
            CCLOG(@"The point is off the line");
        }
        
        // This won't intersect with lineOne
        LineSegment lineThree = createLineSegment(ccp(30,10), ccp(30,30));
        
        bool linecross = doLinesIntersect(lineOne, lineTwo);
        
        if (linecross) {
            
            CCLOG(@"The lines intersect");
        } else {
            CCLOG(@"The lines DO NOT intersect");
            
        }
        */
        
               
    } // end if
    
    return self;
    
} // end init

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
     It will just create the UIImage locally and call the createWithImage function
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
        
        TerCollisionEvent * event = [colList objectAtIndex:index];
        CCLOG(@"Collision event coords are %f, %f", event.startPoint.x, event.startPoint.y);
        CCLOG(@"Collision event coords are %f, %f", event.endPoint.x, event.endPoint.y);
        [event.ter drawLineFrom:event.startPoint endPoint:event.endPoint withWidth:lineWidth withColor:color];
        
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
    
    return applyAfterDraw;
    
} // end shouldApplyAfterEachDraw

#pragma mark Collisions
#pragma mark

// Single point collisions
-(DestTerrain *)getTerrainCollision:(CGPoint)point {
    // TODO :: optimize this later
   
    CGRect rect = CGRectMake(point.x, point.y , 1.0f, 1.0f);
    
    for (NSNumber * key in self.terrainPieces) {
        
        DestTerrain * dTer = [self.terrainPieces objectForKey:key];
        
        if (CGRectIntersectsRect(rect, [dTer boundingBox])) {
            // Point intersects with the terrain
            return dTer;
            
        } // end if
        
        CCLOG(@"origin of given point %f, %f", rect.origin.x, rect.origin.y);
        CCLOG(@"origin of the bounding box %f, %f", [dTer boundingBox].origin.x, [dTer boundingBox].origin.y);
    } // end for
    
    CCLOG(@"No collision");
    return NULL;
    
} // getTerrainCollision


// Double point collisions
-(NSMutableArray *)getTerrainCollisionList:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint {
    /*
     Gets all terrain objects that collide with the two points
     */
    
    NSMutableArray * colList = [[NSMutableArray alloc] init];
    CGRect startRect = CGRectMake(startPoint.x, startPoint.y, 1.0f, 1.0f);
    CGRect endRect = CGRectMake(endPoint.x, endPoint.y, 1.0f, 1.0f);
    
    for (NSNumber * key in self.terrainPieces) {
        
        DestTerrain * dTer = [self.terrainPieces objectForKey:key];
        TerCollisionEvent * event;
        
        CGRect boundingBoxOfTerrain = [dTer boundingBox];
        
        if (CGRectIntersectsRect(startRect, boundingBoxOfTerrain) ){
            // Start point intersects with terrain
            
            if (CGRectIntersectsRect(endRect, boundingBoxOfTerrain)) {
                // Not possible to have any other intersections
                // Start and end point both within terrain
                event = [[TerCollisionEvent alloc]
                         initWithCollisionEventFor:dTer startInter:YES endInter:YES];
                [event addCollisionData:startPoint endPoint:endPoint];
                [colList addObject:event];
                
                CCLOG(@"Start and End points all within one terrain piece");
                return colList;
                
            } else {
                event = [[TerCollisionEvent alloc]
                         initWithCollisionEventFor:dTer startInter:YES endInter:NO];
                [event addCollisionData:startPoint endPoint:endPoint];
                [colList addObject:event];
            } // end inner if
        } // end if
        
        if (CGRectIntersectsRect(endRect, boundingBoxOfTerrain)) {
            // End point intersects with terrain but not start point
            
                CCLOG(@"End intersects but start does not");
                
                
                // Need to determine where the line intersects from start point
                CGPoint startIntersectionPoint = ccp(0,0);
                LineSegment origLine = createLineSegment(startPoint, endPoint);
                
                // Ordering from most likely to least likely intersection points
                
                LineSegment segLeft = createLineSegment(ccp(dTer.boundingBox.origin.x, dTer.boundingBox.origin.y),
                                                        ccp(dTer.boundingBox.origin.x, dTer.boundingBox.origin.y + dTer.contentSize.height));
                
                LineSegment segRight = createLineSegment(ccp(dTer.boundingBox.origin.x + dTer.contentSize.width, dTer.boundingBox.origin.y),
                                                         ccp(dTer.boundingBox.origin.x + dTer.contentSize.width, dTer.boundingBox.origin.y + dTer.contentSize.height));
                
                LineSegment segTop = createLineSegment(ccp(dTer.boundingBox.origin.x, dTer.boundingBox.origin.y + dTer.contentSize.height),
                                                       ccp(dTer.boundingBox.origin.x + dTer.contentSize.height, dTer.boundingBox.origin.y + dTer.contentSize.height));
                
                LineSegment segBottom = createLineSegment(ccp(dTer.boundingBox.origin.x, dTer.boundingBox.origin.y),
                                                          ccp(dTer.boundingBox.origin.x + dTer.contentSize.width, dTer.boundingBox.origin.y));
                
                if (getLineIntersectionPoint(segLeft, origLine, &startIntersectionPoint)) {
                    CCLOG(@"Intersection segLeft at %f, %f", startIntersectionPoint.x, startIntersectionPoint.y);
                    
                } else if (getLineIntersectionPoint(segRight, origLine, &startIntersectionPoint)) {
                     CCLOG(@"Intersection segRight at %f, %f", startIntersectionPoint.x, startIntersectionPoint.y);
                    
                } else if (getLineIntersectionPoint(segTop, origLine, &startIntersectionPoint)) {
                     CCLOG(@"Intersection segTop at %f, %f", startIntersectionPoint.x, startIntersectionPoint.y);
                    
                } else if (getLineIntersectionPoint(segBottom, origLine, &startIntersectionPoint)) {
                     CCLOG(@"Intersection segBottom at %f, %f", startIntersectionPoint.x, startIntersectionPoint.y);
                    
                } else {
                    CCLOG(@"Error with collision logic: There should be a collision point");
                } // end if
            
            if (event) {
                event.endIntersected = YES;
            } else {
                event = [[TerCollisionEvent alloc]
                         initWithCollisionEventFor:dTer startInter:NO endInter:YES];
                [colList addObject:event];
            } // end if
            
            [event addCollisionData:startIntersectionPoint endPoint:endPoint];
        } // end if
        
        if (!event) {
            // Neither start or end is touching
            // But it is still possible the line intersects other terrain pieces
            CCLOG(@"No Collision Event detected for a terrain piece");
        } // end not event
        
    } // end for
    
    if ([colList count] == 0) {
        CCLOG(@"DestTerrainSystem--> There are no terrain objects that intersect with the given points");
    } else {
        CCLOG(@"DestTerrainSystem--> There are %d terrain objects that intersect with the given points", [colList count]);
    } // end if
    
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

