//
//  SearchSegmentFilter.swift
//  Outread
//
//  Created by iosware on 19/08/2024.
//

import SwiftUI

struct SearchSegmentFilter: View {
    @State private var activeSegment: String = "Popular"
    var width: CGFloat
    private let segments: [Segment] = SearchType.allCases.map({Segment(title:  $0.title, object: $0)})
    private let padding: CGFloat = 10

    var onSegmentSelected: ((SearchType) -> Void)? = nil
    
    var body: some View {
        GridSegmentControl(
            segments: segments,
            activeSegment: $activeSegment,
            leftAligned: false,
            style: SegmentControlStyler(
                style: .capsule,
                font: .customFont(font: .poppins, style: .medium, size: .s16),
                textColor: SegmentControlStylerColor(active: Color(.mainBlue), inactive: Color(.white60)),
                activeBarColor: .white
            ),
            segmentTapped: { segment in
                activeSegment = segment.title
                onSegmentSelected?(segment.object as? SearchType ?? SearchType.recent)
            }
        )
        .frame(width: max(0, width - 2 * padding), height: 28)
        .padding(.init(top: 9, leading: padding, bottom: 9, trailing: padding))
        .background(
            RoundedRectangle(cornerRadius: 45)
                .fill(Color(.white5))
        )
    }
}

#Preview {
    SearchSegmentFilter(width: 400)
        .background(.black)
}
