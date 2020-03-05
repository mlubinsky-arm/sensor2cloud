FROM mbedos/mbed-os-env
# Install Dependency
RUN mbed import https://github.com/mlubinsky-arm/sensor2cloud \
    && cd sensor2cloud \
    && mbed deploy \
    && mbed config -G CLOUD_SDK_API_KEY ak_1MDE3MDNhZDMwZDJkOGFlZGE2MWYxMzRjMDAwMDAwMDA017040793c538aeda61f134c00000000IQBgqsHL7r63RXOEXAEiz2YxB5kIgujJ  \
    && mbed dm init -d "arm.com" --model-name "mbed" -q --force
RUN cd sensor2cloud && mbed compile -m NUCLEO_H743ZI2 -t GCC_ARM
RUN cd sensor2cloud && mbed dm update device -D 0170a6e08345000000000001001a30be -m NUCLEO_H743ZI2 --no-cleanup
#ENTRYPOINT ["python", "-V"]
ENTRYPOINT ["which", "python"]


