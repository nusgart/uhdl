// top_sim.cpp --- ---!!!

#include <iostream>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vtop.h"

#define BOOT		top->top__DOT__boot
#define CLK		top->top__DOT__clk
#define CPU_CLK		top->top__DOT__cpu_clk
#define CLK50		top->top__DOT__clk50
#define CYCLES		top->top__DOT__cycles
#define IR		top->top__DOT__lm3__DOT__cpu__DOT__ir
#define LC		top->top__DOT__lm3__DOT__cpu__DOT__lc
#define M		top->top__DOT__lm3__DOT__cpu__DOT__m
#define N		top->top__DOT__lm3__DOT__cpu__DOT__n
#define VGA_CLK		top->top__DOT__vga_clk
#define PROMDISABLE	top->top__DOT__lm3__DOT__cpu__DOT__promdisable
#define R		top->top__DOT__lm3__DOT__cpu__DOT__r
#define RESET		top->top__DOT__reset
#define SET_PROMDISABLE	top->top__DOT__lm3__DOT__set_promdisable
#define STATE		top->top__DOT__lm3__DOT__cpu__DOT__state
#define SYSCLK		top->top__DOT__sysclk
#define AMEM		top->top__DOT__lm3__DOT__cpu__DOT__cadr_amem__DOT__ram
#define AMEM_OUT_A	top->top__DOT__lm3__DOT__cpu__DOT__cadr_amem__DOT__out_a
#define DRAM		top->top__DOT__lm3__DOT__cpu__DOT__cadr_dram__DOT__ram
#define IRAM		top->top__DOT__lm3__DOT__cpu__DOT__cadr_IRAM__DOT__ram
#define LPC		top->top__DOT__lm3__DOT__cpu__DOT__cadr_lpc__DOT__lpc
#define MMEM		top->top__DOT__lm3__DOT__cpu__DOT__cadr_mmem__DOT__ram
#define RAM1_H		top->top__DOT__ram__DOT__ram1__DOT__ram_h
#define RAM1_L		top->top__DOT__ram__DOT__ram1__DOT__ram_l
#define RAM2_H		top->top__DOT__ram__DOT__ram2__DOT__ram_h
#define RAM2_L		top->top__DOT__ram__DOT__ram2__DOT__ram_l
#define RC_STATE	top->top__DOT__rc__DOT__state
#define VMEM0		top->top__DOT__lm3__DOT__cpu__DOT__cadr_vmem0__DOT__ram
#define VMEM1		top->top__DOT__lm3__DOT__cpu__DOT__cadr_vmem1__DOT__ram

#define LOAD_MEMORIES

Vtop *top;

static vluint64_t main_time = 0;

double sc_time_stamp (void)
{
	return main_time;
}

int init_memories(const char *filename, int show)
{
#ifdef LOAD_MEMORIES
	FILE *in;
	in = fopen(filename, "r");
	if (in == NULL)
		return -1;
	if (in) {
		char ch;
		int a;
		unsigned long long vl;
		unsigned int v, h, l;
		while (fscanf(in, "%c %o %llo\n", &ch, &a, &vl) == 3) {
			if (show) VL_PRINTF("%c %o %llo\n", ch, a, vl);
			v = vl;
			switch (ch) {
			case 'A':
				AMEM[a] = v;
				break;
			case 'M':
				MMEM[a] = v;
				break;
			case 'D':
				DRAM[a] = v;
				break;
			case 'I':
				int a1h, a1l, a2h, a2l;
				unsigned char v1h, v1l, v2h, v2l;

#ifdef RC_MEM
				h = vl >> 32;
				l = vl & 0xffffffff;

				a1h = 0x20000 | (a << 1);
				a1l = a2h = a2l = a1h;

				v1h = h >> 24;
				v1l = h >> 16;
				v2h = h >> 8;
				v2l = h >> 0;

				RAM1_H[a1h] = v1h;
				RAM1_L[a1l] = v1l;
				RAM2_H[a2h] = v2h;
				RAM2_L[a2l] = v2l;

				a1h++; a1l++; a2h++; a2l++;

				v1h = l >> 24;
				v1l = l >> 16;
				v2h = l >> 8;
				v2l = l >> 0;

				RAM1_H[a1h] = v1h;
				RAM1_L[a1l] = v1l;
				RAM2_H[a2h] = v2h;
				RAM2_L[a2l] = v2l;
#endif
#ifdef MODEL_MEM
				IRAM[a] = vl;
#endif
				break;
			case '0':
				VMEM0[a] = v;
				break;
			case '1':
				VMEM1[a] = v;
				break;
			}
		}
		fclose(in);
	}
#endif

	return 0;
}

