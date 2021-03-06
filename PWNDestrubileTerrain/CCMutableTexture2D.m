
///
//	All info located in header.
///
#import <OpenGLES/ES1/glext.h>
#import "CCMutableTexture2D.h"
#import "AsyncObject.h"

/*
 #import "EAGLView.h"
 #import "CCConfiguration.h"
 #import "ccMacros.h"
 #import "cocos2d.h"
 */
///
//	Fast find for powers of 2
///
bool IsPow2(uint v)
{
	return (v > 1) && ((v & (v - 1)) == 0);
}

///
//	Fast round to nearest power of 2 for 32-bit int's.
///
uint RoundToNearestPow2(uint v)
{
	//if(v < 32) return 32;
	if(v <= 1)return 2;
	v--;
	v |= v >> 1;
	v |= v >> 2;
	v |= v >> 4;
	v |= v >> 8;
	v |= v >> 16;
	v++;
	return v;
}

@implementation CCMutableTexture2D
@synthesize poly;
static EAGLContext *mutableTextureAuxEAGLcontext = nil;
+ (int) maxTextureSize
{
	return 1024;
}
-(void)commonInit {
	//Draw line polygon
	poly = calloc( sizeof(CGPoint) * CCMUTABLETEXTURE2D_LINE_POLY_COUNT, 1 );
}
- (id) initWithData:(const void*)data pixelFormat:(CCTexture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size
{
	if((self = [super initWithData:data pixelFormat:pixelFormat pixelsWide:width pixelsHigh:height contentSize:size])) {
		data_ = NULL;
		dirty_ = false;
	} else {
		[self commonInit];
	}
	return self;
}


- (void) dealloc
{
	if(data_) { free(data_); data_ = NULL; }
    if(poly) { free(poly); poly = NULL; }
    
	contextLock_ = nil;
    
	
}

@end

@implementation CCMutableTexture2D(Image)
+ (id) textureWithImage:(UIImage*) image
{
	return [[self alloc]initWithImage:image];
}

- (id) initWithImage:(UIImage *)uiImage
{
	NSUInteger				width,
	height,
	i;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned int*			inPixel32;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	CCTexture2DPixelFormat    pixelFormat;
	CGImageRef				image;
	BOOL					sizeToFit = NO;
    
    alteredColumns = [[NSMutableSet alloc] init];
    
	image = [uiImage CGImage];
    
	if(image == NULL) {
		
		NSLog(@"Image is Null");
		return nil;
	}
    
    
	info = CGImageGetAlphaInfo(image);
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
    
	size_t bpp = CGImageGetBitsPerComponent(image);
	if(CGImageGetColorSpace(image)) {
		if(hasAlpha || bpp >= 8)
			pixelFormat = [CCTexture2D defaultAlphaPixelFormat];
		else
			pixelFormat = kCCTexture2DPixelFormat_RGB565;
	} else  //NOTE: No colorspace means a mask image
		pixelFormat = kCCTexture2DPixelFormat_A8;
    
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	transform = CGAffineTransformIdentity;
    
	width = imageSize.width;
    
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < width)
			i *= 2;
		width = i;
	}
	height = imageSize.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < height)
			i *= 2;
		height = i;
	}
    
    
	unsigned maxTextureSize = [[CCConfiguration sharedConfiguration] maxTextureSize];
	if( width > maxTextureSize || height > maxTextureSize ) {
		CCLOG(@"cocos2d: WARNING: Image (%d x %d) is bigger than the supported %d x %d", width, height, maxTextureSize, maxTextureSize);
		return nil;
	}
    
	//	while((width > kMaxTextureSize) || (height > kMaxTextureSize)) {
	//		width /= 2;
	//		height /= 2;
	//		transform = CGAffineTransformScale(transform, 0.5f, 0.5f);
	//		imageSize.width *= 0.5f;
	//		imageSize.height *= 0.5f;
	//	}
    
	// Create the bitmap graphics context
    
	switch(pixelFormat) {
		case kCCTexture2DPixelFormat_RGBA8888:
		case kCCTexture2DPixelFormat_RGBA4444:
		case kCCTexture2DPixelFormat_RGB5A1:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			info = hasAlpha ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNoneSkipLast;
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, info | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		case kCCTexture2DPixelFormat_RGB565:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			info = kCGImageAlphaNoneSkipLast;
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, info | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		case kCCTexture2DPixelFormat_A8:
			data = malloc(height * width);
			info = kCGImageAlphaOnly;
			context = CGBitmapContextCreate(data, width, height, 8, width, NULL, info);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}
    
    
	CGContextClearRect(context, CGRectMake(0, 0, width, height));
	CGContextTranslateCTM(context, 0, height - imageSize.height);
    
	if(!CGAffineTransformIsIdentity(transform))
		CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
	// Repack the pixel data into the right format
    
	if(pixelFormat == kCCTexture2DPixelFormat_RGB565) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
        
	}
	else if (pixelFormat == kCCTexture2DPixelFormat_RGBA4444) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRGGGGBBBBAAAA"
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ =
			((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | // R
			((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | // G
			((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | // B
			((((*inPixel32 >> 24) & 0xFF) >> 4) << 0); // A
        
        
		free(data);
		data = tempData;
        
	}
	else if (pixelFormat == kCCTexture2DPixelFormat_RGB5A1) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGBBBBBA"
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ =
			((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | // R
			((((*inPixel32 >> 8) & 0xFF) >> 3) << 6) | // G
			((((*inPixel32 >> 16) & 0xFF) >> 3) << 1) | // B
			((((*inPixel32 >> 24) & 0xFF) >> 7) << 0); // A
        
        
		free(data);
		data = tempData;
	}
	self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:width pixelsHigh:height contentSize:imageSize];
    
	// should be after calling super init
	hasPremultipliedAlpha_ = (info == kCGImageAlphaPremultipliedLast || info == kCGImageAlphaPremultipliedFirst);
    
	CGContextRelease(context);
    
	//	This is the only change =/ but we want to keep the data for mutable methods
	data_ = data;
	contextLock_ = [[NSLock alloc] init];
    
	[self commonInit];
    
	return self;
}
@end

@implementation CCMutableTexture2D(CCTexture2D)
///
//	Create a texture with a CCTexture2D
///
+ (id) textureWithTexture2D:(CCTexture2D*) tex
{
	return [[self alloc]initWithTexture2D:tex];
}
- (id) initWithTexture2D:(CCTexture2D*) tex
{
	if((self = [super init])){
		contextLock_ = [[NSLock alloc] init];
	}
	[self commonInit];
	return self;
}
@end

@implementation CCMutableTexture2D (MutableTexture)
+ (id) textureWithSize:(CGSize) size
{
	return [[self alloc] initWithSize:size pixelFormat:[[self class] defaultAlphaPixelFormat]];
}
+ (id) textureWithSize:(CGSize) size pixelFormat:(CCTexture2DPixelFormat) pixelFormat
{
	return [[self alloc] initWithSize:size pixelFormat:pixelFormat];
}
- (id) initWithSize:(CGSize) size pixelFormat:(CCTexture2DPixelFormat) pixelFormat
{
	if((self = [super init])){
		format_ = pixelFormat;
		size_ = size;
        
		width_ = size.width;
		if(!IsPow2(width_))
			width_ = RoundToNearestPow2(width_);
        
		height_ = size.height;
		if(!IsPow2(height_))
			height_ = RoundToNearestPow2(height_);
        
		int dataSize = 0;
		switch (format_) {
			case kCCTexture2DPixelFormat_RGBA8888:
				dataSize = width_ * height_ * sizeof(int);
				break;
			case kCCTexture2DPixelFormat_RGBA4444:
			case kCCTexture2DPixelFormat_RGB5A1:
			case kCCTexture2DPixelFormat_RGB565:
				dataSize = width_ * height_ * sizeof(short);
				break;
			case kCCTexture2DPixelFormat_A8:
				dataSize = width_ * height_;
				break;
			default:
				break;
		}
        
        
        
		maxS_ = size_.width / (float)width_;
		maxT_ = size_.height / (float)height_;
        
		hasPremultipliedAlpha_ = NO;
		data_ = calloc(dataSize, 1);
		NSAssert(data_, @"Low Memory, could not allocate Texture Data");
        
		glGenTextures(1, &name_);
		glBindTexture(GL_TEXTURE_2D, name_);
        
		[self setAntiAliasTexParameters];
        
		switch(format_)
		{
			case kCCTexture2DPixelFormat_RGBA8888:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_, height_, 0, GL_RGBA, GL_UNSIGNED_BYTE, data_);
				break;
			case kCCTexture2DPixelFormat_RGBA4444:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_, height_, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data_);
				break;
			case kCCTexture2DPixelFormat_RGB5A1:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_, height_, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data_);
				break;
			case kCCTexture2DPixelFormat_RGB565:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width_, height_, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data_);
				break;
			case kCCTexture2DPixelFormat_A8:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width_, height_, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data_);
				break;
			default:
				[NSException raise:NSInternalInconsistencyException format:@""];
                
		}
		contextLock_ = [[NSLock alloc] init];
	}
	[self commonInit];
	return self;
}

