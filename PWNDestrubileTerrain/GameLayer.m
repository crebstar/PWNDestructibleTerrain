//
//  GameLayer.m
//  DestructibleGround
//
//  Created by Jean-Philippe SARDA on 11/20/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

// This is the URL where I found the original source
// http://www.cocos2d-iphone.org/pixel-based-destructible-ground-with-cocos2d/comment-page-1/#comment-198110

// Import the interfaces
#import "GameLayer.h"
#import "CreditsLayer.h"
#import "CCMutableTexture2D.h"


#define GROUND_SCALE 1 // originally was set as 2 for perf reasons but I see no difference with non scaling
#define DRAW_WIDTH 6.5f
#define MINERS_COUNT 20
#define SHOW_DRAWN_GROUND_STRIPES


@interface GameLayer(Private)
-(void)appendNewGround;
-(void)resetGroundColors;
-(void)editTerrain;
-(void)addRedAlphaTerrain;
@end

// GameLayer implementation
@implementation GameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        // ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        //Enable touches
        self.isTouchEnabled=YES;
        
        grounds=[NSMutableArray arrayWithCapacity:4];
        miners=[NSMutableArray arrayWithCapacity:MINERS_COUNT];
        
        [self appendNewGround]; // TOP OF SCREEN
        
        //[self appendNewGround];
        //[self appendNewGround];
        //[self appendNewGround]; // BOTTOM OF SCREEN
        //[self addRedAlphaTerrain];
        
        //[self editTerrain];
        
#ifdef SHOW_DRAWN_GROUND_STRIPES
        [self resetGroundColors];
#endif
        
        //Add miners
        for (int i=0;i<MINERS_COUNT;i++) {
            //CCLOG(@"Adding miner.png as texture for CCSprite");
            CCSprite *miner=[CCSprite spriteWithFile:@"miner.png"];
            miner.position=ccp(20+(size.width-40)*((float)i+1.0f)/((float)(MINERS_COUNT+1)),size.height-60);
            [self addChild:miner];
            [miners addObject:miner];
        }
        
	
        
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Dig with your finger" fontName:@"Marker Felt" fontSize:24];
		label.position =  ccp( size.width /2 , size.height-14 );
		[self addChild: label];
        
        
        //Promo Micro Miners :D
        
        CCSprite *microminersIcon=[CCSprite spriteWithFile:@"info.png"];
        CCSprite *microminersIconSelected=[CCSprite spriteWithFile:@"info.png"];
        microminersIconSelected.color=ccc3(100, 100, 100);
        CCMenuItem *microminersItem=[CCMenuItemSprite itemFromNormalSprite:microminersIcon selectedSprite:microminersIconSelected target:self selector:@selector(info)];
        microminersItem.position=ccp(size.width-microminersItem.contentSize.width*0.5f-4,microminersItem.contentSize.height*0.5f+4);
        CCMenu *menu=[CCMenu menuWithItems:microminersItem, nil];
        menu.position=CGPointZero;
        [self addChild:menu];
        
        lastDigTime=0;
        touchActiveLocationOK=NO;
        
        
        // Schedule call for updates
        [self schedule:@selector(tick:)];
	}
	return self;
}
// on "dealloc" you need to release all your retained objects


