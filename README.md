# ProtonControlAnimation

https://github.com/user-attachments/assets/fc9b0acc-646f-427d-9a0f-b1e103e65eec

**Experimental** tool to quickly and easily add UI animation to your scenes. 

## Overview

The goal of this project to let users animate Control nodes, without requiring any changes, code or special considerations.  
No shaders, no custom containers, just drop a few `ProtonControlAnimation` nodes to your existing scenes and you're good to go.

## How to install

+ Download this repository.
+ Copy the `addons/proton_control_animation` folder into your addons folder.
+ Enable the plugin in Project Settings.

## How to use

Navigate to the `addon/proton_control_animation/examples` to see what can be done.

### Minimal example

#### Add a `Control` node to animate.

![image](https://github.com/user-attachments/assets/49353f18-62aa-46f1-9cef-5e12cf87b588)

  - Here, we're going to animate a `PanelContainer` inside a control.
  - You can put it inside regular containers too, both will work.

#### Add a `ProtonControlAnimation` node

![image](https://github.com/user-attachments/assets/bd543355-128d-4380-a69a-ad22a0f8435e)

+ `Target` is the control node to animate, select the PanelContainer
+ `Animation` is the animation that will play (see the following section)
+ `Triggers` define **when** the animation should play
  - Here, `on_hover_start` means the animation will start when the mouse moves over the control.
+ `Trigger source` is the element from where we listen the events from:
  - **You can leave it empty**, by default it will use the `Target` control.
  - This is useful if another part of the UI should trigger the Control animation.
    + See the `00_showcase.tscn` file if you want an example.
 
#### Add an animation

![image](https://github.com/user-attachments/assets/80c5743a-357b-430a-ba7a-3f6630f80577)

+ Here, the Scale animation makes the control bigger
+ Three animations are available for now (Scale, Slide and Fade)
  - More will come later
  - Some properties like `from_scale` or `to_scale` are only useful depending on context, I still need to work on the UI.

#### That's it!
You can add another animation node to scale the panel down when the mouse stops hovering.
You can find the complete scene in `addons\proton_control_animation\example\01_scale`