- (ccColor4B) pixelAt:(CGPoint) pt
{
	ccColor4B c = {0, 0, 0, 0};
	if(!data_) return c;
	if(pt.x < 0 || pt.y < 0)  {
        //CCLOG(@"X OR Y IS LESS THAN ZERO x=%f , y=%f", pt.x, pt.y);
        return c;
    }
	if(pt.x >= size_.width || pt.y >= size_.height) {
        //CCLOG(@"size_.width = %f  AND size_.height = %f", size_.width, size_.height);
        //CCLOG(@"X OR Y IS GREATER THAN WIDTH/HEIGHT x=%f , y=%f", pt.x, pt.y);
        return c;
    }
    
	uint x = pt.x, y = pt.y;
    
	if(format_ == kCCTexture2DPixelFormat_RGBA8888){
		uint *pixel = data_;
		pixel = pixel + (y * width_) + x;
		c.r = *pixel & 0xff;
		c.g = (*pixel >> 8) & 0xff;
		c.b = (*pixel >> 16) & 0xff;
		c.a = (*pixel >> 24) & 0xff;
	} else if(format_ == kCCTexture2DPixelFormat_RGBA4444){
		GLushort *pixel = data_;
		pixel = pixel + (y * width_) + x;
		c.a = ((*pixel & 0xf) << 4) | (*pixel & 0xf);
		c.b = (((*pixel >> 4) & 0xf) << 4) | ((*pixel >> 4) & 0xf);
		c.g = (((*pixel >> 8) & 0xf) << 4) | ((*pixel >> 8) & 0xf);
		c.r = (((*pixel >> 12) & 0xf) << 4) | ((*pixel >> 12) & 0xf);
	} else if(format_ == kCCTexture2DPixelFormat_RGB5A1){
		GLushort *pixel = data_;
		pixel = pixel + (y * width_) + x;
		c.r = ((*pixel >> 11) & 0x1f)<<3;
		c.g = ((*pixel >> 6) & 0x1f)<<3;
		c.b = ((*pixel >> 1) & 0x1f)<<3;
		c.a = (*pixel & 0x1)*255;
	} else if(format_ == kCCTexture2DPixelFormat_RGB565){
		GLushort *pixel = data_;
		pixel = pixel + (y * width_) + x;
		c.b = (*pixel & 0x1f)<<3;
		c.g = ((*pixel >> 5) & 0x3f)<<2;
		c.r = ((*pixel >> 11) & 0x1f)<<3;
		c.a = 255;
	} else if(format_ == kCCTexture2DPixelFormat_A8){
		GLubyte *pixel = data_;
		c.a = pixel[(y * width_) + x];
		// Default white
		c.r = 255;
		c.g = 255;
		c.b = 255;
	}
    
	return c;
}

