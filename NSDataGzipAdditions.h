//
//  DataExtension.c
//  Tenic Reader
//
//  Created by Jia Rui Shan on 3/13/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (GZip)

+ (id) compressedDataWithBytes: (const void*) bytes length: (unsigned) length;
+ (id) compressedDataWithData: (NSData*) data;

+ (id) dataWithCompressedBytes: (const void*) bytes length: (unsigned) length;
+ (id) dataWithCompressedData: (NSData*) compressedData;

@end