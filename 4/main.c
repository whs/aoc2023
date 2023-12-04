#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct {
    uint8_t no;
    // the list is zero terminated, this assume input has no zero
    uint8_t winning[10];
    uint8_t have[25];
} card_t;

// Read a card_t. The caller is responsible for freeing card_t
// May return NULL if read fail
card_t* read_card() {
    int err;
    // calloc zero fill the output
    card_t* out = calloc(sizeof(card_t), 1);
    err = scanf("Card %u: ", &out->no);
    if (err != 1) {
        return NULL;
    }
    for (int i = 0; i < sizeof(out->winning); i++) {
        err = scanf("%d ", &out->winning[i]);
        if (err != 1) {
            break;
        }
    }
    scanf(" | ");
    for (int i = 0; i < sizeof(out->have); i++) {
        err = scanf("%d ", &out->have[i]);
        if (err != 1) {
            break;
        }
    }

    return out;
}

// Return number of winnings
int winnings(card_t* card) {
    int combo = 0;
    for (int i = 0; i < sizeof(card->have); i++) {
        int have = card->have[i];
        if (have == 0) {
            break;
        }
        for (int j = 0; j < sizeof(card->winning); j++) {
            int winning = card->winning[j];
            if (winning == 0) {
                break;
            }
            if (have == card->winning[j]) {
                combo++;
                break;
            }
        }
    }
    return combo;
}

int solve(card_t* card) {
    int out = winnings(card);
    if (out == 0) {
        return 0;
    }
    // 2^(n-1)
    return 1 << (out - 1);
}

int main() {
    /*/
    // Part 1
    int worth_sum = 0;
    for (;;) {
        card_t* card = read_card();
        if (card == NULL) {
            break;
        }
        int worth = solve(card);
        worth_sum += worth;
        free(card);
    }
    printf("%d", worth_sum);
    /**/

    /**/
    // Part 2
#define MAX_GAMES 193
    card_t* games[MAX_GAMES] = {NULL};
    int cardCopies[MAX_GAMES] = {0};
    for (int i = 0; i < MAX_GAMES; i++) {
        games[i] = read_card();
        if (games[i] == NULL) {
            break;
        }
        cardCopies[i] = 1;
    }
    for (int i = 0; i < MAX_GAMES; i++) {
        if (games[i] == NULL) {
            break;
        }
        int winning = winnings(games[i]);
        while (winning > 0) {
            cardCopies[i + winning] += cardCopies[i];
            winning--;
        }
    }
    int totalCard = 0;
    for (int i = 0; i < MAX_GAMES; i++) {
        totalCard += cardCopies[i];
    }
    printf("%d\n", totalCard);
    /**/

    return 0;
}