-(void)setVarsForColor:(ccColor4B) c {
	dirty_ = true;
    
	pixelUint=0;
	pixelGLushort=0;
	pixelGLubyte=0;
	if(format_ == kCCTexture2DPixelFormat_RGBA8888){
		pixelUint = data_;
		colorUint=(c.a << 24) | (c.b << 16) | (c.g << 8) | c.r;
	} else if(format_ == kCCTexture2DPixelFormat_RGBA4444){
		pixelGLushort = data_;
		colorGLushort=((c.r >> 4) << 12) | ((c.g >> 4) << 8) | ((c.b >> 4) << 4) | (c.a >> 4);
	} else if(format_ == kCCTexture2DPixelFormat_RGB5A1){
		pixelGLushort = data_;
		colorGLushort=((c.r >> 3) << 11) | ((c.g >> 3) << 6) | ((c.b >> 3) << 1) | (c.a > 0);
	} else if(format_ == kCCTexture2DPixelFormat_RGB565){
		pixelGLushort = data_;
		colorGLushort=((c.r >> 3) << 11) | ((c.g >> 2) << 5) | (c.b >> 3);
	} else if(format_ == kCCTexture2DPixelFormat_A8){
		pixelGLubyte = data_;
		colorGLubyte = c.a;
	} else {
		dirty_ = false;
		return;
	}
}

- (BOOL) setPixelAt:(CGPoint) pt rgba:(ccColor4B) c {
	if(!data_) return NO;
	if(pt.x < 0 || pt.y < 0) return NO;
	if(pt.x >= size_.width || pt.y >= size_.height) return NO;
	uint x = pt.x, y = pt.y;
    
	//	Shifted bit placement based on little-endian, let's make this more
	//	portable =/
    
	[self setVarsForColor:c];
	if (pixelUint!=0) {
		pixelUint[(y * width_) + x] = colorUint;
	} else if (pixelGLushort!=0) {
		pixelGLushort[(y * width_) + x] = colorGLushort;
	} else if (pixelGLubyte!=0) {
		pixelGLubyte[(y * width_) + x] = colorGLubyte;
	} else {
		return NO;
	}
    
    [alteredColumns addObject:[NSNumber numberWithInt:x]];
    
	return YES;
}

