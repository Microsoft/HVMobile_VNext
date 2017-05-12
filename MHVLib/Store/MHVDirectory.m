//
//  MHVDirectory.m
//  MHVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "MHVCommon.h"
#import "MHVDirectory.h"
#import "XLib.h"
#import <MobileCoreServices/UTType.h>
#import <MobileCoreServices/UTCoreTypes.h>

//---------------------------
//
// NSFileManager
//
//---------------------------
@implementation NSFileManager (MHVExtensions)

-(NSURL *) pathForStandardDirectory:(NSSearchPathDirectory)name
{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* urls = [fm URLsForDirectory:name inDomains:NSUserDomainMask];
    if ([NSArray isNilOrEmpty:urls])
    {
        return nil;
    }
    
    return [urls objectAtIndex:0];
}

-(NSURL *)documentDirectoryPath
{
    return [self pathForStandardDirectory:NSDocumentDirectory];
}

-(NSURL *)cacheDirectoryPath
{
    return [self pathForStandardDirectory:NSCachesDirectory];
}

-(long)sizeOfFileAtPath:(NSString *)path
{
    return (long)[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
}

+(NSString *)mimeTypeForFile:(NSString *)filePath
{
    NSString* ext = [filePath pathExtension];
    return [NSFileManager mimeTypeForFileExtension:ext];
}

+(NSString *)mimeTypeForFileExtension:(NSString *)ext
{
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) ext, NULL);
    NSString* mimeType = (NSString *) CFBridgingRelease(UTTypeCopyPreferredTagWithClass (uti, kUTTagClassMIMEType));
    CFRelease(uti);
    return mimeType;
}

+(NSString *)fileExtForMimeType:(NSString *)mimeType
{
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef) mimeType, NULL);
    NSString* ext = (NSString *)CFBridgingRelease(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension));
    CFRelease(uti);
    return ext;
}

@end

//---------------------------
//
// NSFileHandle
//
//---------------------------
@implementation NSFileHandle (MHVExtensions)

+(NSFileHandle *)createOrOpenForWriteAtPath:(NSString *)path
{
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    if (!fileHandle)
    {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    }
    
    return fileHandle;
}

-(BOOL)writeText:(NSString *)text
{
    if ([NSString isNilOrEmpty:text])
    {
        return TRUE;
    }
    
    @try
    {
        NSData* bytes = [text dataUsingEncoding:NSUTF8StringEncoding];
        if (bytes && bytes.length > 0)
        {
            [self writeData:bytes];
            return TRUE;
        }
    }
    @catch (id exception) {
        
    }
    
    return FALSE;
}

-(BOOL)appendText:(NSString *)text
{
    [self seekToEndOfFile];
    return [self writeText:text];
}

+(NSString *) stringFromFileAtPath:(NSString *)path
{
    NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath:path];
    if (!file)
    {
        return nil;
    }
    @try
    {
        NSData* data = [file readDataToEndOfFile];
        if (!data)
        {
            return nil;
        }
        
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    @catch(id exception)
    {
    }
    @finally
    {
        [file closeFile];
    }
}

@end

//---------------------------
//
// MHVDirectory
//
//---------------------------
@interface MHVDirectory (MHVPrivate)

-(XConverter *) getConverter;

@end

@implementation MHVDirectory

@synthesize url = m_path;
@synthesize stringPath = m_stringPath;

-(id)init
{
    return [self initWithPath:nil];
}

-(id)initWithPath:(NSURL *)path
{
    MHVCHECK_NOTNULL(path);
    
    self = [super init];
    MHVCHECK_SELF;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    m_path = path;
    m_stringPath = m_path.path;
    
    MHVCHECK_SUCCESS([fm createDirectoryAtPath:m_stringPath withIntermediateDirectories:TRUE attributes:nil error:nil]);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
    
}

