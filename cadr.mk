# cadr.mk -- files that make up CADR

CADR_SRCS = $(CADR4_SRCS) $(OTHER_SRCS)

CADR4_SRCS	= \
	cadr.vh \
	$(addprefix CADR4/, $(addsuffix .v, $(CADR4_PARTS))) \
	$(addprefix CADR4/IRAML/, $(addsuffix .v, $(IRAML_PARTS))) \
	cadr.v

OTHER_SRCS	= \
	uhdl_common.v \
	cores/ic_74182.v \
	cores/ic_74181.v \
	cores/hz60.v \
	cores/us.v \
	cores/rom.v \
	cores/uart.v \
	spy_port.v \
	mouse.v \
	keyboard.v \
	scancode_rom.v \
	scancode_convert.v \
	cores/ps2_send.v \
	cores/ps2.v \
	ps2_support.v \
	vga_display.v \
	mmc.v \
	mmc_wrapper.v \
	block_dev_mmc.v \
	xbus_unibus.v \
	xbus_tv.v \
	xbus_spy.v \
	xbus_ram.v \
	xbus_io.v \
	xbus_disk.v \
	busint.v

CADR4_PARTS	= \
	ACTL \
	ALATCH \
	ALU \
	ALUC4 \
	AMEM \
	APAR \
	BCPINS \
	BCTERM \
	CAPS \
	CLOCKD \
	CONTRL \
	CPINS \
	DRAM \
	DSPCTL \
	FLAG \
	IOR \
	IPAR \
	IREG \
	IWR \
	L \
	LC \
	LCC \
	LPC \
	MCTL \
	MD \
	MDS \
	MF \
	MLATCH \
	MMEM \
	MO \
	MSKG4 \
	NPC \
	OPCD \
	PDL \
	PDLCTL \
	PDLPTR \
	PLATCH \
	Q \
	QCTL \
	SHIFT \
	SMCTL \
	SOURCE \
	SPC \
	SPCLCH \
	SPCPAR \
	SPCW \
	SPY124 \
	SPY1 \
	SPY2 \
	TRAP \
	VCTL1 \
	VCTL2 \
	VMA \
	VMAS \
	VMEM0 \
	VMEM1 \
	VMEMDR

IRAML_PARTS	= \
	CLOCK1 \
	CLOCK2 \
	DEBUG \
	ICAPS \
	ICTL \
	IWRPAR \
	MBCPIN \
	MCPINS \
	OLORD1 \
	OLORD2 \
	OPCS \
	PCTL \
	PROM \
	IRAM \
	SPY0 \
	SPY4 \
	STAT