- (void) drawHorizontalLine:(float)x0 :(float)x1 :(float)yF withColor:(ccColor4B)c {
	if(!data_) return;
	int y=yF;
	if ((y<0) || (y >= size_.height)) return;

	int xMin, xMax;
	if (x0>x1) {
		xMin=x1;
		xMax=x0;
	} else {
		xMin=x0;
		xMax=x1;
	}
    
	if (xMax<0) return;
	if (xMin>= size_.width) return;
    
	if(xMin < 0) xMin=0;
	if(xMax >= size_.width) xMax=size_.width-1;
    
	[self setVarsForColor:c];
    
	int offsetStart=(y * width_) + xMin;
	int offsetEnd=offsetStart+xMax-xMin;
    
	if (pixelUint!=0) {
		for (int offset=offsetStart;offset<=offsetEnd;offset++) {
			pixelUint[offset] = colorUint;
			//NSLog(@"offset=%d",offset);
		}
	} else if (pixelGLushort!=0) {
		for (int offset=offsetStart;offset<=offsetEnd;offset++) {
			pixelGLushort[offset] = colorGLushort;
		}
	} else if (pixelGLubyte!=0) {
		for (int offset = offsetStart; offset <= offsetEnd; offset++) {
			pixelGLubyte[offset] = colorGLubyte;
		}
	}
    
    // Cache the column values
    
    for (int col = xMin; col <= xMax; col++) {
        [alteredColumns addObject:[NSNumber numberWithInt:col]];
    }
    
}


-(void)drawVerticalLine:(float)y0 endY:(float)y1 atX:(float)xF withColor:(ccColor4B)colorToApply {
    /*
     Draws a vertical line from start point y0 to end point y1 at the specified x coord position
     */
    if (!data_) return;
    
    int x = xF;
    
    if ((x < 0) || (x >= size_.width))  {
        // The x coordinate provided falls outside the texture and therefore a line cannot be drawn
        // Fail silently (Well sort of... There is a log statement here)
        //CCLOG(@"CCMutableTexture2D-> x coordinate cannot be less than zero or greater than the width of the texture");
        //CCLOG(@"CCMutableTexture2D-> Error :: Cannot apply drawVerticalLineEffect");
        return;
    } // end if
    
    int yMin, yMax;
    if (y0 > y1) {
        // end point is less than start point
        yMin = y1;
        yMax = y0;
    } else {
        // end point is greater than the start point
        yMin = y0;
        yMax = y1;
    } // end if
    
    if (yMax < 0) {
        // The yMax falls outside of the texture
        // Fail silently
        //CCLOG(@"CCMutableTexture2D-> yMax coordinate cannot be less than zero");
        //CCLOG(@"CCMutableTexture2D-> Error :: Cannot apply drawVerticalLineEffect");
        return;
    } // end if
    
    if (yMin >= size_.height) {
        // yMin falls outside of the texture
        // Fail silently
        //CCLOG(@"CCMutableTexture2D-> yMin coordinate cannot be greater than the width of the texture");
        //CCLOG(@"CCMutableTexture2D-> Error :: Cannot apply drawVerticalLineEffect");
        return;
    } // end if
    
    
    if (yMin < 0) yMin = 0;
    if (yMax >= size_.height) yMax = (size_.height - 1);
        
    [self setVarsForColor:colorToApply];
    
    // Find appropriate offsets for traversing vertically
    int offsetStart = (yMin * width_) + x;
	int offsetEnd = (yMax * width_) + x;
    
    // Each iteration of the for loop should step by the number of columns as the pixel data
    // is stored in Row Major. This allows for vertical traversal
	if (pixelUint!=0) {
        
		for (int offset=offsetStart; offset<=offsetEnd; offset = offset + width_) {
			pixelUint[offset] = colorUint;
			//NSLog(@"offset=%d",offset);
		} // end for
        
	} else if (pixelGLushort!=0) {
        
		for (int offset=offsetStart; offset<=offsetEnd; offset = offset + width_) {
			pixelGLushort[offset] = colorGLushort;
		} // end for
        
	} else if (pixelGLubyte!=0) {
        
		for (int offset = offsetStart; offset <= offsetEnd; offset = offset + width_) {
			pixelGLubyte[offset] = colorGLubyte;
		} // end for
        
	} // end if
    
    [alteredColumns addObject:[NSNumber numberWithInt:xF]];
    
} // end drawVerticalLine