-(id)initWithRelativePath:(NSString *)path
{
    MHVCHECK_STRING(path);
    
    self = [super init];
    MHVCHECK_SELF;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSURL *fullPath = [[fm documentDirectoryPath] URLByAppendingPathComponent:path];
    MHVCHECK_NOTNULL(fullPath);
    
    return [self initWithPath:fullPath];
    
LError:
    MHVALLOC_FAIL;
}

-(NSURL *) makeChildUrl:(NSString *)name
{
    return [m_path URLByAppendingPathComponent:name];
}

-(NSString *)makeChildPath:(NSString *)name
{
    MHVCHECK_STRING(name);
    
    return [m_stringPath stringByAppendingPathComponent:name];
    
LError:
    return nil;
}

+(void)deleteUrl:(NSURL *)url
{
    @try
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtURL:url error:nil];
    }
    @catch (id exception)
    {
        [exception log];
    }
}

-(NSEnumerator *)getFileNames
{
    return [[MHVDirectoryNameEnumerator alloc] initWithPath:m_path inFileMode:TRUE];
}

-(NSEnumerator *)getDirectoryNames
{
    return [[MHVDirectoryNameEnumerator alloc] initWithPath:m_path inFileMode:FALSE];
}

-(MHVDirectory *)newChildNamed:(NSString *)name
{
    NSURL *path = [self makeChildUrl:name];
    MHVCHECK_NOTNULL(path);
    
    return [[MHVDirectory alloc] initWithPath:path];
    
LError:
    return nil;
}

-(BOOL)fileExists:(NSString *)fileName
{
    NSString* filePath = [self makeChildPath:fileName];
    MHVCHECK_NOTNULL(filePath);
    
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
LError:
    return FALSE;
}

-(NSString *)makeFilePathIfExists:(NSString *)fileName
{
    NSString* filePath = [self makeChildPath:fileName];
    MHVCHECK_NOTNULL(filePath);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return filePath;
    }
    
LError:
    return nil;
    
}

