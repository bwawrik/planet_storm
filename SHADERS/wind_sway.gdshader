// Fixed wind shader based on Maujoe and HungryProton scripts
shader_type canvas_item;
render_mode blend_mix;

// Wind settings.
uniform float speed = 1.0;
uniform float minStrength : hint_range(0.0, 1.0) = 0.01; // Fixed: lower than max
uniform float maxStrength : hint_range(0.0, 1.0) = 0.05; // Fixed: higher than min
uniform float strengthScale = 100.0;
uniform float interval = 3.5;
uniform float detail = 1.0;
uniform float distortion : hint_range(0.0, 1.0);
uniform float heightOffset : hint_range(0.0, 1.0);

// Set a manual offset per asset instance in the editor
uniform float offset = 0.0; 

float getWind(vec2 uv, float time){
    // Safe absolute difference calculation to avoid clamp logic errors
    float diff = abs(maxStrength - minStrength);
    float strength = clamp(minStrength + sin(time / interval) * diff, minStrength, maxStrength) * strengthScale;
    float wind = (sin(time) + cos(time * detail)) * strength * max(0.0, (1.0 - uv.y) - heightOffset);
    
    return wind; 
}

void vertex() {
    // Captures object position via MODEL_MATRIX instead of WORLD_MATRIX to prevent moving jitter
    vec2 obj_pos = MODEL_MATRIX[3].xy;
    
    // Combines Time, manual inspector offset, and a stable position hash
    float time = TIME * speed + offset + (obj_pos.x + obj_pos.y) * 0.05;
    
    // Applies the final wind movement
    VERTEX.x += getWind(UV, time);
}
