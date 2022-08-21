# quickcluster

这是一个用于汽车智能座舱的仪表开发框架

## 特性:

- 基于共享内存的进程管理和守护机制
- 快速启动的解决方案
- 基于QtRemoteObjects的RPC通讯框架
- 仪表互联的解决方案
- 基于Shader的指针描画
- 非侵入式的工程设计

## 依赖：

- C++14

- CMake大于3.10

- Qt5.15或Qt6 (Core Gui Quick RemoteObjects)
- vsomeip (非必须)
- fdbus、protubuf(非必须)
- ros2 (非必须)

## 如何编译：

```cmake
cmake -B build
cmake --build build --target install
```

CMake可选配置:

- -DCLUSTER_HMI_PROJECT: 

  hmi式样 ，可选项有ejanus、coc，默认ejanus

- -DCLUSTER_SERVERS_PROJECT: 

  servers 框架，可选项只有common，默认common

- -DCLUSTER_USE_QT6: 

  是否使用Qt6，默认否
  
- -DCLUSTER_DLT_LOG:

  是否使用dlt-daemon，默认否
  
- -DCLUSTER_IMAGE_CACHE: 

  是否使用快速启动方案的图像缓存，默认是
  
- -DCLUSTER_QTAV_ANIMATION: 

  是否使用QtAV用以场景动画，默认否
  
- -DCLUSTER_QTAV_NAVI: 

  是否使用QtAV的RTSP用以导航投射，默认否

## 如何使用：

运行

```cmake
bootcli start
```

停止

```cmake
bootcli stop
```

Warning: hmi下的ejanus、coc切图不可商业盗用

## 版权所有:

Juntuan.Lu, 2020-2030, All rights reserved.
