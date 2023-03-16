//
//  NPIntegerConfig.swift
//
// Copyright 2023 OpenAlloc LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

public final class NPIntegerConfig<T>: NPBaseConfig<T>
    where T: FixedWidthInteger & Comparable
{
    // MARK: - Parameters

    public init(_ val: T,
                upperBound: T = T.max)
    {
        let formatter = {
            let nf = NumberFormatter()
            nf.locale = Locale.current
            nf.numberStyle = .decimal
            nf.usesGroupingSeparator = false
            nf.isLenient = true
            nf.minimumFractionDigits = 0
            nf.maximumFractionDigits = 0
            nf.generatesDecimalNumbers = true
            return nf
        }()

        let sVal = Self.toString(val, upperBound: upperBound, formatter: formatter)

        super.init(sValue: sVal, upperBound: upperBound, formatter: formatter)
    }

    // MARK: - Internal

    internal static func toString(_ val: T, upperBound: T, formatter: NumberFormatter) -> String {
        let clampedValue = max(0, min(val, upperBound))
        let doubleValue = Double(clampedValue)
        return formatter.string(from: doubleValue as NSNumber) ?? "0"
    }

    override internal func toValue(_ str: String) -> T? {
        guard let val: NSNumber = formatter.number(from: str),
              let val2: T = val as? T
        else { return nil }
        return val2
    }
}
