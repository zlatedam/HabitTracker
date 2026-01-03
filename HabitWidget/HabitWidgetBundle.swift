//
//  HabitWidgetBundle.swift
//  HabitWidget
//
//  Created by Zlatko Damcevski on 3/1/2026.
//

import WidgetKit
import SwiftUI

@main
struct HabitWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitWidget()
        HabitWidgetControl()
        HabitWidgetLiveActivity()
    }
}
