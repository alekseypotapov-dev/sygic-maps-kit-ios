//// SYRouteExtension.swift
//
// Copyright (c) 2019 - Sygic a.s.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the &quot;Software&quot;), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SygicMaps
import SygicUIKit


public extension SYRoute {
    
    func formatedDuration(useSpeedProfile: Bool = true, useTraffic: Bool = true) -> String {
        var duration = info.durationIdeal
        if useSpeedProfile && useTraffic {
            duration = info.durationWithSpeedProfileAndTraffic
        } else if useSpeedProfile {
            duration = info.durationWithSpeedProfile
        }
        return formattedTimeInterval(duration)
    }
    
    func formatedTrafficDelay(useSpeedProfile: Bool = true) -> String? {
        var duration = info.durationIdeal
        if useSpeedProfile {
            duration = info.durationWithSpeedProfile
        }
        let trafficDelay = info.durationWithSpeedProfileAndTraffic - duration
        let delayMinutes = Int(trafficDelay/60)
        guard delayMinutes > 0 else { return nil }
        return formattedTimeInterval(trafficDelay)
    }
    
    func formattedDistance(_ units: SYUIDistanceUnits = .kilometers) -> String {
        let distance = info.length
        let formattedDistance = distance.format(toShortUnits: true, andRound: distance>1000, usingOtherThenFormattersUnits: units)
        return "\(formattedDistance.formattedDistance)\(formattedDistance.units)"
    }
    
    private func formattedTimeInterval(_ timeInterval: TimeInterval) -> String {
        if timeInterval < 60*60 {
            return String(format: "%i%@", Int(timeInterval/60), LS("min"))
        } else {
            let min = Float(timeInterval).truncatingRemainder(dividingBy: 60*60)
            return String(format: "%i%@%i%@", Int(timeInterval/60/60), LS("h"), Int(min/60), LS("min"))
        }
    }
}
