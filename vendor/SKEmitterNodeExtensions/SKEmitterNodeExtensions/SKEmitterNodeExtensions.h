#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface SKEmitterNode (Extensions)

+(SKEmitterNode *) nodeWithFile:(NSString *)filename;
-(void) dieOutInDuration:(NSTimeInterval)duration;

@end
