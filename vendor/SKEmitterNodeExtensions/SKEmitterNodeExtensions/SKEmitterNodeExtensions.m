#import "SKEmitterNodeExtensions.h"

@implementation SKEmitterNode (Extensions)

+(SKEmitterNode *) nodeWithFile:(NSString *)filename {
    NSString *basename = [filename stringByDeletingPathExtension];
    NSString *extension = [filename pathExtension];
    if (0 == [extension length]) {
        extension = @"sks";
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:basename ofType:extension];
    SKEmitterNode *node = (id)[NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return node;
}

-(void) dieOutInDuration:(NSTimeInterval) duration {
    SKAction *firstWait = [SKAction waitForDuration:duration];
    __weak SKEmitterNode *weakSelf = self;
    SKAction *stop = [SKAction runBlock:^{
        weakSelf.particleBirthRate = 0;
    }];
    SKAction *secondWait = [SKAction waitForDuration:self.particleLifetime];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *dieOut = [SKAction sequence:@[firstWait, stop, secondWait, remove]];
    [self runAction:dieOut];
}

@end
