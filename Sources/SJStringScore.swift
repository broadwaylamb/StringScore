//  Based on string_score 0.1.21 by Joshaven Potter.
//  https://github.com/joshaven/string_score/
//
//  Copyright © 2016 YICHI ZHANG
//  https://github.com/yichizhang
//  zhang-yi-chi@hotmail.com
//
//  Copyright © 2017 Sergej Jaskiewicz
//  https://github.com/broadwaylamb
//  jaskiewiczs@icloud.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Foundation

public extension String {

    /// Calculate the score of the `word` against `self`.
    ///
    /// - Parameters:
    ///   - word: The word to search in the string.
    ///   - fuzziness: A number between 0 and 1 which varies how fuzzy the calculation is.
    ///                Defaults to `nil` (fuzziness disabled).
    /// - Returns: The score betwee 0 to 1.
    public func score(_ word: String, fuzziness: Double? = nil) -> Double {

        // If the string is equal to the word, perfect match.
        if self == word {
            return 1
        }

        // If it's not a perfect match and is empty return 0
        if word.isEmpty || self.isEmpty {
            return 0
        }

        var runningScore = 0.0
        var charScore = 0.0
        var finalScore = 0.0
        let lowercasedString = self.lowercased()
        let stringLength = self.count
        var lWord = word.lowercased()
        let wordLength = word.count
        var idxOf: String.Index!
        var startAt = lowercasedString.startIndex
        var fuzzies = 1.0
        var fuzzyFactor = 0.0

        // Cache fuzzyFactor for speed increase
        if let fuzziness = fuzziness {
            fuzzyFactor = 1 - fuzziness
        }

        for i in 0 ..< wordLength {

            // Find next first case-insensitive match of word's i-th character.
            // The search in "string" begins at "startAt".
            if let range = lowercasedString.range(
                of: String(lWord[lWord.index(lWord.startIndex, offsetBy: i)] as Character),
                options: .caseInsensitive,
                range: startAt..<lowercasedString.endIndex,
                locale: nil) {

                // start index of word's i-th character in string.
                idxOf = range.lowerBound
                if startAt == idxOf {
                    // Consecutive letter & start-of-string Bonus
                    charScore = 0.7
                } else {
                    charScore = 0.1

                    // Acronym Bonus
                    // Weighing Logic: Typing the first character of an acronym is as if you
                    // preceded it with two perfect character matches.
                    if self[self.index(idxOf, offsetBy: -1)] == " " {
                        charScore += 0.8
                    }
                }
            } else {
                // Character not found.
                if fuzziness == nil {
                    return 0
                } else {
                    fuzzies += fuzzyFactor
                    continue
                }
            }

            // Same case bonus.
            if (self[idxOf] == word[word.index(word.startIndex, offsetBy: i)]) {
                charScore += 0.1
            }

            // Update scores and startAt position for next round of indexOf
            runningScore += charScore
            startAt = self.index(idxOf, offsetBy: 1)
        }

        // Reduce penalty for longer strings.
        finalScore = 0.5 * (runningScore / Double(stringLength) + runningScore / Double(wordLength)) / fuzzies

        if (lWord[lWord.startIndex] == lowercasedString[lowercasedString.startIndex]) && (finalScore < 0.85) {
            finalScore += 0.15
        }
        
        return finalScore
    }
}
