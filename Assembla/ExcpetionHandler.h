//
//  ExcpetionHandler.h
//  Assembla
//
//  Created by Brian Beversdorf on 9/21/21.
//

#ifndef ExcpetionHandler_h
#define ExcpetionHandler_h
#import <Foundation/Foundation.h>

NS_INLINE NSException * _Nullable ExecuteWithObjCExceptionHandling(void(NS_NOESCAPE^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}

#endif /* ExcpetionHandler_h */
