#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

enum {
    UTF_MAX   = 6u,       /* maximum number of bytes that make up a rune */
    RUNE_SELF = 0x80,     /* byte values larger than this are *not* ascii */
    RUNE_ERR  = 0xFFFD,   /* rune value representing an error */
    RUNE_MAX  = 0x10FFFF, /* Maximum decodable rune value */
    RUNE_EOF  = -1,       /* rune value representing end of file */
    RUNE_CRLF = -2,       /* rune value representing a \r\n sequence */
};

const uint8_t UTF8_SeqBits[] = { 0x00, 0x80, 0xC0, 0xE0, 0xF0, 0xF8, 0xFC, 0xFE };
const uint8_t UTF8_SeqMask[] = { 0x00, 0xFF, 0x1F, 0x0F, 0x07, 0x03, 0x01, 0x00 };
const uint8_t UTF8_SeqLens[] = { 0x01, 0x00, 0x02, 0x03, 0x04, 0x05, 0x06, 0x00 };

static bool runevalid(int32_t val) {
    return (val <= RUNE_MAX)
        && ((val & 0xFFFE) != 0xFFFE)
        && ((val < 0xD800) || (val > 0xDFFF))
        && ((val < 0xFDD0) || (val > 0xFDEF));
}

static size_t runelen(int32_t rune) {
    if(!runevalid(rune))
        return 0;
    else if(rune <= 0x7F)
        return 1;
    else if(rune <= 0x07FF)
        return 2;
    else if(rune <= 0xFFFF)
        return 3;
    else
        return 4;
}

static uint8_t utfseq(uint8_t byte) {
    for (int i = 1; i < 8; i++)
        if ((byte & UTF8_SeqBits[i]) == UTF8_SeqBits[i-1])
            return UTF8_SeqLens[i-1];
    return 0;
}

size_t utf8encode(char str[UTF_MAX], int32_t rune) {
    size_t len = runelen(rune);
    str[0] = (len == 1 ? 0x00 : UTF8_SeqBits[len])
           | (UTF8_SeqMask[len] & (rune >> (6 * (len-1))));
    for (size_t i = 1; i < len; i++)
        str[i] = 0x80u | (0x3Fu & (rune >> (6 * (len-i-1))));
    return len;
}

bool utf8decode(int32_t* rune, size_t* length, int byte) {
    /* Handle the start of a new rune */
    if (*length == 0) {
        /* If we were fed in an EOF as a start byte, handle it here */
        if (byte == RUNE_EOF) {
            *rune = RUNE_EOF;
        } else {
            /* Otherwise, decode the first byte of the rune */
            *length = utfseq(byte);
            *rune   = (*length == 0) ? RUNE_ERR : (byte & UTF8_SeqMask[*length]);
            (*length)--;
        }
    /* Handle continuation bytes */
    } else if ((byte & 0xC0) == 0x80) {
        /* add bits from continuation byte to rune value
         * cannot overflow: 6 byte sequences contain 31 bits */
        *rune = (*rune << 6) | (byte & 0x3F); /* 10xxxxxx */
        (*length)--;
        /* Sanity check the final rune value before finishing */
        if ((*length == 0) && !runevalid(*rune))
            *rune = RUNE_ERR;
    /* Didn't get the continuation byte we expected */
    } else {
        *rune = RUNE_ERR;
    }
    /* Tell the caller whether we finished or not */
    return ((*length == 0) || (*rune == RUNE_ERR));
}
