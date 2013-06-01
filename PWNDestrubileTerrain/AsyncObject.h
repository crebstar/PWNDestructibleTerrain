//
//  AsyncObject.h
//  SpaceTankWars
//
//  Created by Paul Renton on 6/1/13.
//
//

//
//  AsyncObject.h
//  PixelPile
//
//  Created by Lam Pham on 1/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncObject : NSObject
{
	SEL			selector_;
	id			target_;
	id			data_;
}
@property	(readwrite,assign)	SEL			selector;
@property	(readwrite,strong)	id			target;
@property	(readwrite,strong)	id			data;
@end
