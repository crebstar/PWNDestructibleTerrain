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
#import "CCMutableTexture2D.h"



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
        [destTerrainSystem setApplyAfterDraw:YES];
        
        // consider z value as well
        DestTerrain * ter1 = [destTerrainSystem createDestTerrainWithImageName:@"fullscreenground.png" withID:0];
        DestTerrain * ter2 = [destTerrainSystem createDestTerrainWithImageName:@"fullscreenground.png" withID:1];
        
        ter1.position = ccp(100,0);
        
        ter2.position = ccp(ter1.contentSize.width + 100,0);
        
        [self addChild:ter1];
        [self addChild:ter2];
        
        self.isTouchEnabled = YES;
        
        [destTerrainSystem drawCircle:ccp(300,100) withRadius:30.0f withColor:ccc4(0, 0, 0, 0)];
        [destTerrainSystem drawSquare:ccp(500,100) withRadius:30.0f withColor:ccc4(0, 0, 0, 0)];
        
        [destTerrainSystem drawCircle:ccp(110,0) withRadius:50.0f withColor:ccc4(0, 0, 0, 0)];
        
        // Note must grab texture from the sprite itself meaning it is pointless to hold a pointer to it
        
        // TESTS BELOW
        
        //[destTerrainSystem drawLineFrom:ccp(100,50) endPoint:ccp(550, 300) withWidth:30.0f withColor:ccc4(0, 0, 0, 0)];
        
        
        /*
        ter1.position = ccp(0,200);
        [ter1 drawLineFrom:ter1.position
                  endPoint:ccp(ter1.position.x + ter1.contentSize.width,
                               ter1.position.y + ter1.contentSize.height)
                 withWidth:20.0f
                 withColor:ccc4(0, 0, 0, 0)];
        
        */
        /*
        for (int i = 0; i < 240; i++) {
            
            [ter1 drawHorizontalLine:0.0f xEnd:160.0f y:(ter1.position.y + i) withColor:ccc4(0, 0, 0, 0)];
            
        }
         */
        
        /*
        for (int i = 0; i < 160; i++) {
            
            [ter1 drawVerticalLine:self.position.y yEnd:self.position.y + self.contentSize.height/2 x:i withColor:ccc4(0, 0, 0, 0)];
            
        }
         */
        
        /*
        for (int i = 0; i < 200; i++) {
            
            [ter1 drawVerticalLineFromPointToTopEdge:self.position.y + self.contentSize.width/3 atX:i withColor:ccc4(0, 0, 0, 0)];
            
        }
        */
        
        
        [self scheduleUpdate];
    } // end if
    
    return self;
    
} // end init


#pragma mark update
#pragma mark -

-(void)update:(ccTime)dt {
    
   
    
} // end update

/*
-(void)fingerAction:(CGPoint)startPoint :(CGPoint)currentPoint {
    
    //
    // startPoint is the original touch location
    // currentPoint is the current touch location
    
    // Create pointer to ground for size calculations?
    CCSprite *sprite=[grounds objectAtIndex:0];
    
    //Find which strips of ground are invovled
    float maxY,minY;
    
    if (currentPoint.y < startPoint.y) {
        // The current touch location is below start touch location
        minY = currentPoint.y - (int) (DRAW_WIDTH * GROUND_SCALE + 0.5f);
        maxY = startPoint.y + (int) (DRAW_WIDTH * GROUND_SCALE + 0.5f);
        
    } else {
        // The current touch location is above the start touch location
        minY = startPoint.y - (int) (DRAW_WIDTH * GROUND_SCALE + 0.5f);
        maxY = currentPoint.y + (int) (DRAW_WIDTH * GROUND_SCALE + 0.5f);
        
    } // end if
    
    float groundHeight = sprite.contentSize.height*sprite.scaleY;
    float offsetMin=(sprite.position.y + groundHeight/2) - minY;
    
    // Restrict min index to be within ground array bounds
    int idxMin=offsetMin/groundHeight;
    if (idxMin<0) idxMin=0;
    if (idxMin >= grounds.count) idxMin=grounds.count-1;
    
    // Restrict max index to be within ground array bounds
    float offsetMax = (sprite.position.y + groundHeight/2)-maxY;
    int idxMax=offsetMax/groundHeight;
    if (idxMax<0) idxMax=0;
    if (idxMax>=grounds.count) idxMax=grounds.count-1;
    
    // At this point we have the index values for the ground segments involved
    

    
    for (int i=idxMax; i<=idxMin; i++) {
        sprite=[grounds objectAtIndex:i];
        // For each ground segment

        // sprite = groundSprite
        
        // CURRENT TOUCH POINT
        // These contentSize.height/2 calculations aren't needed if we use anchor point of 0,0
        CGPoint local = ccp(currentPoint.x, (currentPoint.y - sprite.position.y) + sprite.contentSize.height/2);
        local.y = sprite.contentSize.height-local.y;
        
        // START TOUCH POINT
        CGPoint activeLocal = ccp(startPoint.x , (startPoint.y - sprite.position.y) + sprite.contentSize.height/2);
        activeLocal.y = sprite.contentSize.height-activeLocal.y;
        
        // Draw line with width (currentColor has an alpha value of 0)
        CCMutableTexture2D* groundMutableTexture=(CCMutableTexture2D*)(sprite.texture);
        [groundMutableTexture drawLineFrom:activeLocal to:local withLineWidth:DRAW_WIDTH andColor:currentColor];
        [groundMutableTexture apply]; //Redraw texture
    }
}
*/


#pragma mark Touch Methods
#pragma mark -

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    /*
     This simple time restriction is here for performance.
     I am not noticing any dips in performance at the moment
     I might try to push it more later with a smaller time interval
     */
	UITouch *touch;
	NSArray *allTouches = [[event allTouches] allObjects];
    
	double now=[NSDate timeIntervalSinceReferenceDate];
    //Draw only every 0.05 seconds to preserve the performance
	if (now-lastDigTime>0.05f) {
		touch=[touches anyObject];
        
		CGPoint touchLocation = [touch locationInView:nil];
		touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
        
                    // activeLocation = original start of the touch
            // touchLocation is the current touch spot
        
        //[self fingerAction:activeLocation :touchLocation];
        
        lastDigTime=now;
		
		activeLocation=touchLocation;
       
	}
}



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
