const float RADIUS = 1.0;
const int MAX_STEP = 255; // step太小会在球体边缘产生光环
const float MAX_DIST = 100.0;
const float EPSILON = 0.001;

vec3 sphereCenter = vec3(0.0, 0.0, 0.0);

vec3 ambientColor = vec3(0.5, 0.0, 0.0);
vec3 diffuseColor = vec3(1.0, 0.0, 0.0);
vec3 specularColor = vec3(1.0, 1.0, 1.0);

float ambientIntensity = 0.3;
float shininess = 5.0;

float sphereSDF (vec3 p) {
    return length(p - sphereCenter) - RADIUS;
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

vec3 getNormal (vec3 sphereCenter, vec3 surfacePos) {
    return normalize(surfacePos - sphereCenter);
}

vec3 calculatePhong (vec3 lightPos, vec3 surfacePos, vec3 cameraPos) {
    vec3 normal = getNormal(sphereCenter, surfacePos);
    vec3 lightDirection = normalize(surfacePos - lightPos);

    // lambert shading
    float diffuse = max(0.0, -dot(lightDirection, normal)); // 此时光线与法线的夹角为钝角

    vec3 reflectLight = reflect(lightDirection, normal);
    vec3 viewDirection = normalize(cameraPos - surfacePos);
    float eyeLight = max(0.0, dot(reflectLight, viewDirection));
    float specular = pow(eyeLight, shininess);

    // vec3 phong = vec3(mix(diffuse, 1.0, ambient) * diffuseColor);
    vec3 phong = diffuse * diffuseColor;
    phong = mix(phong, specular * specularColor, 0.5);

    return phong;
}

// tan(radians(fov)/2.0) = resolution.y / 2.0 / distance(origin, viewPlane);

void main () {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;

    vec3 cameraPos = vec3(0.0, 0.0, 5.0);
    vec3 lightPos = vec3(2.0 * sin(iTime), 0.0, 2.0 * cos(iTime));
    vec3 lightPos2 = vec3(5.0 * sin(0.3 * iTime), 5.0, 5.0 * cos(0.3 * iTime));
    float lightIntensity = 1.0 - ambientIntensity;

    sphereCenter.y += sin(iTime);

    vec3 direction = getRayDirection(45.0, iResolution.xy, gl_FragCoord.xy);

    float depth = raymarch(cameraPos, direction);

    if (depth > MAX_DIST - EPSILON) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec3 surfacePos = cameraPos + direction * depth;

    vec3 color = vec3(ambientIntensity * ambientColor);
    color += lightIntensity * calculatePhong(lightPos, surfacePos, cameraPos);
    color += lightIntensity * calculatePhong(lightPos2, surfacePos, cameraPos);
    
    gl_FragColor = vec4(color, 1.0);
}
