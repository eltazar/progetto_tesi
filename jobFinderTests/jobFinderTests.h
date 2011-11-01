//
//  jobFinderTests.h
//  jobFinderTests
//
//  Created by mario greco on 15/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "DatabaseAccess.h"
@interface jobFinderTests : SenTestCase <DatabaseAccessDelegate>{
    DatabaseAccess *db;
    NSMutableArray *jobs;
    NSString *controlString;
    int testCompleteness;
}

@end
