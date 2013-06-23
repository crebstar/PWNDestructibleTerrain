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
    
    CGPoint tankPOS = tankSprite.position;
    
    CGPoint tankColPoint = ccp(tankSprite.position.x, tankSprite.position.y);
    
    ccColor4B color = ccc4(0, 0, 0, 0);
    BOOL touchedGround = YES;
    if ([destTerrainSystem pixelAt:tankColPoint colorCache:&color]) {
        if (color.a == 0) {
            tankPOS.y -= 2;
            touchedGround = NO;
        }
    } else {
        tankPOS.y -= 2;
        touchedGround = NO;
    }
    
    if (touchedGround) {
        tankPOS.x += 1.00f;
    }
    
    CGPoint rightWall = ccp(tankPOS.x, tankPOS.y + 2);
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
    
    if (touchedGround) {
        CCLOG(@"Tank touched ground.. calculating normal");
        float avgX = 0;
        float avgY = 0;
       // CGPoint centerPoint = ccp(tankSprite.position.x + tankSprite.contentSize.width*0.50f, tankSprite.position.y + (2 * tankSprite.contentSize.height));
        ccColor4B color = ccc4(0, 0, 0, 0);
        for (int x = 25; x >=-25; x--) {
            for (int y = 25; y >=-25; y--) {
                CGPoint pixPt = ccp(x + tankColPoint.x, y + tankColPoint.y);
                if ([destTerrainSystem pixelAt:pixPt colorCache:&color]) {
                    if (color.a != 0) {
                        avgX -= x;
                        avgY -= y;
                    }
                }
            }
        }
        CCLOG(@"avgX is %f   and avgY is %f", avgX, avgY);
        float len = sqrtf(avgX * avgX + avgY * avgY);
        if (len == 0) len = 1;
        CGPoint normal = ccp(avgX / len, avgY / len);
        CCLOG(@"The normal is %f, %f", normal.x, normal.y);
    
        float angle = ccpDot(ccp(1,0), normal);
        
        tankSprite.rotation = (angle * 100);
        CCLOG(@"angle is %f", angle);
        
        
    } // end if
    
    
    
    /*
    if (touchedGround) {
        CCLOG(@"Tank touched ground.. calculating normal");
        NSMutableArray * vecPts = [[NSMutableArray alloc] init];
        // CGPoint centerPoint = ccp(tankSprite.position.x + tankSprite.contentSize.width*0.50f, tankSprite.position.y + (2 * tankSprite.contentSize.height));
        ccColor4B color = ccc4(0, 0, 0, 0);
        for (int x = 20; x >=-20; x--) {
            for (int y = 20; y >= -20; y--) {
                CGPoint pixPt = ccp(x + tankColPoint.x, y + tankColPoint.y);
                if ([destTerrainSystem pixelAt:pixPt colorCache:&color]) {
                    if (color.a != 0) {
                        [vecPts addObject:[NSValue valueWithCGPoint:pixPt]];
                    }
                }
            }
        }
    
    if (vecPts.count > 0) {
        float xSum = 0;
        float ySum = 0;
        float avgX = 0;
        float avgY = 0;
        float len = 0;
        
        for (NSValue * val in vecPts) {
            xSum += val.CGPointValue.x;
            ySum += val.CGPointValue.y;
        }
        
        avgX = xSum/vecPts.count;
        avgY = ySum/vecPts.count;
        CCLOG(@"Average x: %f, Average y %f", avgX, avgY);
        len = sqrtf(avgX * avgX + avgY * avgY);
        CGPoint normal = ccp(avgX/len, avgY/len);
        CCLOG(@"The normal is %f, %f", normal.x, normal.y);
    }
    } // end if
    */
    
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
