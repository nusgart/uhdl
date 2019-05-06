#define CHAOS_CSR_TIMER_INTERRUPT_ENABLE (1 << 0)
#define CHAOS_CSR_LOOP_BACK (1 << 1)
#define CHAOS_CSR_RECEIVE_ALL (1 << 2)
#define CHAOS_CSR_RECEIVER_CLEAR (1 << 3)
#define CHAOS_CSR_RECEIVE_ENABLE (1 << 4)
#define CHAOS_CSR_TRANSMIT_ENABLE (1 << 5)
#define CHAOS_CSR_INTERRUPT_ENABLES (3 << 4)
#define CHAOS_CSR_TRANSMIT_ABORT (1 << 6)
#define CHAOS_CSR_TRANSMIT_DONE (1 << 7)
#define CHAOS_CSR_TRANSMITTER_CLEAR (1 << 8)
#define CHAOS_CSR_LOST_COUNT (017 << 9)
#define CHAOS_CSR_RESET (1 << 13)
#define CHAOS_CSR_CRC_ERROR (1 << 14)
#define CHAOS_CSR_RECEIVE_DONE (1 << 15)

void
print_csr_bits(int csr)
{    printf("csr (%o): ", csr);
	if (csr & CHAOS_CSR_LOOP_BACK)
		printf(" CHAOS_CSR_LOOP_BACK");
	if (csr & CHAOS_CSR_RECEIVE_ALL)
		printf(" CHAOS_CSR_RECEIVE_ALL");
	if (csr & CHAOS_CSR_RECEIVER_CLEAR)
		printf(" CHAOS_CSR_RECEIVER_CLEAR");
	if (csr & CHAOS_CSR_RECEIVE_ENABLE)
		printf(" CHAOS_CSR_RECEIVE_ENABLE");
	if (csr & CHAOS_CSR_TRANSMIT_ENABLE)
		printf(" CHAOS_CSR_TRANSMIT_ENABLE");
	if (csr & CHAOS_CSR_TRANSMIT_ABORT)
		printf(" CHAOS_CSR_TRANSMIT_ABORT");
	if (csr & CHAOS_CSR_TRANSMIT_DONE)
		printf(" CHAOS_CSR_TRANSMIT_DONE");
	if (csr & CHAOS_CSR_TRANSMITTER_CLEAR)
		printf(" CHAOS_CSR_TRANSMITTER_CLEAR");
	if (csr & CHAOS_CSR_RESET)
		printf(" CHAOS_CSR_RESET");
	if (csr & CHAOS_CSR_RECEIVE_DONE)
		printf(" CHAOS_CSR_RECEIVE_DONE");
	if (csr & CHAOS_CSR_CRC_ERROR)
		printf(" CHAOS_CSR_CRC_ERROR");
	if (csr & CHAOS_CSR_LOST_COUNT)
		printf(" CHAOS_CSR_LOST_COUNT(%d.)", (csr & CHAOS_CSR_LOST_COUNT) >> 9);
	csr &= ~(CHAOS_CSR_LOST_COUNT |
		 CHAOS_CSR_RESET |
		 CHAOS_CSR_TRANSMITTER_CLEAR | CHAOS_CSR_TRANSMIT_ABORT |
		 CHAOS_CSR_RECEIVE_DONE | CHAOS_CSR_RECEIVE_ENABLE |
		 CHAOS_CSR_TRANSMIT_DONE | CHAOS_CSR_TRANSMIT_ENABLE |
		 CHAOS_CSR_CRC_ERROR |
		 CHAOS_CSR_LOOP_BACK |
		 CHAOS_CSR_RECEIVE_ALL | CHAOS_CSR_RECEIVER_CLEAR);
	if (csr)
		printf(" unk bits 0%o", csr);
                printf("\n");
}


int main()
{

    print_csr_bits(00000020000);
    print_csr_bits(000220);
    print_csr_bits(00000000060);


    print_csr_bits(00000000260);
    print_csr_bits(00000013000);

    print_csr_bits(00000100220);
}
