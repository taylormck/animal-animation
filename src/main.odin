package animal_animation_toy

import "core:fmt"
import "core:math"
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

AnimalNode :: struct {
    center:    [2]f32,
    direction: [2]f32,
    radius:    f32,
}

Worm :: struct {
    nodes:           [10]AnimalNode,
    speed:           f32,
    node_separation: f32,
    min_spine_angle: f32,
}

create_worm :: proc() -> Worm {
    radius: f32 = 15
    node_separation := 2.2 * radius

    worm := Worm {
        node_separation = node_separation,
        speed           = 250,
        min_spine_angle = math.to_radians_f32(40),
    }

    right: [2]f32 = {1, 0}
    left: [2]f32 = {-1, 0} * node_separation
    center: [2]f32 = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}

    for &node in worm.nodes {
        node.radius = radius
        node.center = center
        node.direction = right

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
    direction := rl.GetMousePosition() - worm.nodes[0].center
    direction = rl.Vector2Normalize(direction)

    // Update the head first
    worm.nodes[0].center += direction * worm.speed * delta
    worm.nodes[0].direction = direction

    for i in 1 ..< len(worm.nodes) {
        chase_node(
            &worm.nodes[i - 1],
            &worm.nodes[i],
            worm.node_separation,
            worm.min_spine_angle,
        )
    }

}

chase_node :: proc(
    lead: ^AnimalNode,
    chaser: ^AnimalNode,
    distance: f32,
    min_angle: f32,
) {
    direction := rl.Vector2Normalize(chaser.center - lead.center)

    angle := rl.Vector2Angle(-lead.direction, -direction)
    if angle < min_angle {
        direction = rl.Vector2Rotate(direction, angle - min_angle)
    }


    chaser.center = lead.center + (direction * distance)
    chaser.direction = -direction
}
