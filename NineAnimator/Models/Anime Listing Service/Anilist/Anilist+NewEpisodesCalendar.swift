//
//  This file is part of the NineAnimator project.
//
//  Copyright © 2018-2020 Marcus Zhou. All rights reserved.
//
//  NineAnimator is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  NineAnimator is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with NineAnimator.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
extension Anilist {
    /// Recommends upcoming episodes for anime's that are on the user's `Watching` / `Planning to Watch List` for the week
    class NewEpisodesCalendar: RecommendationSource {
        let name = "Upcoming Episodes"
        let piority: RecommendationSource.Piority = .defaultHigh
        var shouldPresentRecommendation: Bool { parent.didSetup }
        
        private var generatedRecommendation: Recommendation?
        private let parent: Anilist
        
        init(_ parent: Anilist) {
            self.parent = parent
        }
        
        func shouldReload(recommendation: Recommendation) -> Bool {
            false
        }
        
        func generateRecommendations() -> NineAnimatorPromise<Recommendation> {
            if let cachedRecommendation = generatedRecommendation {
                return .success(cachedRecommendation)
            }

            let queue = DispatchQueue.global()
            return NineAnimatorPromise(queue: queue) {
                (callback: @escaping ((Void?, Error?) -> Void)) in
                // Request after 0.6 seconds to avoid congestion
                queue.asyncAfter(deadline: .now() + 0.6) {
                    callback((), nil)
                }
                return nil
            }
            .thenPromise { self.parent.collections() }
            .thenPromise {
                animeCollections -> NineAnimatorPromise<[CalendarItem]> in
                let animesToSearch = animeCollections
                    .filter { $0.title == "Watching" || $0.title == "Planning" }
                    .map { $0.links(on: 1) }
                    .flatMap { $0 }
                    .compactMap {
                        anylink -> Int? in
                        switch anylink {
                        case .listingReference(let reference):
                            return Int(reference.uniqueIdentifier)
                        default:
                            return nil
                        }
                    }
                return self.parent.requestWeeklyCalendar(animeIDs: animesToSearch)
            } .then {
                calendarItems in
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                dateFormatter.doesRelativeDateFormatting = true
                
                let recommendationItems = calendarItems.map {
                    RecommendingItem(
                        .listingReference($0.reference),
                        caption: "Ep. \($0.episode)",
                        subtitle: dateFormatter.string(from: $0.date),
                        synopsis: $0.mediaSynopsis
                    )
                }
                
                return Recommendation(
                    self,
                    items: recommendationItems,
                    title: self.name,
                    subtitle: "For anime on your Watch/Planning List",
                    style: .thisWeek
                )
            }
        }
    }
}