-(BOOL)createFile:(NSString *)fileName
{
    NSString* filePath = [self makeChildPath:fileName];
    MHVCHECK_NOTNULL(filePath);
    
    return [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    
LError:
    return FALSE;
}

-(BOOL)deleteFile:(NSString *)fileName
{
    NSString* filePath = [self makeChildPath:fileName];
    MHVCHECK_NOTNULL(filePath);
    
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
LError:
    return FALSE;
}

-(NSDictionary *)getFileProperties:(NSString *)fileName
{
    NSString* filePath = [self makeChildPath:fileName];
    MHVCHECK_NOTNULL(filePath);
    
    return [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    
LError:
    return nil;
}

-(BOOL)isFileNamed:(NSString *)name aged:(NSTimeInterval)maxAge
{
    if (![self fileExists:name])
    {
        return TRUE; // A non-existent file is considered stale by definition
    }
    
    NSDate* lastUpdated = [self updateDateForKey:name];
    return ([[NSDate date  ]timeIntervalSinceDate:lastUpdated] > maxAge);
}

-(NSFileHandle *)openFileForRead:(NSString *)fileName
{
    NSString* filePath = [self makeFilePathIfExists:fileName];
    if (!filePath)
    {
        return nil;
    }
    
    return [NSFileHandle fileHandleForReadingAtPath:filePath];
}

-(NSFileHandle *)openFileForWrite:(NSString *)fileName
{
    NSString* filePath = [self makeChildPath:fileName];
    MHVCHECK_NOTNULL(filePath);
    
    return [NSFileHandle fileHandleForWritingAtPath:filePath];
    
LError:
    return nil;
}

//---------------------
//
// MHVObjectStore
//
//---------------------
-(NSEnumerator *)allKeys
{
    return [self getFileNames];
}

-(NSDate *)createDateForKey:(NSString *)key
{
    NSDictionary* fileProperties = [self getFileProperties:key];
    return fileProperties ? fileProperties.fileCreationDate : nil;
}

-(NSDate *)updateDateForKey:(NSString *)key
{
    NSDictionary* fileProperties = [self getFileProperties:key];
    return fileProperties ? fileProperties.fileModificationDate : nil;
}

-(BOOL)keyExists:(NSString *)key
{
    @synchronized(self)
    {
        return [self fileExists:key];
    }
}

-(BOOL)deleteKey:(NSString *)key
{
    @synchronized(self)
    {
        @try
        {
            return [self deleteFile:key];
        }
        @catch (id ex)
        {
            [ex log];
        }
        
        return FALSE;
    }
}

-(id)newObjectWithKey:(NSString *)key name:(NSString *)name andClass:(Class)cls
{
    @synchronized(self)
    {
        NSString* filePath = [self makeChildPath:key];
        if (!filePath)
        {
            return nil;
        }
        
        XConverter* converter = [self getConverter];
        return [NSObject newFromSecureFilePath:filePath withRoot:name asClass:cls withConverter:converter];
    }
}

-(id)getObjectWithKey:(NSString *)key name:(NSString *)name andClass:(Class)cls
{
    return [self newObjectWithKey:key name:name andClass:cls];
}

-(BOOL) putObject:(id)obj withKey:(NSString *)key andName:(NSString *)name
{
    @synchronized(self)
    {
        @try
        {
            XConverter* converter = [self getConverter];
            return [XSerializer secureSerialize:obj withRoot:name toFilePath:[self makeChildPath:key] withConverter:converter];
        }
        @catch (id exception)
        {
            [exception log];
        }
        
        return FALSE;
    }
}

-(NSData *)getBlob:(NSString *)key
{
    @synchronized(self)
    {
        NSFileHandle *handle = [self openFileForRead:key];
        if (!handle)
        {
            return nil;
        }
        
        @try
        {
            return [handle readDataToEndOfFile];
        }
        @catch (id exception)
        {
            [exception log];
        }
        @finally
        {
            [handle closeFile];
        }
        
        return nil;
    }
}

-(BOOL)putBlob:(NSData *)blob withKey:(NSString *)key
{
    @synchronized(self)
    {
        NSFileHandle *handle = [self openFileForWrite:key];
        if (handle == nil)
        {
            [self createFile:key];
            handle = [self openFileForWrite:key];
        }
        MHVCHECK_NOTNULL(handle);
        
        @try
        {
            [handle writeData:blob];
            return TRUE;
        }
        @catch (id exception)
        {
            [exception log];
        }
        @finally
        {
            [handle closeFile];
        }
        
    LError:
        return FALSE;
    }
}

-(id<MHVObjectStore>)newChildStore:(NSString *)name
{
    @synchronized(self)
    {
        return [self newChildNamed:name];
    }
}

-(void)deleteChildStore:(NSString *)name
{
    @synchronized(self)
    {
        NSURL *path = [self makeChildUrl:name];
        [MHVDirectory deleteUrl:path];
    }
}

-(BOOL)childStoreExists:(NSString *)name
{
    @synchronized(self)
    {
        NSString *childPath = [self makeChildPath:name];
        BOOL isDirectory = FALSE;
        BOOL childExists = [[NSFileManager defaultManager] fileExistsAtPath:childPath isDirectory:&isDirectory];
        return (childExists && isDirectory);
    }
}

-(NSEnumerator *)allChildStoreNames
{
    return [self getDirectoryNames];
}

-(NSData *)refreshAndGetBlob:(NSString *)key
{
    return [self getBlob:key];
}

-(id)refreshAndGetObjectWithKey:(NSString *)key name:(NSString *)name andClass:(Class)cls
{
    return [self getObjectWithKey:key name:name andClass:cls];
}


@end

@implementation MHVDirectory (MHVPrivate)

-(XConverter *)getConverter
{
    if (!m_converter)
    {
        m_converter = [[XConverter alloc] init];
    }
    
    return m_converter;
}

@end
