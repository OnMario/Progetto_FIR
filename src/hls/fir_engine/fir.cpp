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
    
    // Manual initialization to zero
    for(int i = 0; i < N_TAPS; i++) {
        #pragma HLS UNROLL
        shift_reg[i] = 0;
    }

    short local_in[BLOCK_SIZE];
    short local_out[OUT_SIZE]; // Output buffer is now size 26

    // PHASE 1: Reading the 16 inputs
    Read_Burst: for(int i = 0; i < BLOCK_SIZE; i++) {
        #pragma HLS PIPELINE II=1
        local_in[i] = in_buffer[i];
    }

    // PHASE 2: Calculation over 26 iterations
    Process_Loop: for (int b = 0; b < OUT_SIZE; b++) {
        #pragma HLS PIPELINE II=1
        
        // Past the 16th sample, we feed dummy ZEROS
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

    // Writing the results to the AXI bus
    Write_Burst: for(int i = 0; i < OUT_SIZE; i++) {
        #pragma HLS PIPELINE II=1
        out_buffer[i] = local_out[i];
    }
}