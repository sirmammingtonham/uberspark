/*
    minimal coss example application that multiplies two unsigned 32-bit integers 
    specified via integer parameters and returns the result

    author: amit vasudevan <amitvasudevan@acm.org>
*/

uint32_t main (uint32_t multiplicand, uint32_t multiplier){
    uint32_t result;

    result = multiplicand * multiplier;

    return result;
}