---
title: Getting started
layout: default
nav_order: 1
---

# Getting started

## Minimal example

- Create a simple UI scene, we need at least a control node to animate. 
  + It doesn't matter where the control node is. It can be the child of a container or a regular control node.

+ **Add a `ProtonControlAnimation` node.**
  - **Target** is the control to animate.
  - **Animation** is the animation resource that describes the animation.

+ **Create an animation resource**
  - For this example, we'll create a `SlideAnimation`
  - Each animation has its own parameters. More on that in the [Reference page](/proton_control_animation/reference/reference.html).

+ Define a trigger.
  - This is a short hand for connecting a signal to the `start()` method of the `ProtonControlAnimation` node.
  - Pick any event in the list. When the associated signal is fired, the animation will start.

## Example scenes

The folder `res://addons/proton_control_animations/examples/` contains several example scenes.
They are annoted with relevant explaination of how the scene is set up and what you can achieve.

The `00_showcase` scene is a demonstration scene that contains almost all the features provided by this addon.
The other scenes are tutorials.

It's recommended to go through these examples in order as these files are sorted by importance and complexity.
