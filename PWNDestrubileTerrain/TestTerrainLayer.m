//
//  TestTerrainLayer.m
//  PWNDestructibleTerrain
//
//  Created by Paul Renton on 6/8/13.
//
//

#import "TestTerrainLayer.h"

#import "DestTerrainSystem.h"
#import "DestTerrain.h"

@interface TestTerrainLayer ()
// Private Functions
-(BOOL)isRetina;

@end

@implementation TestTerrainLayer

@synthesize destTerrainSystem;

@synthesize isRetina;

-(id)init {
    
    self = [super init];
    
    if (self != nil) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCLOG(@"TestTerrainLayer-> Dimensions of screen are:  %f, %f", winSize.width, winSize.height);
        
        isRetina = [self isRetina];
        
        destTerrainSystem = [[DestTerrainSystem alloc] init];
        
        
        
        self.isTouchEnabled = YES;
        
        
        [self scheduleUpdate];
    } // end if
    
    return self;
    
} // end init


#pragma mark update
#pragma mark -

-(void)update:(ccTime)dt {
    
   
    
} // end update

#pragma mark protocol methods
#pragma mark -
-(void)updatePositionWithSystem:(CGPoint)positionOfTerrain {
    
    
    
}

#pragma mark helper functions
#pragma mark -
-(BOOL)isRetina {
    
    // Detect if this device is a Retina supported device
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        
        // We are dealing with a retina device
        isRetina = YES;
        CCLOG(@"TestTerrainLayer-> The device is a RETINA device.");
        
    } else {
        // We are dealing with a non retina device
        isRetina = NO;
        CCLOG(@"TestTerrainLayer-> The device is NOT A RETINA device");
    } // end if

} // end isRetina

@end
