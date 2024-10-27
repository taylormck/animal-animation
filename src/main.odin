package animal_animation_toy

import "core:fmt"
import rl "vendor:raylib"

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720
WINDOW_TITLE :: "Animal Animation Toy"

main :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_TITLE)

    worm := create_worm()

    for !rl.WindowShouldClose() {
        delta := rl.GetFrameTime()

        update_worm(&worm, delta)

        rl.BeginDrawing()
        rl.ClearBackground(rl.DARKGRAY)

        draw_worm(&worm)

        rl.EndDrawing()
    }

    rl.CloseWindow()
}

ANIMAL_NODE_LINE_WIDTH :: 3

Point :: [2]f32

AnimalNode :: struct {
    center: Point,
    radius: f32,
}

Worm :: struct {
    nodes:           [10]AnimalNode,
    speed:           f32,
    node_separation: f32,
}

create_worm :: proc() -> Worm {
    radius: f32 = 15
    node_separation := 2.2 * radius

    worm := Worm {
        node_separation = node_separation,
        speed           = 250,
    }

    left: [2]f32 = {-1, 0} * node_separation
    center: [2]f32 = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}

    for &node in worm.nodes {
        node.radius = radius
        node.center = center

        center -= left
    }

    return worm
}

draw_worm :: proc(worm: ^Worm) {
    for i in 1 ..< len(worm.nodes) {
        rl.DrawLineV(worm.nodes[i - 1].center, worm.nodes[i].center, rl.WHITE)
    }

    #reverse for node in worm.nodes {
        rl.DrawCircleV(node.center, node.radius, rl.WHITE)
        rl.DrawCircleV(
            node.center,
            node.radius - ANIMAL_NODE_LINE_WIDTH,
            rl.BLUE,
        )
    }
}

update_worm :: proc(worm: ^Worm, delta: f32) {
    target := rl.GetMousePosition()
    target -= worm.nodes[0].center
    target = rl.Vector2Normalize(target)
    target *= worm.speed * delta

    // Update the head first
    worm.nodes[0].center += target

    for i in 1 ..< len(worm.nodes) {
        chase_node(&worm.nodes[i - 1], &worm.nodes[i], worm.node_separation)
    }
}

chase_node :: proc(lead: ^AnimalNode, chaser: ^AnimalNode, distance: f32) {
    direction := rl.Vector2Normalize(chaser.center - lead.center)
    chaser.center = lead.center + (direction * distance)
}
