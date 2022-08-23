float rand (in float x) {
    return fract(sin(x) * 1e5);
}

float rand (in vec2 p) {
    return fract(sin(dot(p, vec2(12.9898,78.233))) * 43758.5453123);
}

vec2 rand2d (vec2 p) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

vec3 snow_layer (in vec2 st, in float layer) {
    st *= 5. + 5.0 * layer;

    float ySpeed = 0.5;
    st.y += iTime * ySpeed;

    vec2 ipos = floor(st);
    vec2 fpos = fract(st);

    // snow position
    vec2 point = rand2d(ipos);

    // horizontal move
    float xSpeed = 0.1;
    float offset = rand(point);
    point.x += offset * (0.5 * sin(xSpeed * iTime));

    // avoid edge clip
    point.x = max(0.1, min(0.9, point.x));
    point.y = max(0.1, min(0.9, point.y));

    float dis = distance(point, fpos);

    vec3 color = vec3(dis);

    color = 1.0 - smoothstep(0.0, 0.07 + (layer * 0.03), color);

    return color;
}

void main () {
    vec2 st = gl_FragCoord.xy / iResolution.xy;
    st.x *= iResolution.x / iResolution.y;
    
    vec3 color = vec3(0.0);
   
    color += snow_layer(st, 2.);
    color = mix(snow_layer(st, 1.), color, 0.6);
    color = mix(snow_layer(st, 0.) * 0.8, color, 0.4);


    gl_FragColor = vec4(color, 1.0); 
}
