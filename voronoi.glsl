float rand (in float x) {
    return fract(sin(x) * 1e5);
}

float rand (in vec2 p) {
    return fract(sin(dot(p, vec2(12.9898,78.233))) * 43758.5453123);
}

vec2 rand2 (vec2 p) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

void main () {
    vec2 st = gl_FragCoord.xy / iResolution.xy;
    st.x *= iResolution.x / iResolution.y;
    st *= 10.0;

    vec2 ipos = floor(st);
    vec2 fpos = fract(st);

    vec3 color = vec3(0.0);

    // vec2 point = ipos + vec2(0.5) + 0.5 * vec2(sin(iTime), cos(iTime));

    float minDis = 1.0;

    vec2 offsets[9];
    offsets[0] = vec2(-1.0, 1.0);
    offsets[1] = vec2(0.0, 1.0);
    offsets[2] = vec2(1.0, 1.0);
    offsets[3] = vec2(-1.0, 0.0);
    offsets[4] = vec2(0.0, 0.0);
    offsets[5] = vec2(1.0, 0.0);
    offsets[6] = vec2(-1.0, -1.0);
    offsets[7] = vec2(0.0, -1.0);
    offsets[8] = vec2(1.0, -1.0);

    for (int i = 0; i < 9; i++) {
        vec2 point = rand2(ipos + offsets[i]);
        point = 0.5 + 0.5 * sin(3.1415 * point + iTime);
        float dist = distance(fpos, point + offsets[i]);
        minDis = min(dist, minDis);
    }

    color += vec3(minDis);
    // color += 1.0 - step(0.02, minDis);
    // color.r += step(.98, fpos.x) + step(.98, fpos.y);
    // color -= step(.7,abs(sin(27.0*minDis)))*.5;
    // color += vec3(0.05, 0.3, 0.6);

    gl_FragColor = vec4(color, 1.0); 
}
