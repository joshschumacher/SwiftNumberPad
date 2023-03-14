//
//  NumPadFloat.swift
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

// TODO: assumes lowerBound of 0; support negative values
public final class NumPadFloat<T>: NumPadBase<T>
    where T: BinaryFloatingPoint
{
    // MARK: - parameters

    @Published private(set) var sValue: String
    internal let precision: Int
    internal let formatter: NumberFormatter
    internal let upperBound: T

    public init(_ dvalue: T,
                precision: Int = NumPad.defaultPrecision,
                upperBound: T = T.greatestFiniteMagnitude)
    {
        formatter = {
            let nf = NumberFormatter()
            nf.locale = Locale.current
            nf.numberStyle = .decimal
            nf.usesGroupingSeparator = false
            nf.isLenient = true
            nf.minimumFractionDigits = 0
            nf.maximumFractionDigits = precision
            nf.generatesDecimalNumbers = true
            return nf
        }()

        let clampedValue = max(0, min(dvalue, upperBound))
        let doubleValue = Double(clampedValue)

        sValue = formatter.string(from: doubleValue as NSNumber) ?? "0"
        self.precision = precision
        self.upperBound = upperBound
    }

    // MARK: - Public Properties

    override public var stringValue: String {
        sValue
    }

    override public var value: T? {
        toValue(sValue)
    }

    override var isClear: Bool {
        sValue == "0"
    }

    // MARK: - Public Actions

    override public func clearAction() {
        sValue = "0"
    }

    override public func digitAction(_ digit: NumPad) -> Bool {
        guard digit.isDigit else { return false }
        let strNum = digit.toString
        if isClear {
            sValue = strNum
        } else {
            let cp = currentPrecision
            if cp > 0, cp == precision { return false } // ignore additional input

            let nuValue = sValue.appending(strNum)

            guard let nuDValue = toValue(nuValue),
                  nuDValue <= upperBound else { return false }

            sValue = nuValue
        }

        return true
    }

    override public func backspaceAction() {
        if sValue.count <= 1 {
            clearAction()
        } else {
            sValue.removeLast()
        }
    }

    override public func decimalPointAction() -> Bool {
        guard decimalPointIndex == nil else { return false }
        sValue.append(".")

        return true
    }

    // MARK: - Internal Properties/Helpers

    internal func toValue(_ str: String) -> T? {
        guard let val: NSNumber = formatter.number(from: str),
              let val2: T = val as? T
        else { return nil }
        return val2
    }

    internal var currentPrecision: Int {
        guard let di = decimalPointIndex else { return 0 }
        return sValue.distance(from: di, to: sValue.endIndex) - 1
    }

    internal var decimalPointIndex: String.Index? {
        sValue.firstIndex(of: ".")
    }
}