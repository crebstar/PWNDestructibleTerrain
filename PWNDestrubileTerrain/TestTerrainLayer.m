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

// TODO
// rewrite collapse to go from bottom up
// HAve collapse move one pixel at a time over time to simulate collapsing effect with gravity
// Only collapse when it is being altered and have each game loop iter move a pixel down at a time
// have a bollean for collapsing and an outside function calling an inside function

// Consider having tank's angle only calculated with how the tank edges touch the surface


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
        
        tankCol = [CCSprite spriteWithFile:@"Earth_Tank.png"];
        tankCol.position = ccp(900,600);
        [self addChild:tankCol];
        
        // consider z value as well
        DestTerrain * ter1 = [destTerrainSystem createDestTerrainWithImageName:@"fullscreenground.png" withID:0];
        DestTerrain * ter2 = [destTerrainSystem createDestTerrainWithImageName:@"fullscreenground.png" withID:1];
        DestTerrain * ter3 = [destTerrainSystem createDestTerrainWithImageName:@"grounddetailfull.png" withID:3];
        
        ter1.position = ccp(100,0);
        
        ter2.position = ccp(ter1.contentSize.width + 100,0);
        
        ter3.position = ccp(ter1.contentSize.width * 2 + 100,0);
        
        [self addChild:ter1 z:1];
        [self addChild:ter2 z:2];
        [self addChild:ter3 z:3];
        
        self.isTouchEnabled = YES;
        
        [destTerrainSystem drawCircle:ccp(300,100) withRadius:30.0f withColor:ccc4(0, 0, 0, 0)];
        [destTerrainSystem drawSquare:ccp(500,100) withRadius:30.0f withColor:ccc4(0, 0, 0, 0)];
        
        [destTerrainSystem drawCircle:ccp(110,0) withRadius:50.0f withColor:ccc4(0, 0, 0, 0)];
        
        [destTerrainSystem drawLineFrom:ccp(50,200) endPoint:ccp(900, 200) withWidth:20.0f withColor:ccc4(0, 0, 0, 0)];
        
        tankSprite = [CCSprite spriteWithFile:@"Earth_Tank.png"];
        CCLOG(@"Tank content size width = %f", tankSprite.contentSize.width * 0.50f);
        tankSprite.anchorPoint = ccp(0.50f, 0);
        tankSprite.position = ccp(125,700);
        [self addChild:tankSprite z:10];
        
        [destTerrainSystem drawCircle:ccp(300,479) withRadius:30.0f withColor:ccc4(0, 0, 0, 0)];
        
        //[destTerrainSystem collapseAllTerrain];
        
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
    
    // This logic block should be handled in the sprite class
    CGPoint tankPOS = tankSprite.position;
    
    CGPoint tankColPoint = ccp(tankSprite.position.x, tankSprite.position.y);
    
    ccColor4B color = ccc4(0, 0, 0, 0);
    BOOL touchedGround = YES;
    if ([destTerrainSystem pixelAt:tankColPoint colorCache:&color]) {
        if (color.a == 0) {
            tankPOS.y -= 1;
            touchedGround = NO;
        }
    } else {
        tankPOS.y -= 1;
        touchedGround = NO;
    }
    
    if (touchedGround) {
        tankPOS.x += 0.75f;
    }
    
    // can this be moved to dest terrain system?
    // or is this logic belonging in the sprite
    // Leaning towards it belonging to sprite
    CGPoint rightWall = ccp(tankPOS.x, tankPOS.y + 1);
    if ([destTerrainSystem pixelAt:rightWall colorCache:&color]) {
        if (color.a != 0) {
            int count = 0;
            while (color.a != 0) {
                count++;
                if (count > 20) break;
                if (!([destTerrainSystem pixelAt:ccp(tankPOS.x, tankPOS.y + count) colorCache:&color])) {
                    color.a = 0;
                }
            }
            CCLOG(@"count is %d", count);
            if (!(count > 20)) {
                tankPOS.y += count;
            } else {
                tankPOS.x -= 1;
            }
        }
        
    }
    
    tankSprite.position = tankPOS;
    
    // need to test moving in both directions
    if (touchedGround) {
        float angle;
        CGPoint normal = [destTerrainSystem getAverageSurfaceNormalAt:tankColPoint
                                                             withRect:CGRectMake(0, 0, 23, 23)];
        angle = 100 * ccpDot(ccp(1,0), normal);
        if (angle < -75) {
            tankSprite.rotation = -75;
        } else {
            tankSprite.rotation = angle;
        }
        CCLOG(@"angle is %f", angle);
    } // end if
    
} // end update

#pragma mark Touch Methods
#pragma mark -

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    /*
     This simple time restriction is here for performance.
     I am not noticing any dips in performance at the moment
     I might try to push it more later with a smaller time interval
     */
	UITouch *touch;
    
	double now=[NSDate timeIntervalSinceReferenceDate];
    //Draw only every 0.05 seconds to preserve the performance
	if (now-lastDigTime>0.05f) {
		touch=[touches anyObject];
        
		CGPoint touchLocation = [touch locationInView:[touch view]];
		touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
        touchLocation = [self convertToNodeSpace:touchLocation];
        [destTerrainSystem drawCircle:touchLocation withRadius:20.0f withColor:ccc4(0, 0, 0, 0)];
        lastDigTime=now;
		
		activeLocation=touchLocation;
       
	}
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch;
    touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    [destTerrainSystem drawCircle:touchLocation withRadius:20.0f withColor:ccc4(0, 0, 0, 0)];
    
    CGRect touchPoint = CGRectMake(touchLocation.x, touchLocation.y, 2.0f, 2.0f);
    if (CGRectIntersectsRect(touchPoint, tankCol.boundingBox)) {
        [destTerrainSystem collapseAllTerrain];
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