-(void) drawVerticalLineFromPointToTopEdge:(float)yStart atX:(float)xF withColor:(ccColor4B)colorToApply {
    /*
     Draws a vertical line from a given row(x),col(y) from that point to the top edge of the texture
     In effect, this can be used to modify all pixels above a given x,y coordinate
     */
    
    if (!data_) return; // Fail silently
    
    int x = xF; // convert float to int
    
    if ((x < 0) || (x >= size_.width))  {
        // The x coordinate provided falls outside the texture and therefore a line cannot be drawn
        //CCLOG(@"CCMutableTexture2D-> x coordinate cannot be less than zero or greater than the width of the texture");
        //CCLOG(@"CCMutableTexture2D-> Error :: Cannot apply drawVerticalLineEffect");
        return;
    } // end if
    
    
     //Because we are always drawing to the top edge of the texture for a given point, yMin will always be 0
    int yMin = 0;
    int yMax = yStart;
    
    if (yMax <= 0) {
        //CCLOG(@"CCMutableTexture2D-> yStart coordinate cannot be less than or equal to zero");
        //CCLOG(@"CCMutableTexture2D-> Error :: Cannot apply drawVerticalLineFromPointToTopEdge");
    } // end if
    
    // Instead of failing just adjust the out of bounds yMax to bottom edge row of the texture
    if (yMax >= size_.height) yMax = size_.height - 1;
    
    [self setVarsForColor:colorToApply];
    
    // Find appropriate offsets for traversing vertically
    int offsetStart = (yMin * width_) + x;
	int offsetEnd = (yMax * width_) + x;
    
    // Each iteration of the for loop should step by the number of columns as the pixel data
    // is stored in Row Major. This allows for vertical traversal
	if (pixelUint!=0) {
        
		for (int offset=offsetStart; offset<=offsetEnd; offset = offset + width_) {
			pixelUint[offset] = colorUint;
			//NSLog(@"offset=%d",offset);
		} // end for
        
	} else if (pixelGLushort!=0) {
        
		for (int offset=offsetStart; offset<=offsetEnd; offset = offset + width_) {
			pixelGLushort[offset] = colorGLushort;
		} // end for
        
	} else if (pixelGLubyte!=0) {
        
		for (int offset = offsetStart; offset <= offsetEnd; offset = offset + width_) {
			pixelGLubyte[offset] = colorGLubyte;
		} // end for
        
	} // end if
    
    // No need to cache here since it modifies pixels from a point in col to top
    
} // end drawVerticalLine


-(void) drawCircle:(CGPoint)circleOrigin withRadius:(float)radius withColor:(ccColor4B)color {
    /*
     Draws a circle. There is some overlap here but it is fairly efficient
     */
    int x = radius;
    int y = 0;
    int radiusError = 1 - x;
    
    while (x >= y) {
        
        // Bottom half
        [self drawHorizontalLine:(x + circleOrigin.x) :(circleOrigin.x - x) :(y + circleOrigin.y) withColor:color];
        
        // Top half
        [self drawHorizontalLine:(x + circleOrigin.x) :(circleOrigin.x - x) :(circleOrigin.y - y) withColor:color];
        
        // left side
        [self drawVerticalLine:(x + circleOrigin.y) endY:(circleOrigin.y - x) atX:(-y + circleOrigin.x) withColor:color];
        
        // right side
        [self drawVerticalLine:(x + circleOrigin.y) endY:(circleOrigin.y - x) atX:(y + circleOrigin.x) withColor:color];
        
        y++;
        
        if (radiusError < 0) {
            radiusError = radiusError +  ((2 * y) +1);
        } else {
            x--; // Comment this out to draw a square
            radiusError = radiusError + (2 * (y - x + 1));
        } // end if
        
    } // end while
    
    // Cache the altered col values
    for (int col = circleOrigin.x - radius; col <= circleOrigin.x + radius; col++) {
        if (col < 0 || col >= size_.width) continue;
        [alteredColumns addObject:[NSNumber numberWithInt:col]];
    } // end for
    
} // end draw circle

-(void)createExplosion:(CGPoint)explosionOrigin withRadius:(float)radius withColor:(ccColor4B)color {
    // Similiar to draw circle but creates a charing effect
    // TODO :: Make this more adaptable
    [self drawCircle:explosionOrigin withRadius:radius withColor:color];
    
    for (int w = radius; w >= -radius; w--) {
        int h = 0;
        int ranPixAmt = 3; //arc4random() is possibility as well here
        do {
            if ([self pixelAt:ccp(w + explosionOrigin.x, explosionOrigin.y - h)].a != 0) {
                // Found a ground pixel
                for (int p = 0; p <= ranPixAmt; p++) {
                    switch (p) {
                            // TODO :: Make this more adjustable
                        case 0:
                            [self setPixelAt:ccp(w + explosionOrigin.x, explosionOrigin.y - p - h) rgba:ccc4(4, 4, 4, 250)];
                            break;
                        case 1:
                            [self setPixelAt:ccp(w + explosionOrigin.x, explosionOrigin.y - p - h) rgba:ccc4(16, 16, 16, 250)];
                            break;
                        case 2:
                            [self setPixelAt:ccp(w + explosionOrigin.x, explosionOrigin.y - p - h) rgba:ccc4(25, 25, 25, 250)];
                            break;
                        case 3:
                            [self setPixelAt:ccp(w + explosionOrigin.x, explosionOrigin.y - p - h) rgba:ccc4(51, 51, 51, 250)];
                            break;
                    } // end switch
                } // end for
                break;
            } // end if
            h--;
        } while (h >= (-radius-3));
    } // end outer for
} // end createExplosion

