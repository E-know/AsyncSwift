//
//  StampView.swift
//  AsyncSwift
//
//  Created by Inho Choi on 2022/10/29.
//

import SwiftUI
import UIKit

struct StampView: View {
    @StateObject var observed = Observed()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ScrollViewReader { value in
                ZStack {
                    ForEach(0..<observed.cards.count, id: \.self) { index in
                        observed.cards[observed.events![index]]!.currentImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .offset(y: calculateY(index: index))
                            .onTapGesture {
                                if index == observed.currentIndex {
                                        if observed.isExpand {
                                            withAnimation(.spring()) {
                                                observed.cards[observed.events![index]]!.currentImage = observed.cards[observed.events![index]]!.image
                                                observed.isExpand = false
                                            }
                                        } else {
                                            withAnimation(.spring()) {
                                                observed.cards[observed.events![index]]!.currentImage = observed.cards[observed.events![index]]!.imageExtend
                                                observed.isExpand = true
                                            }
                                        }
                                } else {
                                    withAnimation(.spring()) {
                                        observed.cards[observed.events![index]]!.isSelected = true
                                        observed.cards[observed.events![observed.currentIndex]]!.isSelected = false
                                        if observed.isExpand {
                                            observed.cards[observed.events![observed.currentIndex]]!.currentImage = observed.cards[observed.events![observed.currentIndex]]!.image
                                            observed.isExpand = false
                                        }
                                        observed.currentIndex = index
                                    }
                                }
//                                print("====Seminar002====")
//                                let seminar = observed.cards["Seminar002"]!
//                                print("Selected", seminar.isSelected)
//                                print("OriginalPositon", seminar.originalPosition)
//                                print("====Conference001====")
//                                let conference = observed.cards["Conference001"]!
//                                print("Selected", conference.isSelected)
//                                print("OriginalPositon", conference.originalPosition)
//                                print("====View====")
//                                print("currentIndex", currentIndex)
//                                print("isExtend", isExpand)
                            }
                    }
                }
                .offset(y: UIScreen.main.bounds.height / 2)
            }
            Spacer(minLength: observed.isExpand ? UIScreen.main.bounds.height : 0)
        }
        .padding()
        .onOpenURL{ url in
            Task {
                await observed.openByLink(url: url)
            }
        }
    } // body
}

extension StampView {
    func calculateY(index : Int?) -> CGFloat {
        withAnimation(.spring()) {
            guard let index = index else { return .zero }
            var result: CGFloat
            if observed.cards[observed.events![index]]!.isSelected {
                result = .zero - UIScreen.main.bounds.height / 2
            } else {
                result = observed.cards[observed.events![index]]!.originalPosition
            }
            return result
        }
    }
}

struct StampView_Previews: PreviewProvider {
    static var previews: some View {
        StampView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
        
        StampView()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
    }
}


