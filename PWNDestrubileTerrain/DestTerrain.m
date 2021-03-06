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

@synthesize applyAfterDraw;

-(id)initWithIntID:(NSInteger)terrainID withImage:(UIImage*)image {
    // Should be the only init method one uses
    
    self.mutableTerrainTexture = [CCMutableTexture2D textureWithImage:image];
    
    self = [DestTerrain spriteWithTexture:mutableTerrainTexture];
    
    if (self != nil) {
        
        // Cache id for convenient access if need be
        terID = terrainID;
        applyAfterDraw = false;
        
    } // end if
    
    return self;
    
} // end initWithIntID

-(void)applyChanges {
    // For people who want more control
    CCMutableTexture2D * texture = (CCMutableTexture2D *) [self texture];
    [texture apply];
}

/*
 Convenience wrapper functions. Handles conversion of points from Cocos2D to point system used by CCMutableTexture2D.
 After the conversion it calls the appropriate functions. Use these if you don't want to deal with inconvenience of
 converting points. Otherwise, just typecast the sprite's texture to CCMutableTexture2D and make the conversions/calls
 yourself.
 */

-(void)drawLineFrom:(CGPoint)startPoint endPoint:(CGPoint)endPoint withWidth:(float)lineWidth withColor:(ccColor4B)color {
    /*
     A layer of abstraction from CCMutableTexture2D. This function handles the conversion of Cocos2D coordinates to the
     coordinate system used by the CCMutableTexture2D (Where positive y heads south). It will convert the Cocos2D points
     to points usable by CCMutableTexture2D then call the appropriate drawLine method of the CCMutableTexture for the sprite.
     This same description applies to the draw functions below this function
     
     Note: Important to remember all dest terrain sprites have an anchor point of 0,0
     TODO :: Consider doing a simple colission check to inform users if they are even drawing on correct terrain sprite
     */
        
    CGPoint localStartPoint; // Localize the startPoint parameter to be within coordinate system of the texture
    CGPoint localEndPoint; // Localize the endPoint parameter to be within the coordinate system of the texture
    
    float yStart = (self.contentSize.height - (startPoint.y - self.position.y));
    float yEnd = (self.contentSize.height - (endPoint.y - self.position.y));

    float xStart = (startPoint.x - self.position.x);
    float xEnd = (endPoint.x - self.position.x);
    
    localStartPoint = ccp(xStart, yStart);
    
    localEndPoint = ccp(xEnd, yEnd);
    
    CCMutableTexture2D * terrainTexture = (CCMutableTexture2D *) [self texture];
    
    CCLOG(@"Drawing line from local start %f, %f to localend point %f, %f", localStartPoint.x, localStartPoint.y, localEndPoint.x, localEndPoint.y);
    [terrainTexture drawLineFrom:localStartPoint to:localEndPoint withLineWidth:lineWidth andColor:color];
    
    if ([delegate shouldApplyAfterEachDraw] || self.applyAfterDraw) [terrainTexture apply];
    
} // endDrawLineFrom

-(void)drawHorizontalLine:(float)xStart xEnd:(float)xEnd y:(float)yF withColor:(ccColor4B)colorToApply {
   
    float localXStart = xStart - self.position.x;
    float localXEnd = xEnd - self.position.x;
    float localY =  self.contentSize.height - (yF - self.position.y);
    
    CCMutableTexture2D * terrainTexture = (CCMutableTexture2D *) [self texture];
    
    [terrainTexture drawHorizontalLine:localXStart :localXEnd :localY withColor:colorToApply];
    
    if ([delegate shouldApplyAfterEachDraw] || self.applyAfterDraw) [terrainTexture apply];
    
    
} // end drawHorizontalLine

-(void)drawVerticalLine:(float)yStart yEnd:(float)yEnd x:(float)xF withColor:(ccColor4B)colorToApply {
    
    float localYStart = self.contentSize.height - (yStart - self.position.y);
    float localYEnd = self.contentSize.height - (yEnd - self.position.y);
    float localX = xF - self.position.x;
    
    CCMutableTexture2D * terrainTexture = (CCMutableTexture2D *) [self texture];
    
    [terrainTexture drawVerticalLine:localYStart endY:localYEnd atX:localX withColor:colorToApply];
    
    if ([delegate shouldApplyAfterEachDraw] || self.applyAfterDraw) [terrainTexture apply];
    
} // end drawVerticalLine

