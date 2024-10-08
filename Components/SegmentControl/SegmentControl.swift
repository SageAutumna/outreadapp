//
//  SegmentControl.swift
//  Outread
//
//  Created by iosware on 18/08/2024.
//

import SwiftUI

public struct GridSegmentControl: View {
    
    public let segments: [Segment]
    @Binding var activeSegment: String
    
    let style: SegmentControlStyler
    let leftAligned: Bool
    
    var segmentTapped:((Segment) -> Void)?
    
    public init(segments: [Segment],
                activeSegment: Binding<String>,
                leftAligned: Bool = (UIDevice.current.userInterfaceIdiom == .pad),
                style: SegmentControlStyler,
                segmentTapped: ((Segment) -> Void)? = nil) {
        
        self.segments       = segments
        self._activeSegment = activeSegment
        self.style          = style
        self.leftAligned    = leftAligned
        self.segmentTapped  = segmentTapped
    }
    
    public var body: some View {
        HStack {
            Grid(horizontalSpacing: leftAligned ? 8 : 10) {
                GridRow {
                    ForEach(segments) { segment in
                        SegmentButtonView(
                            segment: segment,
                            style: style,
                            activeSegment: $activeSegment,
                            scrollViewProxy: nil,
                            segmentTapped: segmentTapped
                        )
                    }
                }
            }
            
            if leftAligned {
                Spacer()
            }
        }
    }
}

public struct SegmentControl: View {
    
    public let segments: [Segment]
    var spacing: CGFloat = 8
    var scrollable: Bool
    @Binding var activeSegment: String
    
    let style: SegmentControlStyler
    
    var segmentTapped:((Segment) -> Void)?
    
    public init(segments: [Segment],
                spacing: CGFloat = 16,
                scrollable: Bool = true,
                activeSegment: Binding<String>,
                style: SegmentControlStyler,
                segmentTapped: ((Segment) -> Void)? = nil) {
        
        self.segments       = segments
        self.spacing        = spacing
        self.scrollable     = scrollable
        self._activeSegment = activeSegment
        self.style          = style
        self.segmentTapped  = segmentTapped
    }
    
    public var body: some View {
        
        Group {
            if scrollable {
                ScrollViewReader { scrollViewProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HSTackSegmentedControl(
                            spacing: spacing,
                            segments: segments,
                            style: style,
                            activeSegment: $activeSegment,
                            scrollViewProxy: scrollViewProxy,
                            segmentTapped: self.segmentTapped
                        )
                    }
                }
            }
            else {
                HSTackSegmentedControl(
                    spacing: spacing,
                    segments: segments,
                    style: style,
                    activeSegment: $activeSegment,
                    segmentTapped: self.segmentTapped
                )
                .padding(.horizontal, 10)
            }
        }
    }
    
}

// MARK: - Mutators

extension SegmentControl {
    
    /// If the Segments contains the new active segment provided then
    /// selected it as the new one, otherwise fail quietly
    ///
    /// - Parameter newActiveSegment: **String**
    public mutating func update(activeSegment newActiveSegment: String) {
        
        if segments.contains(where: { $0.title == newActiveSegment }) {
            activeSegment = newActiveSegment
        }
    }
    
    public mutating func update(activeSegmentIdx newSegmentIdx: Int) {
        if newSegmentIdx < segments.count {
            activeSegment = segments[newSegmentIdx].title
        }
    }
}

// MARK: - HSTackSegmentedControl

private struct HSTackSegmentedControl: View {
    
    let spacing: CGFloat
    let segments: [Segment]
    let style: SegmentControlStyler
    
    @Binding var activeSegment: String
    var scrollViewProxy: ScrollViewProxy?
    
    var segmentTapped:((Segment) -> Void)?
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(Array(segments.enumerated()), id: \.offset) { (idx, segment) in
                withAnimation {
                    SegmentButtonView(
                        segment: segment,
                        style: style,
                        activeSegment: $activeSegment,
                        scrollViewProxy: scrollViewProxy,
                        segmentTapped: segmentTapped
                    )
                    .id(segment.id)
                    .padding(.vertical)
                    .hoverEffect()
                }
            }
        }
        .padding(.top)
        .padding(.horizontal, 10)
        .padding(.bottom, 6)
        .onAppear {

            // Scroll to the active segment on appear
            if let activeSegment = self.segments.first(where: { $0.title == self.activeSegment }) {
            
                scrollViewProxy?.scrollTo(activeSegment.id)
            }
        }
    }
}

// MARK: - SegmentButtonView

private struct SegmentButtonView: View {
    
    let segment: Segment
    let style: SegmentControlStyler
    
    @Binding var activeSegment: String
    var scrollViewProxy: ScrollViewProxy?
    
    var segmentTapped:((Segment) -> Void)?
    
    private func isActiveSegment(currentSegment: Segment) -> Bool {
        (currentSegment.title == activeSegment)
    }
    