-(void)appendNewGround {
    
    /*
     TODO :: Consider setting anchor point to 0,0 to simplify positioning
     
     (Crebstar's observations)
     *** Steps for simple ground creation **
     Important to note the current engine only has a working demo for iPhone Non Retina
     
     1) A UIImage with the image used for the sprite is created and then added to the CCMutableTexture2D (Extends Texture 2D)
     Note :: Very important fact that CCMutableTexture2D does NOT extend CCNode
     
     2) A CCSprite is then created with the factory method 'spriteWithTexture' accepting an instance of CCMutableTexture2D
     3) Each ground sprite image is 160 by 60 and is scaled to be 2x in order to simplify calculations and maintain a 60 FPS
     
     4) The first ground sprite is rendered at the top and the rest built relatively off the one above it
     */
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    float y=size.height;
    
    // Original
    //UIImage *image = [UIImage imageNamed:@"ground_vertical.png"];
    
    //Test a different texture with more detail (Comment out above and uncomment below)
    //UIImage *image = [UIImage imageNamed:@"grounddetailed.png"];
    
    // Test a different texture with more detail and larger (Comment out above and uncomment below)
    //UIImage *image = [UIImage imageNamed:@"grounddetailfull.png"];
    
    // Full screen ground. Only use with one call to this method
    UIImage *image = [UIImage imageNamed:@"fullscreenground.png"];

    CCMutableTexture2D *groundMutableTexture = [[CCMutableTexture2D alloc] initWithImage:image];
    [groundMutableTexture setAliasTexParameters];
    CCSprite *groundSprite = [CCSprite spriteWithTexture:groundMutableTexture];
    groundSprite.scale=GROUND_SCALE;
    if (grounds.count!=0) {
        // Draw relative to the previously rendered ground sprite
        // position will change based on anchor point (consider 0,0)
        y=((CCSprite*)([grounds lastObject])).position.y-groundSprite.contentSize.height*groundSprite.scaleY;
    } else {
        // If this is the first ground to be drawn
        // Mult by 0.5 b/c anchor isn't 0,0
        y-=groundSprite.contentSize.height*groundSprite.scaleY*0.5f;
    }
    // I suppose the 0.5f because anchor isn't 0,0
    float x = size.width*0.5f;
    groundSprite.position=ccp(x,y);
    [self addChild:groundSprite];
    [grounds addObject:groundSprite];
    
    
    CCLOG(@"GameLayer--> Ground added with x , y :: %f, %f",x,y);
    CCLOG(@"GameLayer--> Ground has a scale of x , y :: %f , %f", groundSprite.scaleX,groundSprite.scaleY);
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"grounds [ %d ]",grounds.count-1] fontName:@"Marker Felt" fontSize:13];
    label.rotation=90;
    label.position =  ccp( label.contentSize.height*0.5f +2, groundSprite.position.y);
    [self addChild: label];
}





-(void)tick:(ccTime)dt {
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    for (int i=0;i<miners.count;i++) {
        // For Each minor sprite
        CCSprite *miner=[miners objectAtIndex:i];
        
        // Grab a cache of the position and modify it for potential use
        CGPoint minerPosition=miner.position;
        minerPosition.y-=2;
        
        //Check if hits the ground
        
        // Grab the first ground sprite
        CCSprite *sprite=[grounds objectAtIndex:0];
        
        //Found corresponding strip of ground
        float groundHeight = sprite.contentSize.height * sprite.scaleY;
        
        // Size is the size of the screen or in this case the size of the level
        // This simple math determines which block of terrain we are concerned with
        int idxGround = (size.height - minerPosition.y)/groundHeight; // This will round up
        
        if ((idxGround >= 0) && (idxGround < grounds.count)) {
            
            sprite=[grounds objectAtIndex:idxGround];
            
            CCMutableTexture2D* groundMutableTexture = (CCMutableTexture2D*) (sprite.texture);
            
            // Transform real world position into texture position
            // Top border of the texture y = sprite.position.y + groundHeight*0.5f
            // TODO :: Consider how changing anchor position to 0,0 would effect this calculation
            
            // Note :: ccColor4B is a struct holding GLubyte data representing the colors ARGB
            
                                                                // Grab the miners x-axis position          // Top of texture is y position + half height since anchor is mid point
            ccColor4B pixel = [groundMutableTexture pixelAt:ccp( (int) (minerPosition.x/GROUND_SCALE), (int) (((sprite.position.y + groundHeight * 0.5f) - minerPosition.y)/GROUND_SCALE))];
            
            
            if (pixel.a==0) {
                //No hit, we update the miners position
                miner.position=minerPosition;
            }
        }
    }
}





- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch=[touches anyObject];
    currentColor=ccc4(0,0,0,0); //Transparent >> Draw holes (dig)
	CGPoint touchLocation = [touch locationInView:nil];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];

	activeLocation=touchLocation;
    touchActiveLocationOK=YES;
}
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
        
        if (touchActiveLocationOK) {
            // activeLocation = original start of the touch
            // touchLocation is the current touch spot
            [self fingerAction:activeLocation :touchLocation];
            lastDigTime=now;
		}
		activeLocation=touchLocation;
        touchActiveLocationOK=YES;
	}
}

-(void) resetGroundColors {
    for (int i=0; i<grounds.count; i++) {
        CCSprite *sprite=[grounds objectAtIndex:i];
        if (i%2==0) {
            sprite.color=ccc3(255, 210, 230);
        } else {
            sprite.color=ccc3(255, 230, 210);
        }
    }
}

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
    
    //This for a visual representation of impacted grounds
#ifdef SHOW_DRAWN_GROUND_STRIPES
    [self resetGroundColors];
#endif
    
    for (int i=idxMax; i<=idxMin; i++) {
        sprite=[grounds objectAtIndex:i];
        // For each ground segment
#ifdef SHOW_DRAWN_GROUND_STRIPES
        if (i%2==0) {
            sprite.color=ccc3(255, 110, 130);
        } else {
            sprite.color=ccc3(255, 130, 110);
        }
#endif
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

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
#ifdef SHOW_DRAWN_GROUND_STRIPES
    [self resetGroundColors];
#endif
}
- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self ccTouchesEnded:touches withEvent:event];
}

-(void)info {
    [[CCDirector sharedDirector] replaceScene:[CreditsLayer scene]];
}

-(void)editTerrain {
    
    // Reference
    // ccColor4B pixel = [groundMutableTexture pixelAt:ccp( (int) (minerPosition.x/GROUND_SCALE), (int) (((sprite.position.y + groundHeight * 0.5f) - minerPosition.y)/GROUND_SCALE))];
    
    CCSprite * groundSprite = [grounds objectAtIndex:1]; // 2nd from top
    
    CCMutableTexture2D * tex = (CCMutableTexture2D*) [groundSprite texture];
    currentColor=ccc4(0,0,0,0); //Transparent >> Draw holes (dig)
    
    for (int i = 0; i < 160; i++) {
        
        [tex drawHorizontalLine:0 :100 :i withColor:currentColor];
        //[tex drawVerticalLine:0 endY:60.0f atX:i withColor:currentColor];
        //[tex drawVerticalLineFromPointToTopEdge:120.0f atX:i withColor:currentColor];
    }
    
    [tex apply];
    
    currentColor = ccc4(125, 50, 100, 255);
    
    for (int i = 0; i < 60; i++) {
        
        [tex drawHorizontalLine:0 :100 :i withColor:currentColor];
        
    }
    
    [tex apply];
    
} // end editTerrain


-(void)addRedAlphaTerrain {
    
    UIImage * textureImage = [UIImage imageNamed:@"alphatest.png"];
    CCMutableTexture2D * mutText = [CCMutableTexture2D textureWithImage:textureImage];
    [mutText setAliasTexParameters];
    CCSprite * redTerrain = [CCSprite spriteWithTexture:mutText];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    float y=size.height;

    
    if (grounds.count!=0) {
        // Draw relative to the previously rendered ground sprite
        // position will change based on anchor point (consider 0,0)
        y=((CCSprite*)([grounds lastObject])).position.y-redTerrain.contentSize.height;
    } else {
        // If this is the first ground to be drawn
        // Mult by 0.5 b/c anchor isn't 0,0
        y-=redTerrain.contentSize.height;
    }
    
    // I suppose the 0.5f because anchor isn't 0,0
    float x = size.width*0.5f;

    
    redTerrain.position = ccp(x,y);
    [self addChild:redTerrain];
    [grounds addObject:redTerrain];
    
} // end addRed

@end
