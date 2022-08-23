void main () {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    float ratio = iResolution.y / iResolution.x;
    uv.y *= ratio;
    uv.y += (1.0 - ratio) / 2.0; 

    float radius = 0.5;
    vec2 center = vec2(0.5, 0.5);
    float dis = distance(center, uv);
    if (dis > radius) {
        dis = 1.0;
    }
    vec3 color = vec3(dis);
    gl_FragColor = vec4(1.0 - color, 1.0); 
}
