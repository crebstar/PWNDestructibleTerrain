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
-(DestTerrain *)getTerrainCollision:(CGPoint)point;
-(NSMutableArray *)getTerrainCollisionList:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint;

@end

@implementation DestTerrainSystem

@synthesize terrainPieces;
@synthesize applyAfterDraw;


-(void)dealloc {
    
    CCLOG(@"DestTerrainSystem-> Dealloc");
    
    self.terrainPieces = nil;
    self->alteredTerrain = nil;
    
} // end dealloc

-(id)init {
    
    self = [super init];
    
    if (self != nil) {
        
        [self createTerrainDict];
        
        // Used if apply is set to NO
        self->alteredTerrain = [[NSMutableSet alloc] init];
        
        self.applyAfterDraw = NO;
        
    } // end if
    
    return self;
    
} // end init


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

-(void)applyTerrainChanges {
    CCLOG(@"%d objects in alteredTerrain", [alteredTerrain count]);
    for (DestTerrain * ter in alteredTerrain) {
        [ter applyChanges];
    } // end for
    
    [alteredTerrain removeAllObjects];
} // end apply


#pragma mark Wrapper Functions
#pragma mark -

-(void)drawLineFrom:(CGPoint)startPoint endPoint:(CGPoint)endPoint withWidth:(float)lineWidth withColor:(ccColor4B)color {
    
    NSMutableArray * colList = [self getTerrainCollisionList:startPoint toEndPoint:endPoint];
    
    for (int index = 0; index < [colList count]; index++) {
        
        TerCollisionEvent * event = [colList objectAtIndex:index];
        [event.ter drawLineFrom:event.startPoint endPoint:event.endPoint withWidth:lineWidth withColor:color];
        
        if (!applyAfterDraw) {
            [alteredTerrain addObject:event.ter];
        }
        //CCLOG(@"Collision event coords are %f, %f", event.startPoint.x, event.startPoint.y);
        //CCLOG(@"Collision event coords are %f, %f", event.endPoint.x, event.endPoint.y);
    } // end for
    
    colList = nil;
    
} // endDrawLineFrom

-(void)drawHorizontalLine:(float)xStart xEnd:(float)xEnd y:(float)yF withColor:(ccColor4B)colorToApply {
    
    DestTerrain * ter = [self getTerrainCollision:ccp(xStart, yF)];

    if (!ter) {
        return;
    } // end if
    
    [ter drawHorizontalLine:xStart xEnd:xEnd y:yF withColor:colorToApply];
    
    if (!applyAfterDraw) {
        [alteredTerrain addObject:ter];
    }
    
} // end drawHorizontalLine

-(void)drawVerticalLine:(float)yStart yEnd:(float)yEnd x:(float)xF withColor:(ccColor4B)colorToApply {
    
    // Only single collision for now.. consider changing later
    DestTerrain * ter = [self getTerrainCollision:ccp(xF, yStart)];
    
    if (!ter) {
        return;
    } // end if
    
    [ter drawVerticalLine:yStart yEnd:yEnd x:xF withColor:colorToApply];
    
    if (!applyAfterDraw) {
        [alteredTerrain addObject:ter];
    }
    
} // end drawVerticalLine

-(void)drawVerticalLineFromPointToTopEdge:(float)yStart atX:(float)xF withColor:(ccColor4B)colorToApply {
    
    DestTerrain * ter = [self getTerrainCollision:ccp(xF,yStart)];
    
    if (!ter) {
        return;
    } // end if
    
    [ter drawVerticalLineFromPointToTopEdge:yStart atX:xF withColor:colorToApply];
    
    if (!applyAfterDraw) {
        [alteredTerrain addObject:ter];
    }
    
} // end drawVerticalLineFromPointToTopEdge

-(void) drawCircle:(CGPoint)circleOrigin withRadius:(float)radius withColor:(ccColor4B)color {
    
    DestTerrain * ter = [self getTerrainCollision:circleOrigin];
    
    if (!ter)  {
        //CCLOG(@"No Single Collision Detected");
        return;
    } // end if
    
    //CCLOG(@"Single Collision Detected at %f, %f", circleOrigin.x, circleOrigin.y);
    [ter drawCircle:circleOrigin withRadius:radius withColor:color];
    
    if (!applyAfterDraw) {
        [alteredTerrain addObject:ter];
    }
    
} // end DrawCircle

