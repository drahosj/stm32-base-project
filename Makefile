# Global project variables
# MCU Define
export MCU_MODEL=STM32F411xE

# Toolchain
export CC=arm-none-eabi-gcc
export AS=arm-none-eabi-as
export OBJDUMP=arg-none-eabi-objdump
export LD=arm-none-eabi-ld

# Project root
export PROJECT_ROOT=.

# Drivers path
export DRIVERS=$(PROJECT_ROOT)/vendor/Drivers

# Include Paths
#export IFLAGS=-I$(DRIVERS)/BSP/STM32F4xx-Nucleo/
export IFLAGS+= -I$(DRIVERS)/CMSIS/Include/
export IFLAGS+= -I$(DRIVERS)/CMSIS/Device/ST/STM32F4xx/Include
export IFLAGS+= -I$(DRIVERS)/STM32F4xx_HAL_Driver/Inc
export IFLAGS+= -I$(PROJECT_ROOT)/Inc/

export CPPFLAGS= $(IFLAGS)

# Set flags
export CFLAGS= --specs=nosys.specs -mthumb -mcpu=cortex-m4 -mfloat-abi=hard
export CFLAGS+= -mfpu=fpv4-sp-d16 -g -D$(MCU_MODEL)

# Bitchy nag-nag mode settings
export CFLAGS+= -Wall -Wextra -Wpedantic -Werror -Wno-unused-parameter -Wno-unused-variable -Wno-unused-but-set-variable -std=gnu11

###### CONFIGURATION #######
#Source file definitions
# Files is Src
export APPLICATION_FILES=main.c stm32f4xx_hal_msp.c
export APPLICATION_FILES+=stm32f4xx_it.c system_stm32f4xx.c

# Files in Src/drivers
export DRIVER_FILES=

# HAL Requirements
export HAL_MODULES=gpio uart rcc dma cortex

# Startup
export STARTUP=startup_stm32f411xe.s

#Linker Script
export LINKER_SCRIPT=STM32F411RETx_FLASH.ld

#Library flags
export LFLAGS=
export LIBS=

###### END CONFIGURATION ######
# Startup
export STARTUP_FILE=Src/$(STARTUP)

# All ojbects (TODO: FIX USING FOREACH)
export ALL_OBJECTS=objects/*.o objects/hal/*.o #objects/drivers/*.o

export STARTUP_OBJECT=objects/$(subst .s,.o,$(STARTUP))

export HAL_FILES=stm32f4xx_hal.c $(foreach module,$(HAL_MODULES),stm32f4xx_hal_$(module).c)

export APPLICATION_OBJECTS=$(subst .c,.o,$(APPLICATION_FILES))
export DRIVER_OBJECTS=$(subst .c,.o,$(DRIVER_FILES))
export HAL_OBJECTS=$(subst .c,.o,$(HAL_FILES))

export APPLICATION_OBJECTS_EXPANDED= $(foreach object,$(APPLICATION_OBJECTS),objects/$(object))
export DRIVER_OBJECTS_EXPANDED= $(foreach object,$(DRIVER_OBJECTS),objects/drivers/$(object))
export HAL_OBJECTS_EXPANDED= $(foreach object,$(HAL_OBJECTS),objects/hal/$(object))

export LDFLAGS= $(LFLAGS) $(LIBS)

all: image.bin

image.elf: hal applications drivers startup
	$(CC) $(CFLAGS) $(LFLAGS) -T $(LINKER_SCRIPT) -o image.elf $(ALL_OBJECTS) $(LIBS)

image.bin: image.elf
	arm-none-eabi-objcopy -O binary image.elf image.bin

hal: $(HAL_OBJECTS_EXPANDED)

applications: $(APPLICATION_OBJECTS_EXPANDED)

drivers: $(DRIVER_OBJECTS_EXPANDED)

startup: $(STARTUP_OBJECT)

objects/%.o: Src/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

objects/drivers/%.o: Src/drivers/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

objects/hal/%.o: $(DRIVERS)/STM32F4xx_HAL_Driver/Src/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(STARTUP_OBJECT): $(STARTUP_FILE)
	$(CC) $(CFLAGS) $(IFLAGS) -c $(STARTUP_FILE) -o $(STARTUP_OBJECT)

clean:
	rm -f image.elf $(ALL_OBJECTS) image.bin
