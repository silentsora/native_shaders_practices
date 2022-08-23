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

    // vec2 u = smoothstep(0., 1., f);
    vec2 u = f * f * (3. - 2. * f);

    // return mix(a, b, u.x) 
    // + (c - a) * u.y * (1. - u.x) 
    // + (d - b) * u.x * u.y;

    float mixa = mix(a, b, u.x);
    float mixb = mix(c, d, u.x);
    float mixc = mix(mixa, mixb, u.y);
    return mixc;
}

void main () {
    vec2 st = gl_FragCoord.xy / iResolution.xy;
    st -= vec2(0.5);
    // st *= iResolution.x / iResolution.y;

    vec2 st2 = st * 10.0;
    st *= 5.0;
   
    st = rotate2d(noise(st + iTime)) * st2;
    float n = noise(st);

    // n = clamp(0.4, 1.0, n);
    n = smoothstep(0.0, 0.5, n);
    vec3 color = vec3(n);
    // color.r *= 0.45;
    // color.g *= 0.25;
    // color.b *= 0.1;
    // color *= vec3(1.5);

    gl_FragColor = vec4(vec3(1.) - color, 1.0); 
}

// ma = mix(a, b, x) = bx + a(1 - x) = (b - a)x + a
// mb = mix(c, d, x) = (d - c)x + c

// mix(ma, mb, y) = (mb - ma)y + ma = (((d - c)x + c) - ((b - a)x + a))y + ma 
// = (dx - cx + c - bx + ax - a)y + ma
// = dxy - cxy + cy - bxy + axy - ay + ma
// = (d - c - b + a)xy + (c - a)y + ma

// noise = ma + (c - a)y * (1 - x) + (d - b)xy
// = ma + (cy - ay)(1 - x) + (d - b)xy
// = ma + cy - cxy - ay + axy + (d - b)xy;
// = ma + (a + d - b - c)xy + (c - a)y