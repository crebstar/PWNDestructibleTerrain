//
//  TerCollisionEvent.h
//  PWNDestructibleTerrain
//
//  Created by Paul Renton on 6/16/13.
//
//

#import <Foundation/Foundation.h>



@class DestTerrain;


@interface TerCollisionEvent : NSObject {
    
    BOOL startIntersected;
    BOOL endIntersected;
    DestTerrain * ter;
    CGPoint startPoint;
    CGPoint endPoint;
    
} // end ivars


@property(nonatomic, readwrite) BOOL startIntersected;
@property(nonatomic, readwrite) BOOL endIntersected;
@property(nonatomic, readwrite) DestTerrain * ter;
@property(nonatomic, readwrite) CGPoint startPoint;
@property(nonatomic, readwrite) CGPoint endPoint;


-(id)initWithCollisionEventFor:(DestTerrain*)dTer startInter:(BOOL)startInter endInter:(BOOL)endInter;

-(void)addCollisionData:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

@end
