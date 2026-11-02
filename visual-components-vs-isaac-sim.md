# Visual Components vs NVIDIA Isaac Sim

*Last updated: November 2026. Check vendor sites for current versions, licensing and pricing.*

## Summary

The two tools solve different problems:

- **Visual Components** is manufacturing-engineering software. You use it to lay out factories, simulate throughput, program industrial robots offline (OLP) and test PLC logic in virtual commissioning.
- **NVIDIA Isaac Sim** is a robotics research and AI platform. You use it to build and test robot software, train robot policies, simulate sensors and generate synthetic training data.

They overlap only in that both show robots moving in 3D.

## Side-by-side comparison

| | **Visual Components** | **NVIDIA Isaac Sim** |
|---|---|---|
| **Main users** | Manufacturing engineers, system integrators, sales and proposal teams | Robotics software engineers, AI/ML researchers, perception teams |
| **Core job** | Factory layout, discrete-event and throughput simulation, cycle times, offline programming, virtual commissioning | Physics-accurate robot simulation, sensor simulation, reinforcement and imitation learning, synthetic data, sim-to-real |
| **Foundation** | Its own 3D and simulation engine; Windows desktop app | NVIDIA Omniverse Kit, OpenUSD, RTX ray tracing, GPU PhysX |
| **Content** | Large ready-made catalog of robots (ABB, FANUC, KUKA, Yaskawa, UR and others), conveyors, AGVs, machines and human workers | Robot importers (URDF, MJCF) and some sample assets; you usually build your own scenes |
| **Robot programming** | Teach-style OLP with post-processors that output native controller code (for example ABB RAPID, KUKA KRL) | Programmatic control through the Python API, ROS 2 bridge, motion generation (Lula, cuMotion) and learned policies |
| **Physics** | Mostly kinematic and logic-driven, with basic physics | High-fidelity rigid and articulated body physics, contacts and grasping; massively parallel on GPU through Isaac Lab |
| **Sensors** | Basic sensors used as logic triggers | Photoreal RGB and depth cameras, RTX lidar, IMU and others, with domain randomization (Replicator) |
| **PLC and controls** | Strong: OPC UA, Siemens S7 and other connectors for virtual commissioning | Not a focus |
| **Ease of use** | Drag-and-drop components; usable by non-programmers | Steep learning curve; expects Python and robotics knowledge |
| **Hardware** | Ordinary engineering workstation | NVIDIA RTX GPU required, ideally with plenty of VRAM |
| **Cost** | Commercial per-seat license (Essentials, Professional and Premium tiers) | Free; open source since version 5.0 |
| **Ownership** | KUKA (since 2017), but supports many robot brands | NVIDIA |

## When to choose Visual Components

- You need to lay out a cell or line and prove throughput, bottlenecks or buffer sizes.
- You need to win a bid or show a customer a realistic production concept quickly.
- You program industrial robots offline and download the code to the real controller.
- You want to test PLC logic against a virtual plant before you build the real one.

## When to choose Isaac Sim

- You develop and test ROS 2 robot software for mobile robots, manipulators or humanoids.
- You train reinforcement or imitation learning policies at scale.
- You generate labeled synthetic images or point clouds for perception models.
- You need realistic contact and grasping physics, or accurate camera and lidar simulation.

## Using both

Many teams use both tools. Visual Components handles line design and offline programming. Isaac Sim handles the AI and perception work, such as bin picking or teaching mobile robots to navigate the layout. Check current OpenUSD and Omniverse connector support for moving layouts between them.

## Rule of thumb

- *"Will this factory or cell hit its numbers, and what's the robot program?"* → **Visual Components**
- *"Will this robot's software or AI behave correctly in the real world?"* → **Isaac Sim**
