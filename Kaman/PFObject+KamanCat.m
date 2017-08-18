//
//  PFObject+KamanCat.m
//  Kaman
//
//  Created by Moin' Victor on 06/01/2016.
//  Copyright © 2016 Riad & Co. All rights reserved.
//

#import "PFObject+KamanCat.h"

@implementation PFObject (KamanCat)

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[PFObject class]]) {
        PFObject * other = object;
        return self.objectId == other.objectId;
    }
    else if (![object isKindOfClass:self.class]) {
        return NO;
    }
    return [super isEqual:object];
;
}
@end