    var body: some View {
        Button {
            activeSegment = segment.title
            segmentTapped?(segment)
            
            if let scrollViewProxy {
                withAnimation {
                    scrollViewProxy.scrollTo(segment.id)
                }
            }
        } label: {
            
            switch self.style.style {
                case .underline:
                    UnderlineSegmentButtonView(
                        segment: segment,
                        style: style,
                        isActiveSegment: isActiveSegment(currentSegment: segment)
                    )
                    
                case .capsule:
                    Text(segment.title)
                        .font(isActiveSegment(currentSegment: segment) ? style.font.active : style.font.inactive)
                        .foregroundColor((segment.title == activeSegment) ? style.textColor.active : style.textColor.inactive)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(isActiveSegment(currentSegment: segment) ? style.activeBarColor : Color.clear)
                        .clipShape(Capsule())
                    
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - UnderlineSegment - ButtonView

private struct UnderlineSegmentButtonView: View {
    
    let segment: Segment
    let style: SegmentControlStyler
    
    let isActiveSegment: Bool
    
    var body: some View {
        
        VStack(spacing: 4) {
            Text(segment.title)
                .font(isActiveSegment ? style.font.active : style.font.inactive)
                .foregroundColor(isActiveSegment ? style.textColor.active : style.textColor.inactive)
            
            (isActiveSegment ? style.activeBarColor : Color.clear)
                .cornerRadius(style.activeBarWidth / 2)
                .frame(height: style.activeBarWidth)
        }
    }
}

// MARK: - Preview

struct SegmentControlWrapper: View {
    var body: some View {
        VStack {
            
            if #available(iOS 16.0, *) {
                GridSegmentControl(
                    segments: [
                        Segment(title: "Item One"),
                        Segment(title: "Item Two"),
                        Segment(title: "Item Three")
                    ],
                    activeSegment: .constant("Item One"),
                    leftAligned: true,
                    style: SegmentControlStyler(
                        style: .capsule,
                        font: Font.system(size: 16, weight: .semibold),
                        textColor: SegmentControlStylerColor(active: Color.white, inactive: Color.gray),
                        activeBarColor: Color.blue
                    ),
                    segmentTapped: nil
                )
                
                GridSegmentControl(
                    segments: [
                        Segment(title: "Item 1"),
                        Segment(title: "Item 2"),
                        Segment(title: "Item 3")
                    ],
                    activeSegment: .constant("Item 1"),
                    leftAligned: false,
                    style: SegmentControlStyler(
                        style: .capsule,
                        font: .customFont(font: .poppins, style: .medium, size: .s18),
                        textColor: SegmentControlStylerColor(active: Color(.mainBlue), inactive: Color(.white60)),
                        activeBarColor: .white
                    ),
                    segmentTapped: nil
                )
                .background(
                    RoundedRectangle(cornerRadius: 45)
                        .fill(Color(.white5))
                )
            }
            
            SegmentControl(
                segments: [
                    Segment(title: "Study"),
                    Segment(title: "Practice")
                ],
                scrollable: false,
                activeSegment: .constant("Study"),
                style: SegmentControlStyler(
                    font: Font.system(size: 22, weight: .bold),
                    textColor: SegmentControlStylerColor(active: Color.black, inactive: Color.gray),
                    activeBarColor: Color.blue
                )
            )
            
            SegmentControl(
                segments: [
                    Segment(title: "Section One"),
                    Segment(title: "Section Two"),
                    Segment(title: "Section Three")
                ],
                spacing: 0,
                activeSegment: .constant("Section Two"),
                style: SegmentControlStyler(
                    style: .capsule,
                    font: Font.system(size: 16, weight: .semibold),
                    textColor: SegmentControlStylerColor(active: Color.white, inactive: Color.gray),
                    activeBarColor: Color.blue)
            )
            
            SegmentControl(
                segments: [
                    Segment(title: "Section One"),
                    Segment(title: "Section Two"),
                    Segment(title: "Section Three")
                ],
                activeSegment: .constant("Section Two"),
                style: SegmentControlStyler(
                    font: Font.system(size: 22, weight: .bold),
                    textColor: SegmentControlStylerColor(active: Color.black, inactive: Color.gray),
                    activeBarColor: Color.blue)
            )
            
            SegmentControl(
                segments: [
                    Segment(title: "Section One"),
                    Segment(title: "Section Two"),
                    Segment(title: "Section Three"),
                    Segment(title: "Section Four"),
                    Segment(title: "Section Five"),
                    Segment(title: "Section Six"),
                ],
                activeSegment: .constant("Section Two"),
                style: SegmentControlStyler(
                    font: Font.system(size: 22, weight: .bold),
                    textColor: SegmentControlStylerColor(active: Color.black, inactive: Color.gray),
                    activeBarColor: Color.blue)
            )
            Spacer()
        }
    }
}

#Preview {
    SegmentControlWrapper()
}
