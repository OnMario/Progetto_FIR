#ifndef FIR_H
#define FIR_H

#define N_TAPS 11             // Numero di coefficienti (M per il prof)
#define BLOCK_SIZE 16         // Campioni in ingresso (N per il prof)
#define OUT_SIZE 26           // Uscite totali (BLOCK_SIZE + N_TAPS - 1)

void fir_engine(short *in_buffer, short *out_buffer);

#endif