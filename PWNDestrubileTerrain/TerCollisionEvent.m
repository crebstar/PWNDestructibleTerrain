//
//  TerCollisionEvent.m
//  PWNDestructibleTerrain
//
//  Created by Paul Renton on 6/16/13.
//
//

#import "TerCollisionEvent.h"
#import "DestTerrain.h"

@interface TerCollisionEvent ()
// Private Functions

@end

@implementation TerCollisionEvent

@synthesize ter;
@synthesize startIntersected;
@synthesize endIntersected;
@synthesize startPoint, endPoint;

-(id)initWithCollisionEventFor:(DestTerrain*)dTer startInter:(BOOL)startInter endInter:(BOOL)endInter {
    // Note you can also set properties one by one. This is just for convenience. I was going to use a
    // C Struct for this but ARC won't let Objective-C objects exist within structs
    self = [super init];
    
    if (self != nil) {
        
        self.ter = dTer;
        self.startIntersected = startInter;
        self.endIntersected = endInter;
        
    } // end if
    
    return self;
    
} // end init

-(void)addCollisionData:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    
    self.startPoint = startPoint;
    self.endPoint = endPoint;
    
} // end addCollisionData

@end
