################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/home/reds/Desktop/ARE/ARE-Labo5/hps_acquis_string/soft/src/avalon_function.c \
/home/reds/Desktop/ARE/ARE-Labo5/hps_acquis_string/soft/src/hps_application.c 

OBJS += \
./src/avalon_function.o \
./src/hps_application.o 

C_DEPS += \
./src/avalon_function.d \
./src/hps_application.d 


# Each subdirectory must supply rules for building sources it contributes
src/avalon_function.o: /home/reds/Desktop/ARE/ARE-Labo5/hps_acquis_string/soft/src/avalon_function.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler 6.2.0 [arm-altera-eabi]'
	arm-altera-eabi-gcc -O0 -g -Wall -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/hps_application.o: /home/reds/Desktop/ARE/ARE-Labo5/hps_acquis_string/soft/src/hps_application.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler 6.2.0 [arm-altera-eabi]'
	arm-altera-eabi-gcc -O0 -g -Wall -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