-(void) drawSquare:(CGPoint)squareOrigin withRadius:(float)radius withColor:(ccColor4B)color {
    
    DestTerrain * ter = [self getTerrainCollision:squareOrigin];
    
    if (!ter) {
        //CCLOG(@"No Single Collision Detected");
        return;
    } // end if
    
    //CCLOG(@"Single Collision Detected at %f, %f", squareOrigin.x, squareOrigin.y);
    [ter drawSquare:squareOrigin withRadius:radius withColor:color];
    
    if (!applyAfterDraw) {
        [alteredTerrain addObject:ter];
    }
} // end drawSquare

-(void)createExplosion:(CGPoint)explosionOrigin withRadius:(float)radius withColor:(ccColor4B)color {
    
    DestTerrain * ter = [self getTerrainCollision:explosionOrigin];
    
    if (!ter) {
        //CCLOG(@"No Single Collision Detected");
        return;
    } // end if
    
    [ter createExplosion:explosionOrigin withRadius:radius withColor:color];
    
    if (!applyAfterDraw) {
        [alteredTerrain addObject:ter];
    }
    
} // end create explosion

- (BOOL) pixelAt:(CGPoint) pt colorCache:(ccColor4B*)color {
    
    DestTerrain * ter = [self getTerrainCollision:pt];
    
    if (!ter) {
        return NO;
    } // end if
    
    *color = [ter pixelAt:pt];
    
    return YES;
    
} // end pixelat

-(void)collapseAllTerrain {
    
    for (NSNumber * key in self.terrainPieces) {
        [[self.terrainPieces objectForKey:key] collapseTerrain];
    }
    
}

-(bool)collapseSinglePixel {
    
    bool didCol = false;
    for (NSNumber * key in self.terrainPieces) {
        didCol = [[self.terrainPieces objectForKey:key] collapseSinglePixel];
        
    }
    return didCol;
}

#pragma mark Delegate Methods
#pragma mark -


-(BOOL)shouldApplyAfterEachDraw {
    // If YES then it applies texture changes after each draw method
    // This can be hazardous to performance but convenient if you keep
    // forgetting to call apply or just want it done automagically
    
    return applyAfterDraw;
    
} // end shouldApplyAfterEachDraw

-(CGPoint)getAverageSurfaceNormalOfAreaAt:(CGPoint)pt withSquareWidth:(int)area {
    // this method considers the complete area of pixels
    float avgX = 0;
    float avgY = 0;
    ccColor4B color = ccc4(0, 0, 0, 0);
    CGPoint normal;
    float len;
    
    for (int w = area; w >= -area; w = w - 2) {
        for (int h = area; h >= -area; h = h - 2) {
            CGPoint pixPt = ccp(w + pt.x, h + pt.y);
            if ([self pixelAt:pixPt colorCache:&color]) {
                if (color.a != 0) {
                    avgX -= w;
                    avgY -= h;
                } // end inner if
            } // end outer if
        } // end inner for
    } // end outer for
    
    len = sqrtf(avgX * avgX + avgY * avgY);
    if (len == 0) {
        normal = ccp(avgX, avgY);
    } else {
        normal = ccp(avgX/len, avgY/len);
    } // end if
    
    return normal;
} // end get

-(CGPoint)getSurfaceNormalAt:(CGPoint)pt withSquareWidth:(int)area {
    // This method only looks at surface pixels
    
    int avgX = 0;
    int avgY = 0;
    CGPoint normal;
    float len;
    ccColor4B color = ccc4(0, 0, 0, 0);
    
    for (int w = area; w >= -area; w--) {
        int h = area;
        do {
            if ([self pixelAt:ccp(w + pt.x, h + pt.y) colorCache:&color]) {
                if (color.a != 0) {
                    if (w < 0) {
                        avgX -= w;
                        avgY -= h;
                    } else {
                        avgX += w;
                        avgY += h;
                    }
                    break; // Only consider first ground pixel found
                } // end inner if
            } // end outer if
            h--;
        } while (h >= -area);
    } // end for
    
    int perpX = -avgY;
    int perpY = avgX;
    len = sqrtf(perpX * perpX + perpY * perpY);
    normal = ccp(perpX/len, perpY/len);
    
    return normal;
}



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
        
        //CCLOG(@"origin of given point %f, %f", rect.origin.x, rect.origin.y);
        //CCLOG(@"origin of the bounding box %f, %f", [dTer boundingBox].origin.x, [dTer boundingBox].origin.y);
    } // end for
    
    //CCLOG(@"No collision");
    return nil;
    
} // getTerrainCollision


