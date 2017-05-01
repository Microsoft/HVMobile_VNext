//
//  XmlReader.h
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <libxml/tree.h>
#import <libxml/xmlreader.h>
#import "HVStringExtensions.h"
#import "XNodeType.h"
#import "XString.h"
#import "XConverter.h"


@interface XReader : NSObject
{
    xmlTextReader *m_reader;    // C Pointer. Weak ref
    enum XNodeType m_nodeType;
    NSString *m_localName;
    NSString *m_ns;
    NSString *m_value;
    XConverter *m_converter;
}

@property (readwrite, nonatomic, retain) id context;

@property (readonly, nonatomic) xmlTextReader* reader; 
@property (readonly, nonatomic) XConverter* converter;

@property (readonly, nonatomic) int depth;

@property (readonly, nonatomic) enum XNodeType nodeType;
@property (readonly, nonatomic) NSString* nodeTypeString;

@property (readonly, nonatomic) BOOL isEmptyElement;
@property (readonly, nonatomic) BOOL hasEndTag;
@property (readonly, nonatomic) BOOL isTextualNode;

@property (readonly, nonatomic) NSString* localName;
@property (readonly, nonatomic) NSString* namespaceUri;
@property (readonly, nonatomic) BOOL hasValue;
@property (readonly, nonatomic) NSString* value;

@property (readonly, nonatomic) const xmlChar* localNameRaw;
@property (readonly, nonatomic) const xmlChar* namespaceUriRaw;
@property (readonly, nonatomic) const xmlChar* valueRaw;

@property (readonly, nonatomic) const xmlChar* name;
@property (readonly, nonatomic) const xmlChar* prefix;

@property (readonly, nonatomic) BOOL hasAttributes;
@property (readonly, nonatomic) int attributeCount;

// Designated
-(id) initWithReader:(xmlTextReader *)reader andConverter:(XConverter *) converter;
-(id) initWithReader:(xmlTextReader *) reader;
-(id) initFromFile:(NSString *) fileName;
-(id) initFromFile:(NSString *) fileName withConverter:(XConverter *) converter;
-(id) initFromMemory:(NSData*) buffer;
-(id) initFromMemory:(NSData*) buffer withConverter:(XConverter *) converter;
-(id) initFromString:(NSString *) string;
-(id) initFromString:(NSString *) string withConverter:(XConverter *) converter;

-(void) clear;

-(NSString *) getAttribute:(NSString *) name;
-(NSString *) getAttribute:(NSString *) name NS: (NSString*) ns;
-(NSString *) getAttributeAt:(int) index;
-(BOOL) moveToAttributeAt:(int) index;
-(BOOL) moveToAttribute:(NSString *) name;
-(BOOL) moveToAttribute:(NSString *)name NS: (NSString *) ns;
-(BOOL) moveToFirstAttribute;
-(BOOL) moveToNextAttribute;

-(BOOL) moveToAttributeWithXmlName:(const xmlChar *) xmlName;
-(BOOL) moveToAttributeWithXmlName:(const xmlChar *)xmlName andXmlNs:(const xmlChar *) xmlNs;

-(BOOL) isStartElement;
-(BOOL) isStartElementWithName:(NSString *) name;
-(BOOL) isStartElementWithName:(NSString *) name NS: (NSString *) ns;
-(BOOL) isStartElementWithXmlName:(const xmlChar *) name;

-(enum XNodeType) moveToContent;
-(BOOL) moveToElement;
-(BOOL) moveToStartElement;

// These return TRUE if the startElement has a corresponding End tag - i.e. it is not empty
-(BOOL) readStartElement;
-(BOOL) readStartElementWithName:(NSString *) name;
-(BOOL) readStartElementWithName:(NSString *) name NS: (NSString *) ns;
-(BOOL) readStartElementWithXmlName:(const xmlChar *) xName;


-(void) readEndElement;
-(NSString *) readElementString;

-(NSString *) readString;
-(BOOL) read;
-(NSString *) readInnerXml;
-(NSString *) readOuterXml;

-(BOOL) skip;

@end

xmlTextReader* XAllocBufferReader(NSData *buffer);
xmlTextReader* XAllocStringReader(NSString *string);
xmlTextReader* XAllocFileReader(NSString* fileName);

