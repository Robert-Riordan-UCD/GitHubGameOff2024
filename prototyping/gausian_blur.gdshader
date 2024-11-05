shader_type canvas_item;

/* Return the convolution of 2 3x3 matrix's */
float conv(mat3 a, mat3 b) {
    float result = 0.0;
    for (int x=-1; x<=1; x++) {
        for (int y=-1; y<=1; y++) {
            result += a[x+1][y+1] * b[x+1][y+1];
        }       
    }       
    return result;
}

const mat3 gaussian_filter = mat3(
        vec3(1.0, 2.0, 1.0)/8.0,
        vec3(2.0, 4.0, 2.0)/8.0,
        vec3(1.0, 2.0, 1.0)/8.0
);

void fragment() {
    mat3 pixels_r;
    mat3 pixels_g;
    mat3 pixels_b;
    vec3 tex;
    for (int x=-1; x<=1; x++) {
        for (int y=-1; y<=1; y++) {
            tex = texture(TEXTURE, UV).rgb*2.0 - 1.0;
            pixels_r[x+1][y+1] = tex.r;
            pixels_g[x+1][y+1] = tex.g;
            pixels_b[x+1][y+1] = tex.b;
        }
    }
	COLOR.r = conv(pixels_r, gaussian_filter);
    COLOR.g = conv(pixels_g, gaussian_filter);
    COLOR.b = conv(pixels_b, gaussian_filter);
}