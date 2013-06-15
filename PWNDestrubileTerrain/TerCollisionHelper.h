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
    
    BOOL didCollide;
    CGPoint colPoint;
    
} CollisionData;

typedef struct {
    
    CGPoint startPoint;
    CGPoint endPoint;
    
} LineSegment;

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



/*
 TODO:: Implement this algorithm
 http://martin-thoma.com/how-to-check-if-two-line-segments-intersect/
 http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
 
 // Returns 1 if the lines intersect, otherwise 0. In addition, if the lines
 // intersect the intersection point may be stored in the floats i_x and i_y.
 
 char get_line_intersection(float p0_x, float p0_y, float p1_x, float p1_y,
 float p2_x, float p2_y, float p3_x, float p3_y, float *i_x, float *i_y)
 {
 float s1_x, s1_y, s2_x, s2_y;
 // This converting to vectors?
 s1_x = p1_x - p0_x;     s1_y = p1_y - p0_y;
 s2_x = p3_x - p2_x;     s2_y = p3_y - p2_y;
 
 float s, t;
 s = (-s1_y * (p0_x - p2_x) + s1_x * (p0_y - p2_y)) / (-s2_x * s1_y + s1_x * s2_y);
 t = ( s2_x * (p0_y - p2_y) - s2_y * (p0_x - p2_x)) / (-s2_x * s1_y + s1_x * s2_y);
 
 if (s >= 0 && s <= 1 && t >= 0 && t <= 1)
 {
 // Collision detected
 if (i_x != NULL)
 *i_x = p0_x + (t * s1_x);
 if (i_y != NULL)
 *i_y = p0_y + (t * s1_y);
 return 1;
 }
 
 return 0; // No collision
 }
 
 // Alternative
 int get_line_intersection(float p0_x, float p0_y, float p1_x, float p1_y,
 float p2_x, float p2_y, float p3_x, float p3_y, float *i_x, float *i_y)
 {
 float s02_x, s02_y, s10_x, s10_y, s32_x, s32_y, s_numer, t_numer, denom, t;
 s10_x = p1_x - p0_x;
 s10_y = p1_y - p0_y;
 s32_x = p3_x - p2_x;
 s32_y = p3_y - p2_y;
 
 denom = s10_x * s32_y - s32_x * s10_y;
 if (denom == 0)
 return 0; // Collinear
 bool denomPositive = denom > 0;
 
 s02_x = p0_x - p2_x;
 s02_y = p0_y - p2_y;
 s_numer = s10_x * s02_y - s10_y * s02_x;
 if ((s_numer < 0) == denomPositive)
 return 0; // No collision
 
 t_numer = s32_x * s02_y - s32_y * s02_x;
 if ((t_numer < 0) == denomPositive)
 return 0; // No collision
 
 if (((s_numer > denom) == denomPositive) || ((t_numer > denom) == denomPositive))
 return 0; // No collision
 // Collision detected
 t = t_numer / denom;
 if (i_x != NULL)
 *i_x = p0_x + (t * s10_x);
 if (i_y != NULL)
 *i_y = p0_y + (t * s10_y);
 
 return 1;
 }
 
 */


#endif
