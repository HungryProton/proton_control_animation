# ProtonControlAnimation
**Proof of concept** for a Godot addon to make UI animation easier.
The goal is to let you add UI animations (scale, slide, fade etc) by simply adding nodes to your existing UI scenes, without having to code anything.

*Note: While this is meant to become a proper tool in the future, it is absolutely not the case in its current form*

## Overview


+ Add a `ProtonControlAnimation` to your scene.
+ This node holds an animation resource that defines the type of animation (slide or scale for now)
+ Specify the targets
  - Targets are the control nodes that will be animated
+ Specify the triggers
  - Triggers are the events that will cause the animation to play



https://github.com/user-attachments/assets/9bc079fd-eef6-4950-87db-1d56308f4ffe


