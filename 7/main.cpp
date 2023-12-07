#include <algorithm>
#include <cstdint>
#include <iostream>
#include <vector>
#include <string>
#include <array>
#include <span>
#include <utility>

#define PART2 1

using namespace std;

constexpr char cardIndex[] = {
#if PART2
    'A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2', 'J',
#else
    'A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2',
#endif
};

constexpr int cardPower(const char card) {
    for (int i = 0; i < sizeof(cardIndex); i++) {
        if (cardIndex[i] == card) {
            return i;
        }
    }
    unreachable();
}

class Hand {
    void updateCards() {
        for (int i = 0; i < sizeof(cardIndex); i++) {
            for (const char c : this->hand) {
                if (c == cardIndex[i]) {
                    this->cards[i]++;
                }
            }
        }
#if PART2
        int maxIndex = 0;
        uint8_t maxValue = 0;
        auto cardsNoJoker = this->cardsButJoker();
        for (int i = 0; i < cardsNoJoker.size(); i++) {
            uint8_t value = cardsNoJoker[i];
            if(value > maxValue) {
                maxIndex = i;
                maxValue = value;
            }
        }
        this->cards[maxIndex] += this->cards[12];
#endif
    }

    span<
        const uint8_t,
#if PART2
    12
#else
    13
#endif
    > cardsButJoker() const {
#if PART2
        return span(this->cards).first<12>();
#else
        return span(this->cards);
#endif
    }

    int8_t uniqueCardCount() const {
        int8_t uniqueCards = 0;
        for (uint8_t count : this->cardsButJoker()) {
            if (count > 0) {
                uniqueCards++;
            }
        }
        return uniqueCards;
    }

public:
    string hand;
    uint16_t bid;
    array<uint8_t, 13> cards = {0};

    void read() {
        getline(cin, this->hand, ' ');
        if (this->hand.empty()) {
            throw std::length_error("eol");
        }
        this->updateCards();

        string bid;
        getline(cin, bid);
        this->bid = static_cast<uint16_t>(stoul(bid));
    }

    int handType() const {
        if (this->isFiveOfAKind()) {
            return 7;
        } else if (this->isFourOfAKind()) {
            return 6;
        } else if (this->isFullHouse()) {
            return 5;
        } else if (this->isThreeOfAKind()) {
            return 4;
        } else if (this->isTwoPair()) {
            return 3;
        } else if (this->isOnePair()) {
            return 2;
        } else if (this->isHighCard()) {
            return 1;
        } else {
            throw runtime_error("WTF hand " + hand);
        }
    }

    bool isFiveOfAKind() const {
        for (uint8_t count : this->cardsButJoker()) {
            if (count == 5) {
                return true;
            }
        }
        return false;
    }

    bool isFourOfAKind() const {
        // AAAAB
        // AAAJB
        for (uint8_t count : this->cardsButJoker()) {
            if (count == 4) {
                return true;
            }
        }
        return false;
    }

    bool isFullHouse() const {
        // AABB1
        // AABBB
        int twoPairCount = 0;
        int threePairCount = 0;
        for(uint8_t count : this->cardsButJoker()) {
            if(count == 2) {
                twoPairCount++;
            }else if(count == 3) {
                threePairCount++;
            }
        }
        return threePairCount == 1 && twoPairCount == 1;
    }

    bool isThreeOfAKind() const {
        bool found3 = false;
        // TTT98
        // TTJ98
        for (uint8_t count : this->cardsButJoker()) {
            if (count == 3) {
                found3 = true;
            } else if (count > 1) {
                return false;
            }
        }
        return found3;
    }

    bool isTwoPair() const {
        // AABB1
        int pairCount = 0;
        for (uint8_t count : this->cards) {
            if (count == 2) {
                pairCount++;
            }
        }
        return pairCount == 2;
    }

    bool isOnePair() const {
        // AA123
        // AJ123
        if (this->uniqueCardCount() != 4) {
            return false;
        }
        for (uint8_t count : this->cardsButJoker()) {
            if (count == 2) {
                return true;
            }
        }
        return false;
    }

    bool isHighCard() const {
        return this->uniqueCardCount() == 5;
    }

    // Compare hand of the same type. Returning true if this hand is weaker
    bool compareWith(const Hand& other) const {
        for (int i = 0; i < this->hand.size(); i++) {
            if (this->hand[i] == other.hand[i]) {
                continue;
            }
            int aIndex = cardPower(this->hand[i]);
            int bIndex = cardPower(other.hand[i]);
            return aIndex > bIndex;
        }
        // must be equal...
        return true;
    }
};

int main() {
    vector<Hand> hands;
    for (;;) {
        Hand hand;
        try {
            hand.read();
        }
        catch (std::length_error e) {
            break;
        }
        hands.push_back(hand);
    }

    // Sort hand by score ascendingly
    sort(hands.begin(), hands.end(), [](const Hand& a, const Hand& b) {
        int aScore = a.handType();
        int bScore = b.handType();
        if (aScore == bScore) {
            return a.compareWith(b);
        }
        return aScore < bScore;
    });

    int winning = 0;
    for (int i = 0; i < hands.size(); i++) {
        cout << "Hand " << i << " " << hands[i].hand << " type " << hands[i].handType() << " bid " << hands[i].bid <<
            endl;
        winning += hands[i].bid * (i + 1);
    }
    cout << winning << endl;
    // 248626506 too low part 2
    // 248314070 is wrong
    // 248302507 is wrong
    // 248255840 is wrong
}
