//
//  TestStatus.swift
//  
//
//  Created by asukhodolova on 8.11.22.
//

import Foundation

public enum TestStatus: String {
  case passed = "PASSED"
  case failed = "FAILED"
  case skipped = "SKIPPED"
  case inProgress = "IN PROGRESS"
  case aborted = "ABORTED"
}
