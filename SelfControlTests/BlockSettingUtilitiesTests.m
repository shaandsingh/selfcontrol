//
//  BlockDateUtilitiesTests.m
//  SelfControlTests
//
//  Created by Charles Stigler on 17/07/2018.
//

#import <XCTest/XCTest.h>
#import "SCBlockSettingUtilities.h"

@interface BlockSettingUtilitiesTests : XCTestCase

@end

// Static dictionaries of block values to test against

// Test info dictionaries
NSDictionary* runningDict; // Settings dict that has a block running (ending in 5 min, BlockIsRunning = YES)
NSDictionary* shouldBeRunningButNotDict; // Settings dict that should have a block running (ending in 5 min) but does not (BlockISRunning = NO)
NSDictionary* shouldNotBeRunningButIsDict; // Settings dict that should not a block running (no BlockEndDate) but does (BlockISRunning = YES)

NSDictionary* shouldBeRunningLegacyDict; // Enabled + active legacy dictionary way (started 5 minutes ago, duration 10 min)
NSDictionary* shouldNotBeRunningLegacyDict; // Inactive old way (started 10 minutes 5 seconds ago, duration 10 min)
NSDictionary* disabledLegacyDict; // Disabled old way (start date removed)

NSDictionary* clearDict; // Completely clear defaults (first run)

@implementation BlockSettingUtilitiesTests

- (NSUserDefaults*)testDefaults {
    return [[NSUserDefaults alloc] initWithSuiteName: @"BlockSettingUtilitiesTests"];
}

+ (void)setUp {
    // Initialize the sample data dictionaries
    runningDict = @{
                                @"BlockEndDate": [NSDate dateWithTimeIntervalSinceNow: 300]
                                };
    enabledInactiveOldWayDict = @{
                                  @"BlockStartedDate": [NSDate dateWithTimeIntervalSinceNow: -605],
                                  @"BlockDuration": @10,
                                  @"BlockEndDate": [NSNull null]
                                  }; // Enabled + inactive old way (started 10 minutes 5 seconds ago, duration 10 min)
    disabledOldWayDict = @{
                           @"BlockStartedDate": [NSDate distantFuture],
                           @"BlockDuration": @10,
                           @"BlockEndDate": [NSNull null]
                           };
    enabledActiveNewWayDict = @{
                                @"BlockStartedDate": [NSNull null],
                                @"BlockDuration": @10,
                                @"BlockEndDate": [NSDate dateWithTimeIntervalSinceNow: 300]
                                };
    enabledInactiveNewWayDict = @{
                                  @"BlockStartedDate": [NSNull null],
                                  @"BlockDuration": @10,
                                  @"BlockEndDate": [NSDate dateWithTimeIntervalSinceNow: -5]
                                  };
    enabledActiveNewWayConflictingInfoDict = @{
                                               @"BlockStartedDate": [NSDate dateWithTimeIntervalSinceNow: -605],
                                               @"BlockDuration": @10,
                                               @"BlockEndDate": [NSDate dateWithTimeIntervalSinceNow: 300]
                                               };
    disabledNewWayDict = @{
                           @"BlockStartedDate": [NSNull null],
                           @"BlockDuration": @10,
                           @"BlockEndDate": [NSDate distantPast]
                           };
    enabledOldDisabledNewDict = @{
                                  @"BlockStartedDate": [NSDate dateWithTimeIntervalSinceNow: -300],
                                  @"BlockDuration": @10,
                                  @"BlockEndDate": [NSDate distantPast]
                                  };
    clearDict = @{
                  @"BlockEndDate": [NSNull null],
                  @"BlockStartedDate": [NSNull null],
                  @"BlockDuration": [NSNull null]
                  };
}

