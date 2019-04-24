FROM twobombs/cudacluster

# clone repos
RUN git clone --recursive https://github.com/twobombs/qrack.git
RUN git clone --recursive https://github.com/SoftwareQuTech/SimulaQron.git
RUN git clone --recursive https://github.com/vm6502q/ProjectQ.git

# install features
RUN apt-get update && apt-get -y install build-essential cmake wget vim-common opencl-headers curl doxygen nginx && apt-get clean all

# Qrack install & dependancies 
RUN cd /qrack/include && mkdir CL
RUN cd /qrack && mkdir _build && cd _build && cmake .. && make all && make install && cd .. && doxygen doxygen.config && mv /var/www/html /var/www/old_html && ln -s /qrack/doc/html /var/www/html

# install python3
RUN apt-get install -y python3 python3-pip python3-tk
# Set a UTF-8 locale - this is needed for some python packages to play nice
RUN apt-get -y install language-pack-en
ENV LANG="en_US.UTF-8"

# ProjectQ install
# pybind11 workaround
RUN pip3 install pybind11
# rebuild workaround
RUN cd /ProjectQ && pip3 install --user .
RUN cd /ProjectQ && pip3 install --user  --global-option="--with-qracksimulator" .

# Install SimulaQron 
RUN pip3 install simulaqron

# Install jupyter
RUN pip3 install jupyter

# node run script
COPY run-node /root/

EXPOSE 80 8801-8811 8888
