/*
 Copyright (c) 2014, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SFSyncDownTarget.h"
#import "SFMruSyncDownTarget.h"
#import "SFSoqlSyncDownTarget.h"
#import "SFSoslSyncDownTarget.h"
#import "SFSmartSyncConstants.h"
#import <SalesforceSDKCore/SalesforceSDKConstants.h>

// query types
NSString * const kSFSyncTargetQueryTypeMru = @"mru";
NSString * const kSFSyncTargetQueryTypeSoql = @"soql";
NSString * const kSFSyncTargetQueryTypeSosl = @"sosl";
NSString * const kSFSyncTargetQueryTypeCustom = @"custom";


@implementation SFSyncDownTarget

#pragma mark - From/to dictionary

+ (SFSyncDownTarget*) newFromDict:(NSDictionary*)dict {
    NSString* implClassName;
    switch ([SFSyncDownTarget queryTypeFromString:dict[kSFSyncTargetTypeKey]]) {
    case SFSyncDownTargetQueryTypeMru:
        return [SFMruSyncDownTarget newFromDict:dict];
    case SFSyncDownTargetQueryTypeSosl:
        return [SFSoslSyncDownTarget newFromDict:dict];
    case SFSyncDownTargetQueryTypeSoql:
         return [SFSoqlSyncDownTarget newFromDict:dict];
    case SFSyncDownTargetQueryTypeCustom:
        implClassName = dict[kSFSyncTargetiOSImplKey];
        return [NSClassFromString(implClassName) newFromDict:dict];
    }
    // Fell through
    return nil;
}

- (NSDictionary*) asDict ABSTRACT_METHOD

# pragma mark - Data fetching

- (void) startFetch:(SFSmartSyncSyncManager*)syncManager
       maxTimeStamp:(long long)maxTimeStamp
         errorBlock:(SFSyncDownTargetFetchErrorBlock)errorBlock
      completeBlock:(SFSyncDownTargetFetchCompleteBlock)completeBlock
ABSTRACT_METHOD

- (void) continueFetch:(SFSmartSyncSyncManager*)syncManager
            errorBlock:(SFSyncDownTargetFetchErrorBlock)errorBlock
         completeBlock:(SFSyncDownTargetFetchCompleteBlock)completeBlock
{
    completeBlock(nil);
}

#pragma mark - string to/from enum for query type

+ (SFSyncDownTargetQueryType) queryTypeFromString:(NSString*)queryType {
    if ([queryType isEqualToString:kSFSyncTargetQueryTypeSoql]) {
        return SFSyncDownTargetQueryTypeSoql;
    }
    if ([queryType isEqualToString:kSFSyncTargetQueryTypeMru]) {
        return SFSyncDownTargetQueryTypeMru;
    }
    if ([queryType isEqualToString:kSFSyncTargetQueryTypeSosl]) {
        return SFSyncDownTargetQueryTypeSosl;
    }
    // Must be custom
    return SFSyncDownTargetQueryTypeCustom;
}

+ (NSString*) queryTypeToString:(SFSyncDownTargetQueryType)queryType {
    switch (queryType) {
        case SFSyncDownTargetQueryTypeMru:  return kSFSyncTargetQueryTypeMru;
        case SFSyncDownTargetQueryTypeSosl: return kSFSyncTargetQueryTypeSosl;
        case SFSyncDownTargetQueryTypeSoql: return kSFSyncTargetQueryTypeSoql;
        case SFSyncDownTargetQueryTypeCustom: return kSFSyncTargetQueryTypeCustom;
    }
}

@end