- (void)setUp {
    [super setUp];

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBlockEnabledActive {
    NSUserDefaults* defaults = [self testDefaults];
    
    // Enabled + active old way (started 5 minutes ago, duration 10 min)
    [defaults setValuesForKeysWithDictionary: enabledActiveOldWayDict];
    XCTAssert([SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert([SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    
    // Enabled + inactive old way (started 10 minutes 5 seconds ago, duration 10 min)
    [defaults setValuesForKeysWithDictionary: enabledInactiveOldWayDict];
    XCTAssert([SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert(![SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    
    // Disabled old way
    [defaults setValuesForKeysWithDictionary: disabledOldWayDict];
    XCTAssert(![SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert(![SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    
    // Enabled + active new way (started 5 minutes ago, duration 10 min)
    [defaults setValuesForKeysWithDictionary: enabledActiveNewWayDict];
    XCTAssert([SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert([SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    
    // Enabled + inactive new way (started 10 minutes 5 seconds ago, duration 10 min)
    [defaults setValuesForKeysWithDictionary: enabledInactiveNewWayDict];
    XCTAssert([SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert(![SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    
    // Enabled + active new way, but with old values showing conflicting info
    [defaults setValuesForKeysWithDictionary: enabledActiveNewWayConflictingInfoDict];
    XCTAssert([SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert([SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    
    // Disabled new way
    [defaults setValuesForKeysWithDictionary: disabledNewWayDict];
    XCTAssert(![SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert(![SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    
    // Disabled new way, but enabled/active via the old way
    [defaults setValuesForKeysWithDictionary: enabledOldDisabledNewDict];
    XCTAssert([SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert([SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    

    // Completely clear
    [defaults setValuesForKeysWithDictionary: clearDict];
    XCTAssert(![SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert(![SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
}

- (void)testStartBlock {
    NSUserDefaults* defaults = [self testDefaults];
    NSDate* blockEndDate;
    NSDate* expectedEndDate;
    
    // Start from disabled (new way) with 10 min block duraion
    [defaults setValuesForKeysWithDictionary: disabledNewWayDict];
    [SCBlockDateUtilities startBlockInDefaults: defaults];
    XCTAssert([SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert([SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    // Block end date should now be 10 min from now (with minor margin for timing error)
    blockEndDate = defaults.dictionaryRepresentation[@"BlockEndDate"];
    expectedEndDate = [NSDate dateWithTimeIntervalSinceNow: 600];
    XCTAssert([blockEndDate timeIntervalSinceDate: expectedEndDate] < 2 && [blockEndDate timeIntervalSinceDate: expectedEndDate] > -2);
    
    // Start from disabled (old way) with 10 min block duraion
    [defaults setValuesForKeysWithDictionary: disabledOldWayDict];
    [SCBlockDateUtilities startBlockInDefaults: defaults];
    XCTAssert([SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert([SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    // Block end date should now be 10 min from now (with minor margin for timing error)
    blockEndDate = defaults.dictionaryRepresentation[@"BlockEndDate"];
    expectedEndDate = [NSDate dateWithTimeIntervalSinceNow: 600];
    XCTAssert([blockEndDate timeIntervalSinceDate: expectedEndDate] < 2 && [blockEndDate timeIntervalSinceDate: expectedEndDate] > -2);
    // Old BlockStartedDate Property should be cleared
    NSDate* blockStartedDate = [defaults objectForKey: @"BlockStartedDate"];
    XCTAssert(blockStartedDate == nil || [blockStartedDate isEqualToDate: [NSDate distantFuture]]);

    // Start from clear (no block duration)
    // Block duration defaults to 15 min, so it should start block with duration 15 minutes
    [defaults setValuesForKeysWithDictionary: clearDict];
    [SCBlockDateUtilities startBlockInDefaults: defaults];
    XCTAssert([SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert([SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    // Block end date should be now (with minor margin for timing error)
    blockEndDate = defaults.dictionaryRepresentation[@"BlockEndDate"];
    expectedEndDate = [NSDate dateWithTimeIntervalSinceNow: 900];
    XCTAssert([blockEndDate timeIntervalSinceDate: expectedEndDate] < 2 && [blockEndDate timeIntervalSinceDate: expectedEndDate] > -2);
    
    // Start when block is already active - should keep block active, but change the block ending date
    [defaults setValuesForKeysWithDictionary: enabledActiveNewWayDict];
    [defaults setValue: @20 forKey: @"BlockDuration"]; // change duration so we can notice the block ending date changing
    [SCBlockDateUtilities startBlockInDefaults: defaults];
    XCTAssert([SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert([SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    // Block end date should be 20 min from now (with minor margin for timing error)
    blockEndDate = defaults.dictionaryRepresentation[@"BlockEndDate"];
    expectedEndDate = [NSDate dateWithTimeIntervalSinceNow: 1200];
    XCTAssert([blockEndDate timeIntervalSinceDate: expectedEndDate] < 2 && [blockEndDate timeIntervalSinceDate: expectedEndDate] > -2);
}

- (void)testRemoveBlock {
    NSUserDefaults* defaults = [self testDefaults];
    
    // Remove when block is active/enabled with new properties
    [defaults setValuesForKeysWithDictionary: enabledActiveNewWayDict];
    [SCBlockDateUtilities removeBlockFromDefaults: defaults];
    XCTAssert(![SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert(![SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    
    // Remove when block is active/enabled with old properties
    [defaults setValuesForKeysWithDictionary: enabledActiveOldWayDict];
    [SCBlockDateUtilities removeBlockFromDefaults: defaults];
    XCTAssert(![SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert(![SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    
    // Remove when block is enabled but inactive with new properties
    [defaults setValuesForKeysWithDictionary: enabledInactiveNewWayDict];
    [SCBlockDateUtilities removeBlockFromDefaults: defaults];
    XCTAssert(![SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert(![SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    
    // Remove when block is enabled but inactive with old properties
    [defaults setValuesForKeysWithDictionary: enabledInactiveOldWayDict];
    [SCBlockDateUtilities removeBlockFromDefaults: defaults];
    XCTAssert(![SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert(![SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
    
    // Remove when block is already disabled (should stay disabled)
    [defaults setValuesForKeysWithDictionary: disabledNewWayDict];
    [SCBlockDateUtilities removeBlockFromDefaults: defaults];
    XCTAssert(![SCBlockDateUtilities blockIsRunningInDictionary: defaults.dictionaryRepresentation]);
    XCTAssert(![SCBlockDateUtilities blockShouldBeRunningInDictionary: defaults.dictionaryRepresentation]);
}


@end