# [MM-LINS](https://github.com/lian-yue0515/MM-LINS) converter to [HDMapping](https://github.com/MapsHD/HDMapping)

## Intended use

This small toolset allows to integrate the SLAM solution provided by [MM-LINS](https://github.com/lian-yue0515/MM-LINS) with [HDMapping](https://github.com/MapsHD/HDMapping).
This repository contains a ROS 1 workspace that:
  - submodule to tested revision of MM-LINS (FAST-LIO based)
  - a converter that listens to topics advertised from the odometry node and saves data in a format compatible with HDMapping.

## Example datasets

- [Bunker DVI Dataset](https://charleshamesse.github.io/bunker-dvi-dataset/) — `reg-1.bag` (Livox MID-360). See branch `Bunker-DVI-Dataset-reg-1`.
- [KITTI raw/odometry](https://www.cvlibs.net/datasets/kitti/). See branch `kitti`.

## Published topics (from MM-LINS)

- `/cloud_registered`      — `sensor_msgs/PointCloud2`, per-scan registered cloud in world frame
- `/Odometry`              — `nav_msgs/Odometry`
- `/path`                  — `nav_msgs/Path`

The converter only consumes `/cloud_registered` and `/Odometry`.

## Dependencies

```shell
sudo apt install -y nlohmann-json3-dev
```

## Building

```shell
mkdir -p /test_ws/src
cd /test_ws/src
git clone https://github.com/MapsHD/benchmark-MM-LINS-to-HDMapping.git --recursive
cd ..
catkin_make
```

## Usage — conversion:

```shell
rosrun mm-lins-to-hdmapping listener <recorded.bag> <output_dir>
```

For a one-shot Docker-based pipeline, switch to branch `Bunker-DVI-Dataset-reg-1` or `kitti`.
