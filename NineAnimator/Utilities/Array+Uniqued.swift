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

/// Credit to: https://stackoverflow.com/a/46354989
public extension Array where Element: Hashable {
    /// Creates new ordered array without any duplicates.
    /// Unlike a `Set`, this collection will contain the original order
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        // Filter out duplicates by checking if it can be inserted to the Set
        return filter { seen.insert($0).inserted }
    }
}
