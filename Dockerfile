FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

# Workaround: fuse-overlayfs corrupts GPG signatures during layer extraction
RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gnupg2 lsb-release software-properties-common \
    build-essential git cmake \
    python3-pip python3-dev \
    libeigen3-dev \
    libpcl-dev \
    nlohmann-json3-dev \
    tmux \
    wget \
    unzip \
    libusb-1.0-0-dev \
    libboost-all-dev \
    libopencv-dev \
    libtbb-dev \
    libceres-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros/ubuntu $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/ros1.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-desktop-full \
    python3-rosdep \
    python3-catkin-tools \
    ros-noetic-geometry-msgs \
    ros-noetic-sensor-msgs \
    ros-noetic-std-msgs \
    ros-noetic-nav-msgs \
    ros-noetic-message-generation \
    ros-noetic-message-runtime \
    ros-noetic-catkin \
    ros-noetic-tf \
    ros-noetic-pcl-ros \
    ros-noetic-cv-bridge \
    libopencv-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# GTSAM 4.0.3 (required by MM-LINS)
RUN wget -O /opt/gtsam.zip https://github.com/borglab/gtsam/archive/refs/tags/4.0.3.zip && \
    unzip gtsam.zip && \
    cd gtsam-4.0.3 && \
    mkdir build && cd build && \
    cmake .. -DGTSAM_BUILD_TESTS=OFF -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF -DGTSAM_USE_SYSTEM_EIGEN=ON && \
    make -j$(nproc) && make install && ldconfig && \
    cd / && rm -rf /opt/gtsam*

# Livox SDK
RUN git clone https://github.com/Livox-SDK/Livox-SDK.git && \
    cd Livox-SDK && \
    rm -rf build && mkdir build && cd build && \
    cmake .. && make -j$(nproc) && make install

WORKDIR /ros_ws

COPY ./src ./src

RUN sed -i 's|imu_topic:  "/imu_raw"|imu_topic:  "/imu/data"|' src/MM-LINS/FAST-LIO/config/velodyne.yaml

# Build workspace
RUN source /opt/ros/noetic/setup.bash && \
    catkin_make

ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID ros && \
    useradd -m -u $UID -g $GID -s /bin/bash ros

RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc && \
    echo "source /ros_ws/devel/setup.bash" >> ~/.bashrc

CMD ["bash"]
