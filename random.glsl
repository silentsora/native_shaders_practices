float rand (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float random (in float x) {
    return fract(sin(x) * 1e5);
}

void main () {
    vec2 st = gl_FragCoord.xy / iResolution.xy;
    vec2 grid = vec2(100., 50.);
    st *= grid;

    float speed = 1.0;
    speed = 1.0 + 10.0 * random(floor(st.y));
    st.x += iTime * speed * -20.0;

    vec2 ipos = floor(st);
    vec2 fpos = fract(st);


    float random = rand(ipos);
    random = step(0.9 - clamp(0.1 * speed, 0.0, 0.9), random);

    random *= step(0.2, fpos.y);

    vec3 color = vec3(random);
    // color.r = fract(sin(iTime));
    gl_FragColor = vec4(1.0 - color, 1.0); 
}  