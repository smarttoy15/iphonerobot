//
//  STTDevice.h
//  smarttoysdktest
//
//  Created by newma on 4/3/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import "network/stpeer.h"

@interface SRDevice : STPeer

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* subTitle;
@property (nonatomic, strong) NSString* imageUrl;

@end