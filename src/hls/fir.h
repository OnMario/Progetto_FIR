#ifndef FIR_H
#define FIR_H

#define N_TAPS 11             // Number of coefficients (M for the professor)
#define BLOCK_SIZE 16         // Input samples (N for the professor)
#define OUT_SIZE 26           // Total outputs (BLOCK_SIZE + N_TAPS - 1)

void fir_engine(short *in_buffer, short *out_buffer);

#endif