#ifdef RC_SYNC_CHECK
int rc_sync_check(void)
{
	if (SYSCLK && RC_STATE != 2) {
		if (STATE == 8 && RC_STATE != 1) {
			VL_PRINTF("out of sync: cpu %d rc %d; %lld\n", 
				  STATE, 
				  RC_STATE, 
				  main_time);
			vl_finish("top.cpp", __LINE__, "");
		}
	}
}
#endif

int main(int argc, char** argv)
{
	VerilatedVcdC* tfp = NULL;
	Verilated::commandArgs(argc, argv);

	int load_memories = 0;
	int show_waves = 0;
	int show_pc = 0;
	int show_min_time = 0;
	int show_max_time = 0;
	int show_memories = 0;
	int force_mcram = 0;
	int force_debug = 0;
	int force_debug_ram = 0;
	int clocks_100 = 0;
	int clocks_25 = 0;
	int clocks_12 = 0;
	int clocks_6 = 0;
	int clocks_1x = 0;
	int clocks_all = 0;

	int reset_mult = 1;
	int loop_count = 0;
	int wait_count = 0;
	int max_loop = 20;
	char *mem_filename;
	int result = 0;

	top = new Vtop;

	printf("built on: %s %s\n", __DATE__, __TIME__);

	mem_filename = (char *)"output";

	for (int i = 0; i < argc; i++) {
		if (argv[i][0] == '+') {
			switch (argv[i][1]) {
			case 'l':
				load_memories++;
				mem_filename = strdup(argv[++i]);
				break;
			case 'm': show_memories++; break;
			case 'w': show_waves++; break;
			case 'p': show_pc++; break;
			case 'f': force_mcram++; break;
			case 'd': force_debug++; break;
			case 'r': force_debug_ram++; break;
			case 'c':
				switch (argv[i][2]) {
				case '0': clocks_1x++; break;
				case '1': clocks_100++; break;
				case '3': clocks_25++; break;
				case '4': clocks_12++; break;
				case '5': clocks_6++; break;
				case 'a': clocks_all++; break;
				}
				break;
			case 'b': show_min_time = atoi(argv[i]+2); break;
			case 'e': show_max_time = atoi(argv[i]+2); break;
			default:
				fprintf(stderr, "bad arg? %s\n", argv[i]);
				exit(1);
			}
		}
	}

#ifdef VM_TRACE
	if (show_waves) {
		Verilated::traceEverOn(true);
		VL_PRINTF("Enabling waves...\n");
		tfp = new VerilatedVcdC;
		top->trace(tfp, 99);
		tfp->open("top.vcd");

		if (show_min_time)
			printf("show_min_time=%d\n", (int)show_min_time);
		if (show_max_time)
			printf("show_max_time=%d\n", (int)show_max_time);
	}
#endif

	float hp50, hp100, hp108;
	float t50, t100, t108;
	hp50 =  ((1.0 / 50000000.0)  * 1000000000.0) / 2.0;
	hp100 = ((1.0 / 100000000.0) * 1000000000.0) / 2.0;
	hp108 = ((1.0 / 108000000.0) * 1000000000.0) / 2.0;

	if (force_debug) {
		printf("force debug\n");
	}

	int clk25, clk12, clk6;

	if (clocks_100 || clocks_25 || clocks_12)
		max_loop = 200;
	if (clocks_6)
		max_loop = 500;
	if (clocks_all)
		max_loop = 5000;

	while (!Verilated::gotFinish()) {
		if (load_memories && main_time == 1) {
			if (init_memories(mem_filename, show_memories)) {
				perror(mem_filename);
				fprintf(stderr, "memory initialization failed\n");
				exit(1);
			}
		}

		if (clocks_1x) {
			reset_mult = 1;
			CPU_CLK = CPU_CLK ? 0 : 1;
			CLK50 = CPU_CLK;
			CLK = CPU_CLK;
		}

		if (clocks_100) {
			reset_mult = 10;

			CLK = CLK ? 0 : 1;
			if (CLK) {
				CLK50 = CLK50 ? 0 : 1;
				if (CLK50)
					CPU_CLK = CPU_CLK ? 0 : 1;
			}
		}

		if (clocks_25) {
			reset_mult = 10;

			CLK = CLK ? 0 : 1;
			if (CLK) {
				CLK50 = CLK50 ? 0 : 1;
				if (CLK50) {
					clk25 = clk25 ? 0 : 1;
					if (clk25)
						CPU_CLK = CPU_CLK ? 0 : 1;
				}
			}
		}

		if (clocks_12) {
			reset_mult = 10;

			CLK = CLK ? 0 : 1;
			VGA_CLK = CLK;
			if (CLK) {
				CLK50 = CLK50 ? 0 : 1;
				if (CLK50) {
					clk25 = clk25 ? 0 : 1;
					if (clk25) {
						clk12 = clk12 ? 0 : 1;
						if (clk12)
							CPU_CLK =
								CPU_CLK ? 0 : 1;
					}
				}
			}
		}

		if (clocks_6) {
			reset_mult = 10;

			CLK = CLK ? 0 : 1;
			VGA_CLK = CLK;
			if (CLK) {
				CLK50 = CLK50 ? 0 : 1;
				if (CLK50) {
					clk25 = clk25 ? 0 : 1;
					if (clk25) {
						clk12 = clk12 ? 0 : 1;
						if (clk12) {
							clk6 = clk6 ? 0 : 1;
							if (clk6) {
								CPU_CLK =
									CPU_CLK ?
									0 : 1;
							}
						}
					}
				}
			}
		}

		if (clocks_all) {
			reset_mult = 40;
			if (t50 >= hp50) {
				t50 = 0.0;
				CLK50 = CLK50 ? 0 : 1;
				if (CLK50)
					CPU_CLK = CPU_CLK ? 0 : 1;
			}

			if (t100 >= hp100) {
				t100 = 0.0;
				CLK = CLK ? 0 : 1;
			}

			if (t108 >= hp108) {
				t108 = 0.0;
				VGA_CLK = VGA_CLK ? 0 : 1;
			}

			t50 += 0.25;
			t100 += 0.25;
			t108 += 0.25;
		}

		if (main_time < 500*reset_mult) {
			if (main_time == 10*reset_mult) {
				VL_PRINTF("reset on\n");
				RESET = 1;
			}
			if (main_time == 240*reset_mult) {
				VL_PRINTF("boot on\n");
				BOOT = 1;
			}
			if (main_time == 250*reset_mult) {
				VL_PRINTF("reset off\n");
				RESET = 0;
			}
			if (main_time == 260*reset_mult) {
				VL_PRINTF("boot off\n");
				BOOT = 0;
				CYCLES = 0;
			}
		}

		top->eval();

		if (force_mcram) {
			SET_PROMDISABLE = 1;
			PROMDISABLE = 1;
		}

		int old_cpu_clk;

		if (RESET)
			int old_cpu_clk = 1;

		if (force_debug && 0) {
			printf("clk %d %d state %d\n", 
			       CPU_CLK, old_cpu_clk, 
			       STATE);
		}

		if (CPU_CLK && old_cpu_clk == 0 &&
		    STATE == 4)
		{
			if (show_pc)
				VL_PRINTF("%lu; %o %017lo A=%011o M=%011o N%d R=%011o LC=%011o\n", 
					  main_time, 
					  LPC, 
					  (QData)IR, 
					  AMEM_OUT_A, 
					  M, 
					  N, 
					  R, 
					  LC);

			if ((QData)IR & 010000000000000000LL) {
				if ((QData)IR & 0xffLL) {
					VL_PRINTF("MC STOP ERROR ");
					result = 1;
				} else
					VL_PRINTF("MC STOP OK ");
				vl_finish("top.cpp", __LINE__, "");
			}

		}

		old_cpu_clk = CPU_CLK;

		if (STATE == 32) {
			if (RESET == 0 &&
			    PROMDISABLE == 0 &&
			    LPC < 0100 &&
			    main_time > 10000) {
				loop_count++;
			} else
				loop_count = 0;
		}

		if (loop_count > max_loop) {
			VL_PRINTF("MC STOP ERROR PROM; lpc %o, main_time %ld\n", 
				  LPC, main_time);
			vl_finish("top.cpp", __LINE__, "");
			result = 2;
		}

		if (STATE == 32) {
			if (LPC == 0610)
				wait_count = 0;
			if (LPC == 0614)
				wait_count++;
		}

		if (wait_count > 10000) {
			VL_PRINTF("MC WAIT DISK; lpc %o, main_time %ld\n", 
				  LPC, main_time);
			vl_finish("top.cpp", __LINE__, "");
			result = 2;
		}

#ifdef RC_SYNC_CHECK
		rc_sync_check();
#endif

#ifdef VM_TRACE
	if (tfp) {
		if (show_min_time == 0 && show_max_time == 0)
			tfp->dump(main_time);
		else
			if (show_min_time && main_time > show_min_time)
				tfp->dump(main_time);

		if (show_max_time && main_time > show_max_time)
			vl_finish("top.cpp", __LINE__, "");
	}
#endif

		main_time++;
	}

	top->final();

	if (tfp)
		tfp->close();

	if (result)
		exit(result);

	exit(0);
}
