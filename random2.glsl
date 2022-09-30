float rand2d (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float rand (in float x) {
    return fract(sin(x) * 1e5);
}

void main () {
    vec2 st = gl_FragCoord.xy / iResolution.xy;
    vec2 grid = vec2(100.0, 10.);
    st *= grid;

    float speed = 30.0 * (rand(floor(st.y)) - 0.5) * floor(10.0 * sin(0.1 * iTime));
    st.x += iTime * speed;

    vec2 ipos = floor(st);
    vec2 fpos = fract(st);


    float random = rand2d(ipos);
    random = step(0.3, random);

    vec3 color = vec3(random);
    gl_FragColor = vec4(color, 1.0); 
}  