float rand (in float x) {
    return fract(sin(x) * 1e5);
}

float rand (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float smo (in float f) {
    return f * f * (3.0 - 2.0 * f);
}

mat2 rotate2d (in float angle) {
     return mat2(cos(angle),-sin(angle),
                sin(angle),cos(angle));
}

float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3. - 2. * f);

    float mixa = mix(a, b, u.x);
    float mixb = mix(c, d, u.x);
    float mixc = mix(mixa, mixb, u.y);
    return mixc;
}

float fbm (vec2 st) {
    const int octaves = 6;
    float lacunarity = 2.0; // 间隙度 越大网格越明显
    float gain = 0.5; // 增益 有点像曝光度

    float amplitude = 0.5;
    float frequency = 1.0;

    float value = 0.0;

    for (int i = 0; i < octaves; i++) {
        value += amplitude * noise(frequency * st);
        frequency *= lacunarity;
        st = rotate2d(0.5 + 0.01 * iTime) * st;
        amplitude *= gain;
    }

    return value;
}

void main () {
    vec2 st = gl_FragCoord.xy / iResolution.xy;
    st.x *= iResolution.x / iResolution.y;
    st *= 3.0;

    vec2 q = vec2(0.0);
    // q.x = fbm(st);
    // q.y = fbm(st + vec2(1.));
   
    vec2 r = vec2(0.0);
    r.x = fbm(st + q + vec2(1.7,9.2)+ 0.15 * iTime);
    r.y = fbm(st + q + vec2(8.3,2.8)+ 0.12 * iTime);
    float value = fbm(st + r);
    vec3 color = vec3(value);

    gl_FragColor = vec4(color, 1.0); 
}
