//
//  TerCollisionHelper.h
//  PWNDestructibleTerrain
//
//  Created by Paul Renton on 6/12/13.
//
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>



#ifndef PWNDestructibleTerrain_TerCollisionHelper_h
#define PWNDestructibleTerrain_TerCollisionHelper_h


#define EPSILON 0.000001

typedef struct {
    
    CGPoint colPointStart;
    CGPoint colPointEnd;
    
} CollisionData;

typedef struct {
    
    CGPoint startPoint;
    CGPoint endPoint;
    
} LineSegment;


CollisionData createCollisionData(CGPoint start, CGPoint end) {
    
    CollisionData colData;
    colData.colPointStart = start;
    colData.colPointEnd = end;
    return colData;
    
} // end createCollisionData

LineSegment createLineSegment(CGPoint start, CGPoint end) {
    /* Convenience method to initialize linesegment struct */
    LineSegment seg;
    seg.startPoint = start;
    seg.endPoint = end;
    return seg;
} // end createLineSeg

double crossProduct(CGPoint a, CGPoint b) {
    /*  Convenience function for cross product */
    double crossProdResult = (a.x * b.y) - (b.x * a.y);
    return crossProdResult;
} // end crossProduct


bool doLineBoundingBoxesIntersect(LineSegment lineOne, LineSegment lineTwo) {
    /*
     Checks if two line bounding boxes intersect
     */
    return lineOne.startPoint.x <= lineTwo.endPoint.x &&
        lineOne.endPoint.x >= lineTwo.startPoint.x &&
        lineOne.startPoint.y <= lineTwo.endPoint.y &&
        lineOne.endPoint.y >= lineTwo.startPoint.y;
    
} // end doLineBoundingBoxesIntersect

bool isPointOnLine(LineSegment line, CGPoint pointToCheck) {
    /*
     Use cross product to detect if the point is on the line
     */
     
    // Create a new line with startPoint at the origin
    LineSegment lineStartingAtOrigin = createLineSegment(ccp(0,0), ccp(line.endPoint.x - line.startPoint.x,
                                                       line.endPoint.y - line.startPoint.y));
    
    CGPoint tempPoint = ccp(pointToCheck.x - line.startPoint.x, pointToCheck.y - line.startPoint.y);
    
    double crossProd = crossProduct(lineStartingAtOrigin.endPoint, tempPoint);
    
    return fabs(crossProd) < EPSILON;
    
} // end isPoint onLine

bool isPointRightOfLine(LineSegment line, CGPoint pointToCheck) {
    /*
     Use cross product to detect is a point is to the right of a line or left
     left is positive and right if negative
     */
    LineSegment lineStartingAtOrigin = createLineSegment(ccp(0,0),
                                                         ccp(line.endPoint.x - line.startPoint.y, line.endPoint.y - line.startPoint.y));
    
    CGPoint tempPoint = ccp(pointToCheck.x - line.startPoint.x, pointToCheck.y - line.startPoint.y);
    
    return crossProduct(lineStartingAtOrigin.endPoint, tempPoint) < 0;
    
} // end isPointRightOfLine

bool lineSegmentTouchesOrCrossesLine(LineSegment lineOne, LineSegment lineTwo) {
    /*
     Note this considers end point or start point intersections to be potential crossing points
     Carrot ( ^ ) is the XOR bitwise operator
     */
    return isPointOnLine(lineOne, lineTwo.startPoint) ||
    isPointOnLine(lineOne, lineTwo.endPoint) ||
    (isPointRightOfLine(lineOne, lineTwo.startPoint) ^
     isPointRightOfLine(lineOne, lineTwo.endPoint));
    
} // end lineSegmentTouchesOrCrossesLine

bool doLinesIntersect(LineSegment lineOne, LineSegment lineTwo) {
    
    return doLineBoundingBoxesIntersect(lineOne, lineTwo) &&
        lineSegmentTouchesOrCrossesLine(lineOne, lineTwo) &&
        lineSegmentTouchesOrCrossesLine(lineTwo, lineOne);
    
} // end doLinesIntersect


bool getLineIntersectionPoint(LineSegment lineOne, LineSegment lineTwo, CGPoint * intersectionPoint) {
    /*
     Returns true if there is an intersection and modifies a past in LineSegment pointer
     This is more optimized but less descriptive of why there is or is not a collision
     Use this if you don't care about details on intermediate steps and want the added
     calculations involved for determining the intersection point between the two lines
     
     See this article for a good description of the algor (see posts towards bottom)
     http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
     
     */
    
    float s10_x, s10_y; // Vector components for first line
    float s32_x, s32_y; // Vector components for second line
    
    // Get 2D vector components for lineOne
    s10_x = lineOne.endPoint.x - lineOne.startPoint.x;
    s10_y = lineOne.endPoint.y - lineOne.startPoint.y;
    
    // Get 2D vector components for lineTwo
    s32_x = lineTwo.endPoint.x - lineTwo.startPoint.x;
    s32_y = lineTwo.endPoint.y - lineTwo.startPoint.y;
    
    double denom = crossProduct(ccp(s10_x,s10_y), ccp(s32_x, s32_y));
    if (denom == 0) {
        CCLOG(@"The two lines are colinear");
        return false; // Colinear
    } // end if
    
    bool denomPositive = denom > 0; // denom can't be 0 at this point
    
    float s02_x, s02_y;
    float s_numer;
    
    s02_x = lineOne.startPoint.x - lineTwo.startPoint.x;
    s02_y = lineOne.startPoint.y - lineTwo.startPoint.y;
    
    s_numer = crossProduct(ccp(s10_x, s10_y), ccp(s02_x, s02_y));
    
    if ((s_numer < 0) && denomPositive) {
        CCLOG(@"Failed on s_numer");
        return false; // no collision
    } // end if
    
    float t_numer;
    
    t_numer = crossProduct(ccp(s32_x, s32_y), ccp(s02_x, s02_y));
    
    if ((t_numer < 0) == denomPositive) {
        CCLOG(@"failed on t_numer");
        return false; // no collision
    } // end if
    
    if (((s_numer > denom) == denomPositive) ||
        ((t_numer > denom) == denomPositive)) {
        CCLOG(@"Failed on s and t");
        return false; // no collision
    } // end if
    
    // Collision detected if it gets this far
    float t;
    t = t_numer / denom; // Remember it is impossible for denom to be 0 at this point
    
    if (intersectionPoint) {
        // Get the intersection points
        intersectionPoint->x = lineOne.startPoint.x + (t * s10_x);
        intersectionPoint->y = lineOne.startPoint.y + (t * s10_y);
    } // end if
    
    return true;
    
} // end getLineIntersectionPoints




#endif