// Double point collisions
-(NSMutableArray *)getTerrainCollisionList:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint {
    /*
     Gets all terrain objects that collide with a line segment
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
                
                //CCLOG(@"Start and End points all within one terrain piece");
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
            // Must determine the intersection point
                //CCLOG(@"End intersects but start does not");
                
                
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
                    //CCLOG(@"Intersection segLeft at %f, %f", startIntersectionPoint.x, startIntersectionPoint.y);
                    
                } else if (getLineIntersectionPoint(segRight, origLine, &startIntersectionPoint)) {
                     //CCLOG(@"Intersection segRight at %f, %f", startIntersectionPoint.x, startIntersectionPoint.y);
                    
                } else if (getLineIntersectionPoint(segTop, origLine, &startIntersectionPoint)) {
                     //CCLOG(@"Intersection segTop at %f, %f", startIntersectionPoint.x, startIntersectionPoint.y);
                    
                } else if (getLineIntersectionPoint(segBottom, origLine, &startIntersectionPoint)) {
                     //CCLOG(@"Intersection segBottom at %f, %f", startIntersectionPoint.x, startIntersectionPoint.y);
        
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
            BOOL didIntersect = NO; // Try to prove assumption wrong
            CGPoint startIntersectionPoint = ccp(0,0);
            LineSegment origLine = createLineSegment(startPoint, endPoint);
            event = [[TerCollisionEvent alloc] initWithCollisionEventFor:dTer startInter:NO endInter:NO];
            
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
                //CCLOG(@"Intersection segLeft at %f, %f", startIntersectionPoint.x, startIntersectionPoint.y);
                didIntersect = YES;
                event.startPoint = startIntersectionPoint;
            }
            
            if (getLineIntersectionPoint(segRight, origLine, &startIntersectionPoint)) {
                //CCLOG(@"Intersection segRight at %f, %f", startIntersectionPoint.x, startIntersectionPoint.y);
                if (didIntersect) { event.endPoint = startIntersectionPoint; }
                else { event.startPoint = startIntersectionPoint; didIntersect = YES; }
                
            }
            
            if (getLineIntersectionPoint(segTop, origLine, &startIntersectionPoint)) {
                //CCLOG(@"Intersection segTop at %f, %f", startIntersectionPoint.x, startIntersectionPoint.y);
                if (didIntersect) { event.endPoint = startIntersectionPoint; }
                else { event.startPoint = startIntersectionPoint; didIntersect = YES; }
            }
            
            if (getLineIntersectionPoint(segBottom, origLine, &startIntersectionPoint)) {
                //CCLOG(@"Intersection segBottom at %f, %f", startIntersectionPoint.x, startIntersectionPoint.y);
                if (didIntersect) { event.endPoint = startIntersectionPoint; }
                else { event.startPoint = startIntersectionPoint; didIntersect = YES; }
            }
            
            if (didIntersect) {
                [colList addObject:event];
            } 
                           
        } // end not event
        
    } // end for
    
    /* Testing collision count :: Uncomment if you wish for testing
    if ([colList count] == 0) {
        CCLOG(@"DestTerrainSystem--> There are no terrain objects that intersect with the given points");
    } else {
        CCLOG(@"DestTerrainSystem--> There are %d terrain objects that intersect with the given points", [colList count]);
    } // end if
    */
    
    return colList;
} // endGetTerrainCollisionList


#pragma mark Helper Methods
#pragma mark -

-(void)createTerrainDict {
    if (!self.terrainPieces) {
        self.terrainPieces = [[NSMutableDictionary alloc] init];
    } // end if
} // end createTerrainDict

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
    self.applyAfterDraw = applyAtEachDraw;
    
} // end setApplyAtEachDraw

@end