-(void) drawSquare:(CGPoint)squareOrigin withRadius:(float)radius withColor:(ccColor4B)color {
    
    int x = radius;
    int y = 0;
    int radiusError = 1 - x;
    
    while (x >= y) {
        
        // Bottom half
        [self drawHorizontalLine:(x + squareOrigin.x) :(squareOrigin.x - x) :(y + squareOrigin.y) withColor:color];
        
        // Top half
        [self drawHorizontalLine:(x + squareOrigin.x) :(squareOrigin.x - x) :(squareOrigin.y - y) withColor:color];
        
        y++;
        
        if (radiusError < 0) {
            radiusError = radiusError +  ((2 * y) +1);
        } else {
            radiusError = radiusError + (2 * (y - x + 1));
        } // end if
        
    } // end while
    
    // Cache the altered columns
    for (int col = squareOrigin.x - radius; col <= squareOrigin.x + radius; col++) {
        if (col < 0 || col >= size_.width) continue;
        [alteredColumns addObject:[NSNumber numberWithInt:col]];
    } // end for
    
} //endDrawSquare

- (void) fillConvexPolygon:(CGPoint*)p :(int)n withColor:(ccColor4B)c {
	int *yOrderedIdx = calloc( sizeof(int) * n, 1 );
	for (int i=0;i<n;i++) {
		yOrderedIdx[i]=i;
	}
	//Order polygon corners by its corners y ascending
	for (int i=0;i<n;i++) {
		int oI=yOrderedIdx[i];
		float min=p[oI].y;
		for (int j=i+1;j<n;j++) {
			int oJ=yOrderedIdx[j];
			if (p[oJ].y<min) {
				yOrderedIdx[i]=oJ;
				yOrderedIdx[j]=oI;
				min=p[oJ].y;
			}
		}
	}
    
	int rightIndex,leftIndex;
	leftIndex=(yOrderedIdx[0]+n-1)%n +1;
	rightIndex=(yOrderedIdx[0]+1)%n -1;
    
	CGPoint leftPoint0,leftPoint1,rightPoint0,rightPoint1;
	leftPoint0=leftPoint1=rightPoint0=rightPoint1=p[yOrderedIdx[0]];
    
	float leftInc,rightInc;
	int yMin=leftPoint0.y+0.5f;
	int yMax=p[yOrderedIdx[n-1]].y;
    
	int leftX,rightX;
    
	for (int y=yMin;y<yMax;y++) {
		while (y>=rightPoint1.y) {
			//new right points
			rightPoint0=rightPoint1;
			rightIndex++; if (rightIndex>=n) rightIndex=0;
			rightPoint1=p[rightIndex];
            
			rightInc=0;
			if ((rightPoint1.y-rightPoint0.y)!=0) {
				rightInc=(rightPoint1.x-rightPoint0.x)/(rightPoint1.y-rightPoint0.y);
			}
		}
        
		while (y>=leftPoint1.y) {
			//new left points
			leftPoint0=leftPoint1;
			leftIndex--; if (leftIndex<0) leftIndex=n-1;
			leftPoint1=p[leftIndex];
            
			leftInc=0;
			if ((leftPoint1.y-leftPoint0.y)!=0) {
				leftInc=(leftPoint1.x-leftPoint0.x)/(leftPoint1.y-leftPoint0.y);
			}
			//NSLog(@"y>leftPoint1.y new leftIndex=%d leftInc=%f",leftIndex,leftInc);
		}
        
		leftX=leftPoint0.x;
		rightX=rightPoint0.x;
		//if (y>0)
		[self drawHorizontalLine:leftX :rightX :y withColor:c];
		//if (yMin<0) NSLog(@"drawHorizontalLine %d-%d,%d",leftX,rightX,y);
        
		leftPoint0.x+=leftInc;
		rightPoint0.x+=rightInc;
	}
    
	leftX=leftPoint0.x;
	rightX=rightPoint0.x;
	[self drawHorizontalLine:leftX :rightX :yMax withColor:c];
    
	free(yOrderedIdx);
}

