/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-17 15:07
 Descript: Socket在读取数据时的回调函数
 */

#import "network/stnetwork.h"
#include <net/if.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <ifaddrs.h>
#import <dlfcn.h>

@interface STNetwork ()

@end

@implementation STNetwork

+ (NSString*)getLocalIPv4FromWifi {
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    
    return nil;
}

+ (NSString*)getIPv4StringFromIn_Addr:(const in_addr_t)addr {
    NSString* retIP = NULL;
    
    char ip[20];
    memset(ip, 0, sizeof(ip));
    unsigned int intIP;
    memcpy(&intIP, &addr,sizeof(unsigned int));
    int a = (intIP >> 24) & 0xFF;
    int b = (intIP >> 16) & 0xFF;
    int c = (intIP >> 8) & 0xFF;
    int d = intIP & 0xFF;
    
    sprintf(ip, "%d.%d.%d.%d", d,c,b,a);
    
    retIP = [NSString stringWithFormat:@"%d.%d.%d.%d", d,c,b,a];
    return retIP;
}

@end