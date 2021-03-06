FROM twobombs/docker-arm-deploy

# clone repos
RUN git clone --recursive https://github.com/vm6502q/qrack.git
RUN git clone --recursive https://github.com/SoftwareQuTech/SimulaQron.git
RUN git clone --recursive https://github.com/vm6502q/ProjectQ.git
RUN git clone --recursive https://github.com/XanaduAI/pennylane-pq.git

# install features
RUN apt-get update && apt-get -y install build-essential cmake wget vim-common opencl-headers curl doxygen libfreetype6-dev python-numpy python-scipy libblas-dev liblapack-dev libatlas-base-dev gfortran nginx && apt-get clean all
RUN python3 -m pip install --upgrade pip && apt-get -y install python3-numpy python3-scipy && apt-get clean all

# Qrack install & dependancies 
RUN cd /qrack/include && mkdir CL
ADD https://www.khronos.org/registry/OpenCL/api/2.1/cl.hpp /qrack/include/CL/cl.hpp
RUN cd /qrack && mkdir _build && cd _build && cmake -DENABLE_RDRAND=OFF -DENABLE_PURE32=ON .. && make all && make install && cd .. && doxygen doxygen.config && mv /var/www/html /var/www/old_html && ln -s /qrack/doc/html /var/www/html

# install python3
RUN apt-get install -y python3 python3-pip python3-tk
# Set a UTF-8 locale - this is needed for some python packages to play nice
RUN apt-get -y install language-pack-en
ENV LANG="en_US.UTF-8"

# ProjectQ install
# pybind11 workaround
RUN pip3 install pybind11
RUN pip3 install sphinx sphinx_rtd_theme
# rebuild workaround
RUN cd /ProjectQ && pip3 install --user .
RUN cd /ProjectQ && pip3 install --user  --global-option="--with-qracksimulator" .
# RUN cd /ProjectQ/docs && make html clean

# Install SimulaQron
# workaround because of missing dependancy
RUN pip3 install cairocffi
RUN pip3 install simulaqron

# Install pennylane
RUN pip3 install pennylane_pq
RUN cd /pennylane-pq && make test

# Install jupyter
RUN pip3 install jupyter

# node run script
COPY run-node /root/

EXPOSE 80 8801-8811 8888