-(void)drawVerticalLineFromPointToTopEdge:(float)yStart atX:(float)xF withColor:(ccColor4B)colorToApply {
    
    float localYStart = self.contentSize.height - (yStart - self.position.y);
    float localX = xF - self.position.x;
    
    CCMutableTexture2D * terrainTexture = (CCMutableTexture2D *) [self texture];
    
    [terrainTexture drawVerticalLineFromPointToTopEdge:localYStart atX:localX withColor:colorToApply];
    
    if ([delegate shouldApplyAfterEachDraw] || self.applyAfterDraw) [terrainTexture apply];
    
} // endDrawVerticalLineFromPointToTopEdge


-(void) drawCircle:(CGPoint)circleOrigin withRadius:(float)radius withColor:(ccColor4B)color {
    
    int localXOrigin = circleOrigin.x - self.position.x;
    int localYOrigin = self.contentSize.height - (circleOrigin.y - self.position.y);
    
    CCMutableTexture2D * terrainTexture = (CCMutableTexture2D *) [self texture];
    
    [terrainTexture drawCircle:ccp(localXOrigin, localYOrigin) withRadius:radius withColor:color];
    
    if ([delegate shouldApplyAfterEachDraw] || self.applyAfterDraw) [terrainTexture apply];
    
} // end drawCircle

-(void) drawSquare:(CGPoint)squareOrigin withRadius:(float)radius withColor:(ccColor4B)color {
    
    int localXOrigin = squareOrigin.x - self.position.x;
    int localYOrigin = self.contentSize.height - (squareOrigin.y - self.position.y);
    
    CCMutableTexture2D * terrainTexture = (CCMutableTexture2D *) [self texture];
    
    [terrainTexture drawSquare:ccp(localXOrigin, localYOrigin) withRadius:radius withColor:color];
    
    if ([delegate shouldApplyAfterEachDraw] || self.applyAfterDraw) [terrainTexture apply];
    
} // end drawSquare

-(void)createExplosion:(CGPoint)explosionOrigin withRadius:(float)radius withColor:(ccColor4B)color {
    
    int localXOrigin = explosionOrigin.x - self.position.x;
    int localYOrigin = self.contentSize.height - (explosionOrigin.y - self.position.y);
    
    CCMutableTexture2D * terrainTexture = (CCMutableTexture2D *) [self texture];
    
    [terrainTexture createExplosion:ccp(localXOrigin, localYOrigin) withRadius:radius withColor:color];
    
    if ([delegate shouldApplyAfterEachDraw] || self.applyAfterDraw) [terrainTexture apply];
    
}

- (ccColor4B) pixelAt:(CGPoint) pt {
    
    int localXOrigin = pt.x - self.position.x;
    int localYOrigin = self.contentSize.height - (pt.y - self.position.y);
    
    CCMutableTexture2D * terrainTexture = (CCMutableTexture2D *) [self texture];
    
    return [terrainTexture pixelAt:ccp(localXOrigin, localYOrigin)];
    
} // end pixelAt


-(void)collapseTerrain {
    
    CCMutableTexture2D * terrainTexture = (CCMutableTexture2D *) [self texture];
    [terrainTexture collapseAllPixels];
    if ([delegate shouldApplyAfterEachDraw] || self.applyAfterDraw) [terrainTexture apply];
    
}

-(bool)collapseSinglePixel {
    
    CCMutableTexture2D * terrainTexture = (CCMutableTexture2D *) [self texture];
    bool didCol =  [terrainTexture collapseSinglePixel];
    if ([delegate shouldApplyAfterEachDraw] || self.applyAfterDraw) [terrainTexture apply];
    return didCol;
    
}

#pragma mark Overrides
#pragma mark -



@end