-(void) drawLineFrom:(CGPoint)p0 to:(CGPoint)p1 withLineWidth:(float)w andColor:(ccColor4B) c {
	//[contextLock_ lock];
	CGPoint vector=ccpMult(ccpNormalize(ccpSub(p1, p0)),w);
	//float d=ccpLength(vector);
	CGPoint midVector=ccpMult(vector,0.707106781f);
    
	CGPoint perp=ccpPerp(vector);
	CGPoint midPerp=ccpPerp(midVector);
    
	//int n=10;
	//CGPoint *poly = calloc( sizeof(CGPoint) * n, 1 );
	int i=0;
	poly[i]=ccpSub(ccpSub(p0,midVector),midPerp); i++;
	poly[i]=ccpSub(p0,vector); i++;
	poly[i]=ccpAdd(ccpSub(p0,midVector),midPerp); i++;
    
	poly[i]=ccpAdd(p0,perp); i++;
	poly[i]=ccpAdd(p1,perp); i++;
    
	poly[i]=ccpAdd(ccpAdd(p1,midVector),midPerp); i++;
	poly[i]=ccpAdd(p1,vector); i++;
	poly[i]=ccpSub(ccpAdd(p1,midVector),midPerp); i++;
    
	poly[i]=ccpSub(p1,perp); i++;
	poly[i]=ccpSub(p0,perp); i++;
    
    
	[self fillConvexPolygon:poly :CCMUTABLETEXTURE2D_LINE_POLY_COUNT withColor:c];
    
	//free(poly);
	//[contextLock_ unlock];
}

- (void) fill:(ccColor4B) c {
	if(!data_) return;
	[self setVarsForColor:c];
    
	int offsetSize=height_*width_;
    
	if (pixelUint!=0) {
		for (int offset=0;offset<offsetSize;offset++) {
			pixelUint[offset] = colorUint;
		}
	} else if (pixelGLushort!=0) {
		for (int offset=0;offset<offsetSize;offset++) {
			pixelGLushort[offset] = colorGLushort;
		}
	} else if (pixelGLubyte!=0) {
		for (int offset=0;offset<offsetSize;offset++) {
			pixelGLubyte[offset] = colorGLubyte;
		}
	}
}

-(void) pixelGrabGlow:(CGPoint)p glowColor:(ccColor4B)glowColor {
    CGPoint cur;
    ccColor4B color;
    
    cur=ccp(p.x-1,p.y-1);
    color=[self pixelAt:cur];
    if ((color.r==0)&&(color.g==0)&&(color.b==0)) {
        [self setPixelAt:cur rgba:glowColor];
    }
    cur=ccp(p.x,p.y-1);
    color=[self pixelAt:cur];
    if ((color.r==0)&&(color.g==0)&&(color.b==0)) {
        [self setPixelAt:cur rgba:glowColor];
    }
    cur=ccp(p.x+1,p.y-1);
    color=[self pixelAt:cur];
    if ((color.r==0)&&(color.g==0)&&(color.b==0)) {
        [self setPixelAt:cur rgba:glowColor];
    }
    cur=ccp(p.x-1,p.y);
    color=[self pixelAt:cur];
    if ((color.r==0)&&(color.g==0)&&(color.b==0)) {
        [self setPixelAt:cur rgba:glowColor];
    }
    cur=ccp(p.x,p.y);
    color=[self pixelAt:cur];
    if ((color.r==0)&&(color.g==0)&&(color.b==0)) {
        [self setPixelAt:cur rgba:glowColor];
    }
    cur=ccp(p.x+1,p.y);
    color=[self pixelAt:cur];
    if ((color.r==0)&&(color.g==0)&&(color.b==0)) {
        [self setPixelAt:cur rgba:glowColor];
    }
    cur=ccp(p.x-1,p.y+1);
    color=[self pixelAt:cur];
    if ((color.r==0)&&(color.g==0)&&(color.b==0)) {
        [self setPixelAt:cur rgba:glowColor];
    }
    cur=ccp(p.x,p.y+1);
    color=[self pixelAt:cur];
    if ((color.r==0)&&(color.g==0)&&(color.b==0)) {
        [self setPixelAt:cur rgba:glowColor];
    }
    cur=ccp(p.x+1,p.y+1);
    color=[self pixelAt:cur];
    if ((color.r==0)&&(color.g==0)&&(color.b==0)) {
        [self setPixelAt:cur rgba:glowColor];
    }
}

