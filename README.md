# ProtonControlAnimation

**A simple way to animate Control nodes in Godot.**

https://github.com/user-attachments/assets/fc9b0acc-646f-427d-9a0f-b1e103e65eec


## Overview

The goal of this project to let users animate Control nodes, without requiring any changes, code or special considerations.  
No shaders, no custom containers, just drop a few `ProtonControlAnimation` nodes to your existing scenes and you're good to go.

## How to install

+ Like any other Godot add-on.
+ Check out [the documentation](https://hungryproton.github.io/proton_control_animation/installation.html) for a detailled step by step guide.

## Minimal example

This tool works with your existing scenes.
Simply add a `ProtonControlAnimation` node under the control you want to animate.

![image](https://github.com/user-attachments/assets/49353f18-62aa-46f1-9cef-5e12cf87b588)

  - In this example, we will animate the `PanelContainer`

### The `ProtonControlAnimation` nodes

![image](https://github.com/user-attachments/assets/f7f9cca6-fb65-4963-adba-82863a0470a7)

+ This node handles when an animation should play.
  - Check out the [full documentation](https://hungryproton.github.io/proton_control_animation/reference/animation_node.html) for more information.
+ `Target` is the control node to animate (in this case, the `PanelContainer`).
+ `Animation` is the animation that will play.
 
### The animation resources

![image](https://github.com/user-attachments/assets/8798e88a-5fd3-4a18-8350-275c02ba2fa6)

+ The animation resource is what actually animates the controls.
+ Add a Scale animation one to the `ProtonControlAnimation` node
+ Each animation has its own set of parameters, check out [the documentation](https://hungryproton.github.io/proton_control_animation/reference/reference.html).

### Playing an animation

The easiest way to play an animation is by using the Triggers properties, on the `ProtonControlAnimation` node:

![image](https://github.com/user-attachments/assets/ce1ed35c-9ea5-455f-a068-337b2b742aaa)

+ **Trigger Source** is the control we're listening for events
  - The triggers below are the most commonly used signals.
+ In this example, `On Hover Start` is enabled. The animation will play when the player hovers `PanelContainer` with the mouse.

+ You can also ignore that panel, and directly call the `start()` function to play the animation.
  - You can find more information in the example scene `05_triggers.tscn`

### That's it!

This setup scales the panel up when hovering it with the mouse.
You can add another animation node to scale it down when the mouse stops hovering.
Check out the complete scene in `addons\proton_control_animation\examples\01_getting_started.tscn`

## Going further

You can extend the `ProtonControlAnimationResource` class to create your own animations. Check out the `animations/fade.gd` script for a minimal example.
