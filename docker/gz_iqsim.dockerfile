FROM ros:noetic-ros-base-focal

WORKDIR /home

SHELL ["/bin/bash", "-c"]

RUN apt-get update
ENV DEBIAN_FRONTEND=noninteractive

# install basic dependencies
RUN apt-get install -y curl git cmake tmux
RUN cd /usr/bin && ln -fs python3 python

# install ros pkgs
RUN apt-get install -y \
                        ros-noetic-gazebo-ros \ 
                        ros-noetic-mavros \
                        ros-noetic-gazebo-plugins \
                        ros-noetic-sensor-msgs \
                        ros-noetic-rviz \
                        ros-noetic-rqt-tf-tree \
                        ros-noetic-rqt-image-view
RUN git clone https://github.com/khancyr/ardupilot_gazebo && \
    cd ardupilot_gazebo && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install 

ADD src /home/src
ADD scripts /home/scripts

RUN cp -r /home/src/modules/aws-robomaker-small-house-world/models /home/models && \
    cp -r /home/src/modules/iq_sim/models/* /home/models

ENV GAZEBO_MODEL_PATH=/home/models
RUN source /opt/ros/noetic/setup.bash && catkin_make --only-pkg-with-deps iq_sim
RUN bash /home/scripts/install_geographiclib_datasets.sh

# RUN apt-get install -y x11-apps

# ENTRYPOINT source /home/devel/setup.bash && roslaunch iq_sim smallhouse.launch