-(void)collapseAllPixels {
    
    for (int x = 0; x < width_; x++) {
        bool nonAlphaFound = false;
        CGPoint start;
        CGPoint end;
        for (int y = 0; y < height_; y++) {
            if ([self pixelAt:ccp(x,y)].a != 0) {
                if (!nonAlphaFound) {
                    start = ccp(x,y);
                    nonAlphaFound = true;
                }
            } else {
                if (nonAlphaFound) {
                    end = ccp(x,(y - 1));
                    // Make call to collapse terrain with start and end
                    //[self drawVerticalLine:start.y endY:end.y atX:x withColor:ccc4(100, 100, 100, 100)];
                    int yidx = y;
                    int starty = start.y;
                    while (([self pixelAt:ccp(x,yidx)].a == 0) && (yidx < height_)) {
                        
                        [self setPixelAt:ccp(x,yidx) rgba:[self pixelAt:ccp(x,starty)]];
                        [self setPixelAt:ccp(x, starty) rgba:ccc4(0, 0, 0, 0)];
                        
                        yidx++;
                        starty++;
                    }
                break;
                }
            }
        } // end inner for
    } // end outer for 
    
}

-(bool)collapseSinglePixel {
    
    bool didCollapse = false;
        for (NSNumber * col in [alteredColumns allObjects]) {
        int x = col.intValue;
        bool shouldShift = false;
        bool alphaFound = false;
        for (int y = (size_.height -1); y >= 0; y--) {
            if (!shouldShift) {
                if ([self pixelAt:ccp(x,y)].a == 0) {
                    // Need to shift all pixels above one down
                    alphaFound = true;
                } else if (alphaFound) {
                    didCollapse = shouldShift = true;
                    // Ensure the top pixel is alpha'ed out if a collapse will occur
                    [self setPixelAt:ccp(x,0) rgba:ccc4(0, 0, 0, 0)];
                    [self setPixelAt:ccp(x,(y+1)) rgba:[self pixelAt:ccp(x,y)]];
                } // end inner if
            } else {
                // Need to shift pixels down one
                [self setPixelAt:ccp(x,(y+1)) rgba:[self pixelAt:ccp(x,y)]];
            } // end if
        } // end inner for
        // Remove column from cache if no pixels collapsed
        if (!shouldShift) [alteredColumns removeObject:col];
    } // end outer for
    
    return didCollapse;
} // end collapseSinglePixel

-(void)showLogAlteredColumnsCache {
    // For debugging purposes
    
    if (!alteredColumns) {
        CCLOG(@"There are no altered columns in the cache for this texture");
        return;
    }
    
    
    for (NSNumber * col in [alteredColumns allObjects]) {
        CCLOG(@"column %d", [col intValue]);
    }
   
    
}

- (Boolean) apply {
	if(!dirty_) return NO;
	if(!data_) return NO;
    
	glBindTexture(GL_TEXTURE_2D, name_);
    
	switch(format_) {
		case kCCTexture2DPixelFormat_RGBA8888:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_, height_, 0, GL_RGBA, GL_UNSIGNED_BYTE, data_);
			break;
		case kCCTexture2DPixelFormat_RGBA4444:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_, height_, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data_);
			break;
		case kCCTexture2DPixelFormat_RGB5A1:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_, height_, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data_);
			break;
		case kCCTexture2DPixelFormat_RGB565:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width_, height_, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data_);
			break;
		case kCCTexture2DPixelFormat_A8:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width_, height_, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data_);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@""];
	}
	dirty_ = false;
	return YES;
}

- (void) applyWithAsyncObject:(AsyncObject*)async {
	@autoreleasepool {
		[contextLock_ lock];
		if( mutableTextureAuxEAGLcontext == nil ) {
			mutableTextureAuxEAGLcontext = [[EAGLContext alloc]
                                        initWithAPI:kEAGLRenderingAPIOpenGLES1
                                        sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]];
        
			if( ! mutableTextureAuxEAGLcontext )
				CCLOG(@"cocos2d: TextureCache: Could not create EAGL context");
		}
    
		if( [EAGLContext setCurrentContext:mutableTextureAuxEAGLcontext] ) {
			[self apply];
			// The callback will be executed on the main thread
			[async.target performSelectorOnMainThread:async.selector withObject:nil waitUntilDone:NO];
			[EAGLContext setCurrentContext:nil];
		} else {
			CCLOG(@"cocos2d: TextureCache: EAGLContext error");
		}
		[contextLock_ unlock];
	}
}

- (void) applyAsyncWithCallback:(id) target selector:(SEL) callbackSel
{
	AsyncObject *asyncObject = [[AsyncObject alloc] init];
	asyncObject.selector = callbackSel;
	asyncObject.target = target;
	[NSThread detachNewThreadSelector:@selector(applyWithAsyncObject:) toTarget:self withObject:asyncObject];
}

- (void) drawAtPoint:(CGPoint)point 
{
	[contextLock_ lock];
	[super drawAtPoint:point];
	[contextLock_ unlock];
}


- (void) drawInRect:(CGRect)rect
{
	[contextLock_ lock];
	[super drawInRect:rect];
	[contextLock_ unlock];
}

@end
