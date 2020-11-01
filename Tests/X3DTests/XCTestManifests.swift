import XCTest

#if !canImport(ObjectiveC)
public func allTests () -> [XCTestCaseEntry]
{
   return [
      testCase (X3DTests .allTests),
   ]
}
#endif
