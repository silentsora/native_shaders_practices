const float RADIUS = 1.0;
const int MAX_STEP = 30;
const float MAX_DIST = 100.0;
const float EPSILON = 0.001;

float sphereSDF (vec3 p) {
    return length(p) - RADIUS;
}

float raymarch (vec3 origin, vec3 direction) {
    float depth = 0.0;

    for (int i = 0; i < MAX_STEP; i++) {
        vec3 p = origin + direction * depth;
        float dist = sphereSDF(p);
        depth += dist;

        // 超出视距或到达物体内部终止
        if (depth > MAX_DIST || dist < EPSILON) break;
    }
    return depth;
}

vec3 getRayDirection (float fov, vec2 resolution, vec2 fragCoord) {
    vec3 coord = vec3(0.0);
    coord.xy = fragCoord - resolution / 2.0; // 坐标转换成平面中心点为(0,0)
    coord.z = -resolution.y / tan(radians(fov) / 2.0) / 2.0; // 相机到平面的距离
    return normalize(coord);
}

// tan(radians(fov)/2.0) = resolution.y / 2.0 / distance(origin, viewPlane);

void main () {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;

    vec3 cameraPos = vec3(0.0, 0.0, 5.0);
    vec3 sphereCenter = vec3(0.0, 0.0, 0.0);

    // vec3 viewPlanePos = vec3(uv, 2.0);
    vec3 direction = getRayDirection(45.0, iResolution.xy, gl_FragCoord.xy);

    float depth = raymarch(cameraPos, direction);

    vec3 color = vec3(0.0);
    if (depth <= MAX_DIST - EPSILON) {
        color = vec3(1.0);
    }
    gl_FragColor = vec4(color, 1.0);
}
