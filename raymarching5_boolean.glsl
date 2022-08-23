const int MAX_STEP = 255; // step太小会在球体边缘产生光环
const float MAX_DIST = 100.0;
const float EPSILON = 0.001;

vec3 cubeCenter = vec3(0.0, 0.0, 0.0);
vec3 cubeSize = vec3(0.5, 0.5, 0.5);

vec3 sphereCenter = vec3(0.0, 0.0, 0.0);
float sphereRadius = 0.5;

vec3 ambientColor = vec3(0.5, 0.0, 0.0);
vec3 diffuseColor = vec3(1.0, 0.0, 0.0);
vec3 specularColor = vec3(1.0, 1.0, 1.0);

float ambientIntensity = 0.3;
float shininess = 5.0;

// 交集
float intersectSDF (float sdfA, float sdfB) {
    return max(sdfA, sdfB);
}

// 并集
float unionSDF (float sdfA, float sdfB) {
    return min(sdfA, sdfB);
}

// 差集
float differenceSDF (float sdfA, float sdfB) {
    return max(sdfA, -sdfB);
}

float cubeSDF (vec3 p) {
    vec3 d = abs(p - cubeCenter) - cubeSize;
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

float sphereSDF (vec3 p) {
    return length(p - sphereCenter) - sphereRadius;
}

float sceneSDF (vec3 p) {
    return unionSDF(differenceSDF(cubeSDF(p), sphereSDF(p)), sphereSDF(p * 1.5));
}

float raymarch (vec3 origin, vec3 direction) {
    float depth = 0.0;

    for (int i = 0; i < MAX_STEP; i++) {
        vec3 p = origin + direction * depth;
        float dist = sceneSDF(p);
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

vec3 getNormal (vec3 center, vec3 p) {
    // return normalize(surfacePos - cubeCenter);
    return normalize(vec3(
        // sceneSDF(vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)),
        // sceneSDF(vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)),
        // sceneSDF(vec3(p.x, p.y, p.z + EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON))
        sceneSDF(vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)),
        sceneSDF(vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)),
        sceneSDF(vec3(p.x, p.y, p.z + EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON))
    ));
}

vec3 calculatePhong (vec3 lightPos, vec3 surfacePos, vec3 cameraPos) {
    vec3 normal = getNormal(cubeCenter, surfacePos);
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

// mat4 rotate3d (float x, float y, float z) {
//     mat4 rotateX = mat4(
//         1.0, 0.0, 0.0, 0.0,
//         0.0, cos(x), -sin(x), 0.0,
//         0.0, sin(x), -cos(x), 0.0,
//         0.0, 0.0, 0.0, 1.0
//     );

//     return rotateX;
// }

mat4 LookAtMatrix (vec3 viewPos, vec3 target, vec3 upVec) {
    // xyz to uvw 即view坐标系的三个轴的单位向量，右手坐标系

    vec3 w = normalize(viewPos - target); // target往viewPos为z轴正方向 
    vec3 u = normalize(cross(upVec, w)); // 根据右手法则确定叉乘顺序
    vec3 v = normalize(cross(w, u)); // 根据右手法则确定叉乘顺序

    return mat4(
        u, 0.0,
        v, 0.0,
        w, 0.0,
        0.0, 0.0, 0.0, 1.0
    );
}

void main () {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;

    vec3 cameraPos = vec3(0.0, 0.0, 5.0);
    vec3 cameraLookAt = vec3(0.0, 0.0, 0.0);
    vec3 lightPos = vec3(2.0 * sin(iTime), 0.0, 2.0 * cos(iTime));
    vec3 lightPos2 = vec3(5.0 * sin(0.3 * iTime), 5.0, 5.0 * cos(0.3 * iTime));
    float lightIntensity = 1.0 - ambientIntensity;

    sphereCenter.y += sin(iTime);
    cameraPos = vec3(5.0 * sin(iTime), 3.0 * sin(iTime), 5.0 * cos(iTime));

    mat4 viewTransform = LookAtMatrix(cameraPos, cameraLookAt, vec3(0., 1., 0.));

    // world viewDirection
    vec3 direction = getRayDirection(45.0, iResolution.xy, gl_FragCoord.xy);
    direction = (viewTransform * vec4(direction, 0.0)).xyz;

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
