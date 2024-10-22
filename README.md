# GDMSCoder
GDMiniScript Code Environment - A custom implementation of the MiniScript Scripting Language in Godot

# Overview
MiniScript (https://miniscript.org) is a simple, elegant scripting language for learning to code, and is simple to embed as a scripting language within other programming environments. GDMiniScript is a Godot GDExtension that can be used to implement MiniScript within the Godot environment, and GDMSCoder is an Editor/IDE to write and run GDMiniScript code as stand-alone software, or to embed within a larger Godot program.

# Design Philosophy
The original goal for GDMiniScript was as a way for Godot Game programmers to allow the players to write their own scripts to control gameplay in your game, allowing you to create your very own coding game with ease, so you can focus on your gameplay without having to write your own scripting engine. 

GDMSCoder was designed to be a simple editor to plug into your Godot code, to save you having to write your own script editor. However, as development has continued, the use-cases have expanded, and future functionality will allow you to write full games in GDMSCoder, adding some of the Godot specific functionality as extensions to the MiniScript language, so full programs can be written in GDMiniScript, without having to learn GDScript or Godot at all.

The core GDMiniScript extension is independent of the GDMSCoder project, and can be used stand-alone in your own Godot Project as a basic interpreter, accepting a GDMiniScript script file as input, executing the code, and passing results back to the host environment. GDMSCOder can also be seen then as an example of how to interface with GDMininScript using GDcript code and Godot.

# Status
As of 22nd October, 2024, this is an early pre-alpha release to allow other Godot programmers a chance to review the state of the project, provide feedback on current and future functionality, and test implmenting in their projects, to see if using MiniScript as a scripting language for your Godot project, is something you'd like to do.

Note that because this is pre-alpha, the code is incomplete, will have bugs and missing functionality, and everything is subject to change. However, the interface to the GDMiniScript extension itself should be fairly stable, with just additional functionality to be added to future versions, but I make no guarantees.

At this stage, it is assumed you are doing your Godot coding in GDScript. No attempt have been made to use C# in Godot. GDExtensions are still considered beta functionanailty by the Godot team, so the very foundations of how extensions work is subject to change and improvement, and the current Godot 4.4 Dev builds are already showing improved functionality, which I'm likely to implement in future releases.

There is no user documentation currently, but it is a high priority, along with resolving issues in this release and I have already identified multiple areas of code refactoring to be done to decouple the extension interface from the GDScript code, and also to package up all of the code editor functionality into a more discrete unit. This will allow easier implementation of this editor into your own Godot projects, if you wish to have an out of the box GDMiniScript script editor for your users to write their own GDMiniScript code in your Godot programs.

# Requirements
The current build is utilising Godot 4.3 release. Embedding GDMSCoder in your own Godot Project will require understanding of how GDMiniScript works. Consult the (yet to be created) documentation for further information.

# Installation
1. Download a zipoped copy of the code and extract to a sub-folder for GDMSCoder
2. Open Godot 4.3 and import the sub-folder created above
3. Open the `User://` folder for the project. This should bring up a File Explorer window
4. Open a second File Explorer window under the `project` folder, you will see a folder of sample scripts called `GDMS_Examples`
