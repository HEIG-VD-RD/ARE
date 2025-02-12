################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := clean

# All of the sources participating in the build are defined here
-include sources.mk
-include src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 

# All Target
all: hps_aquis_string.axf

# Tool invocations
hps_aquis_string.axf: $(OBJS) /opt/intelFPGA/18.1/University_Program/Monitor_Program/arm_tools/baremetal/arm-altera-eabi/lib/cycloneV-dk-ram-hosted.ld $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C Linker 6.2.0 [arm-altera-eabi]'
	arm-altera-eabi-gcc -T "/opt/intelFPGA/18.1/University_Program/Monitor_Program/arm_tools/baremetal/arm-altera-eabi/lib/cycloneV-dk-ram-hosted.ld" -o "hps_aquis_string.axf" $(OBJS) $(LIBS) $(USER_OBJS)
	@echo 'Finished building target: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(EXECUTABLES) $(OBJS) $(C_DEPS) hps_aquis_string.axf 
	-@echo ' '

.PHONY: all clean dependents

-include ../makefile.targets
