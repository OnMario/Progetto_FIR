#include "fir.h"

void fir_engine(short *in_buffer, short *out_buffer) {
    #pragma HLS INTERFACE m_axi port=in_buffer bundle=gmem0 depth=16 offset=slave
    #pragma HLS INTERFACE m_axi port=out_buffer bundle=gmem0 depth=26 offset=slave
    #pragma HLS INTERFACE s_axilite port=in_buffer bundle=ctrl
    #pragma HLS INTERFACE s_axilite port=out_buffer bundle=ctrl
    #pragma HLS INTERFACE s_axilite port=return bundle=ctrl

    const short h[N_TAPS] = {0, -10, -9, 23, 56, 74, 56, 23, -9, -10, 0};
    

    short shift_reg[N_TAPS];
    #pragma HLS ARRAY_PARTITION variable=shift_reg complete dim=1
    
    // Inizializzazione manuale a zero
    for(int i = 0; i < N_TAPS; i++) {
        #pragma HLS UNROLL
        shift_reg[i] = 0;
    }

    short local_in[BLOCK_SIZE];
    short local_out[OUT_SIZE]; // Il buffer di uscita ora è da 26

    // FASE 1: Lettura dei 16 ingressi
    Read_Burst: for(int i = 0; i < BLOCK_SIZE; i++) {
        #pragma HLS PIPELINE II=1
        local_in[i] = in_buffer[i];
    }

    // FASE 2: Calcolo su 26 iterazioni
    Process_Loop: for (int b = 0; b < OUT_SIZE; b++) {
        #pragma HLS PIPELINE II=1
        
        // Superato il 16esimo campione, inseriamo ZERI finti
        short x = (b < BLOCK_SIZE) ? local_in[b] : (short)0;
        int acc = 0;
        
        Shift_Accum_Loop: for (int i = N_TAPS - 1; i > 0; i--) {
            shift_reg[i] = shift_reg[i - 1];
            acc += shift_reg[i] * h[i];
        }
        
        shift_reg[0] = x;
        acc += shift_reg[0] * h[0];
        
        local_out[b] = (short)acc;
    }

    // Scrittura dei risultati sul bus AXI
    Write_Burst: for(int i = 0; i < OUT_SIZE; i++) {
        #pragma HLS PIPELINE II=1
        out_buffer[i] = local_out[i];
    }
}