//	Simplex 3D Noise
//	by Ian McEwan, Ashima Arts
float4 permute(float4 x){return fmod(((x*34.0)+1.0)*x, 289.0);}
float4 taylorInvSqrt(float4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float _noise(float3 v){
	const float2  C = float2(1.0/6.0, 1.0/3.0) ;
	const float4  D = float4(0.0, 0.5, 1.0, 2.0);

	// First corner
	float3 i  = floor(v + dot(v, C.yyy) );
	float3 x0 =   v - i + dot(i, C.xxx) ;

	// Other corners
	float3 g = step(x0.yzx, x0.xyz);
	float3 l = 1.0 - g;
	float3 i1 = min( g.xyz, l.zxy );
	float3 i2 = max( g.xyz, l.zxy );

	//  x0 = x0 - 0. + 0.0 * C
	float3 x1 = x0 - i1 + 1.0 * C.xxx;
	float3 x2 = x0 - i2 + 2.0 * C.xxx;
	float3 x3 = x0 - 1. + 3.0 * C.xxx;

	// Permutations
	i = abs(fmod(i, 289.0 ));
	float4 p = permute( permute( permute(
				i.z + float4(0.0, i1.z, i2.z, 1.0 ))
			+ i.y + float4(0.0, i1.y, i2.y, 1.0 ))
			+ i.x + float4(0.0, i1.x, i2.x, 1.0 ));

	// Gradients
	// ( N*N points uniformly over a square, mapped onto an octahedron.)
	float n_ = 1.0/7.0; // N=7
	float3  ns = n_ * D.wyz - D.xzx;

	float4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  fmod(p,N*N)

	float4 x_ = floor(j * ns.z);
	float4 y_ = floor(j - 7.0 * x_ );    // fmod(j,N)

	float4 x = x_ *ns.x + ns.yyyy;
	float4 y = y_ *ns.x + ns.yyyy;
	float4 h = 1.0 - abs(x) - abs(y);

	float4 b0 = float4( x.xy, y.xy );
	float4 b1 = float4( x.zw, y.zw );

	float4 s0 = floor(b0)*2.0 + 1.0;
	float4 s1 = floor(b1)*2.0 + 1.0;
	float4 sh = float4( -step(h.x, 0),-step(h.y, 0),-step(h.z, 0),-step(h.w, 0) );

	float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
	float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

	float3 p0 = float3(a0.xy,h.x);
	float3 p1 = float3(a0.zw,h.y);
	float3 p2 = float3(a1.xy,h.z);
	float3 p3 = float3(a1.zw,h.w);

	//Normalise gradients
	float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;

	// lerp final noise value
	float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
	m = m * m;
	return 42.0 * dot( m*m, float4( dot(p0,x0), dot(p1,x1),
									dot(p2,x2), dot(p3,x3) ) );
}

float4 noise(float2 st, float scale, float offset){
    float nz = _noise(float3(st.x*scale, st.y*scale, offset*_Time.y));
    return float4(nz,nz,nz,1.0);
}

float4 voronoi(float2 st, float scale, float speed, float blending) {
	float3 color = (float3)(.0);

	// Scale
	st *= scale;

	// Tile the space
	float2 i_st = floor(st);
	float2 f_st = frac(st);

	float m_dist = 10.;  // minimun distance
	float2 m_point;        // minimum point

	for (int j=-1; j<=1; j++ ) {
		for (int i=-1; i<=1; i++ ) {
		float2 neighbor = float2(float(i),float(j));
		float2 p = i_st + neighbor;
		float2 pnt = frac(sin(float2(dot(p,float2(127.1,311.7)),dot(p,float2(269.5,183.3))))*43758.5453);
		pnt = 0.5 + 0.5*sin(_Time.y*speed + 6.2831*pnt);
		float2 diff = neighbor + pnt - f_st;
		float dist = length(diff);

		if( dist < m_dist ) {
			m_dist = dist;
			m_point = pnt;
		}
		}
	}

	// Assign a color using the closest point position
	color += dot(m_point,float2(.3,.6));
	color *= 1.0 - blending*m_dist;
	return float4(color, 1.0);
}

float4 osc(float2 _st, float freq, float sync, float offset){
	float2 st = _st;
	float r = sin((st.x-offset/freq+_Time.y*sync)*freq)*0.5  + 0.5;
	float g = sin((st.x+_Time.y*sync)*freq)*0.5 + 0.5;
	float b = sin((st.x+offset/freq+_Time.y*sync)*freq)*0.5  + 0.5;
	return float4(r, g, b, 1.0);
}
		
float4 shape(float2 _st, float sides, float radius, float smoothing){
	float2 st = _st * 2. - 1.;
	// Angle and radius from the current pixel
	float a = atan2(st.x,st.y)+3.1416;
	float r = (2.*3.1416)/sides;
	float d = cos(floor(.5+a/r)*r-a)*length(st);
    float s = 1.0-smoothstep(radius,radius + smoothing,d);
	return float4(s,s,s, 1.0);
}

float4 gradient(float2 _st, float speed) {
	return float4(_st, sin(_Time.y*speed), 1.0);
}

float4 src(float2 _st, sampler2D _tex){
	//  float2 uv = gl_FragCoord.xy/float2(1280., 720.);
	return tex2D(_tex, frac(_st));
}

float4 solid(float2 uv, float _r, float _g, float _b, float _a){
	return float4(_r, _g, _b, _a);
}

float2 rotate(float2 st, float _angle, float speed){
	float2 xy = st - (float2)(0.5);
	float angle = _angle + speed *_Time.y;
	xy = mul(float2x2(cos(angle),-sin(angle), sin(angle),cos(angle)),xy);
	xy += 0.5;
	return xy;
}

float2 scale(float2 st, float amount, float xMult, float yMult, float offsetX, float offsetY){
	float2 xy = st - float2(offsetX, offsetY);
	xy*=(1.0/float2(amount*xMult, amount*yMult));
	xy+=float2(offsetX, offsetY);
	return xy;
}

float2 pixelate(float2 st, float pixelX, float pixelY){
	float2 xy = float2(pixelX, pixelY);
	return (floor(st * xy) + 0.5)/xy;
}

float4 posterize(float4 c, float bins, float gamma){
	float4 c2 = float4( pow(c.x, gamma), pow(c.y, gamma), pow(c.z, gamma), pow(c.w, gamma) );
    float4 bns = (float4)bins;
	c2 *= bns;
	c2 = floor(c2);
	c2/= bns;
    float rgm = (1.0/gamma);
	c2 = float4( pow(c2.x, rgm),pow(c2.y, rgm),pow(c2.z, rgm),pow(c2.w, rgm));
	return float4(c2.xyz, c.a);
}

float4 shift(float4 c, float r, float g, float b, float a){
	float4 c2 = float4(c);
	c2.r = frac(c2.r + r);
	c2.g = frac(c2.g + g);
	c2.b = frac(c2.b + b);
	c2.a = frac(c2.a + a);
	return float4(c2.rgba);
}

float2 repeat(float2 _st, float repeatX, float repeatY, float offsetX, float offsetY){
	float2 st = _st * float2(repeatX, repeatY);
	st.x += step(1., fmod(st.y,2.0)) * offsetX;
	st.y += step(1., fmod(st.x,2.0)) * offsetY;
	return frac(st);
}

float2 modulateRepeat(float2 _st, float4 c1, float repeatX, float repeatY, float offsetX, float offsetY){
	float2 st = _st * float2(repeatX, repeatY);
	st.x += step(1., fmod(st.y,2.0)) + c1.r * offsetX;
	st.y += step(1., fmod(st.x,2.0)) + c1.g * offsetY;
	return frac(st);
}

float2 repeatX(float2 _st, float reps, float offset){
	float2 st = _st * float2(reps, 1.0);
	st.y += step(1., fmod(st.x,2.0))* offset;
	return frac(st);
}

float2 modulateRepeatX(float2 _st, float4 c1, float reps, float offset){
	float2 st = _st * float2(reps, 1.0);
	st.y += step(1., fmod(st.x,2.0)) + c1.r * offset;
	return frac(st);
}

float2 repeatY(float2 _st, float reps, float offset){
	float2 st = _st * float2(1.0, reps);
	st.x += step(1., fmod(st.y,2.0))* offset;
	return frac(st);
}

float2 modulateRepeatY(float2 _st, float4 c1, float reps, float offset){
	float2 st = _st * float2(reps, 1.0);
	st.x += step(1., fmod(st.y,2.0)) + c1.r * offset;
	return frac(st);
}

float2 kaleid(float2 st, float nSides){
	st -= 0.5;
	float r = length(st);
	float a = atan2(st.x,st.y);
	float pi = 2.*3.1416;
	a = abs(fmod(a,pi/nSides));
	a = abs(a-pi/nSides/2.);
	return r*float2(cos(a), sin(a));
}

float2 modulateKaleid(float2 st, float4 c1, float nSides){
	st -= 0.5;
	float r = length(st);
	float a = atan2(st.x, st.y);
	float pi = 2.*3.1416;
	a = abs(fmod(a,pi/nSides));
	a = abs(a-pi/nSides/2.);
	return (c1.r+r)*float2(cos(a), sin(a));
}

float2 scrollX(float2 st, float amount, float speed){
	st.x += amount + _Time.y*speed;
	return frac(st);
}

float2 modulateScrollX(float2 st, float4 c1, float amount, float speed){
	st.x += c1.r*amount + _Time.y*speed;
	return frac(st);
}

float2 scrollY(float2 st, float amount, float speed){
	st.y += amount + _Time.y*speed;
	return frac(st);
}

float2 modulateScrollY(float2 st, float4 c1, float amount, float speed){
	st.y += c1.r*amount + _Time.y*speed;
	return frac(st);
}

float4 add(float4 c0, float4 c1, float amount){
	return (c0+c1)*amount + c0*(1.0-amount);
}

float4 layer(float4 c0, float4 c1){
	return float4(lerp(c0.rgb, c1.rgb, c1.a), c0.a+c1.a);
}

float4 blend(float4 c0, float4 c1, float amount){
	return c0*(1.0-amount)+c1*amount;
}

float4 mult(float4 c0, float4 c1, float amount){
	return c0*(1.0-amount)+(c0*c1)*amount;
}

float4 diff(float4 c0, float4 c1){
	return float4(abs(c0.rgb-c1.rgb), max(c0.a, c1.a));
}

float2 modulate(float2 st, float4 c1, float amount){
	return st + c1.xy*amount;
}

float2 modulateScale(float2 st, float4 c1, float multiple, float offset){
	float2 xy = st - (float2)(0.5);
	xy*=(1.0/float2(offset + multiple*c1.r, offset + multiple*c1.g));
	xy+=(float2)(0.5);
	return xy;
}

float2 modulatePixelate(float2 st, float4 c1, float multiple, float offset){
	float2 xy = float2(offset + c1.x*multiple, offset + c1.y*multiple);
	return (floor(st * xy) + 0.5)/xy;
}

float2 modulateRotate(float2 st, float4 c1, float multiple, float offset){
	float2 xy = st - (float2)(0.5);
	float angle = offset + c1.x * multiple;
	xy = mul(float2x2(cos(angle),-sin(angle), sin(angle),cos(angle)),xy);
	xy += 0.5;
	return xy;
}

float2 modulateHue(float2 st, float4 c1, float amount){
	return st + (float2(c1.g - c1.r, c1.b - c1.g) * amount * 1.0/_ScreenParams.xy);
}

float4 invert(float4 c0, float amount){
	return float4((1.0-c0.rgb)*amount + c0.rgb*(1.0-amount), c0.a);
}

float4 contrast(float4 c0, float amount) {
	float4 c = (c0-(float4)(0.5))*(float4)(amount) + (float4)(0.5);
	return float4(c.rgb, c0.a);
}

float4 brightness(float4 c0, float amount){
	return float4(c0.rgb + (float3)(amount), c0.a);
}

float luminance(float3 rgb){
	const float3 W = float3(0.2125, 0.7154, 0.0721);
	return dot(rgb, W);
}

float4 mask(float4 c0, float4 c1){
	float a = luminance(c1.rgb);
	return float4(c0.rgb*a, a);
}

float4 luma(float4 c0, float threshold, float tolerance){
	float a = smoothstep(threshold-tolerance, threshold+tolerance, luminance(c0.rgb));
	return float4(c0.rgb*a, a);
}

float4 thresh(float4 c0, float threshold, float tolerance){
    float stp = smoothstep(threshold-tolerance, threshold+tolerance, luminance(c0.rgb));
	return float4(stp,stp,stp, c0.a);
}

float4 color(float4 c0, float _r, float _g, float _b, float _a){
	float4 c = float4(_r, _g, _b, _a);
	float4 pos = step(0.0, c); // detect whether negative

	// if > 0, return r * c0
	// if < 0 return (1.0-r) * c0
	return float4(lerp((1.0-c0)*abs(c), c*c0, pos));
}

float3 _rgbToHsv(float3 c){
	float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
	float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 _hsvToRgb(float3 c){
	float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float4 saturate(float4 c0, float amount){
	const float3 W = float3(0.2125, 0.7154, 0.0721);
	float3 intensity = (float3)(dot(c0.rgb, W));
	return float4(lerp(intensity, c0.rgb, amount), c0.a);
}

float4 hue(float4 c0, float hue){
	float3 c = _rgbToHsv(c0.rgb);
	c.r += hue;
	//  c.r = frac(c.r);
	return float4(_hsvToRgb(c), c0.a);
}

float4 colorama(float4 c0, float amount){
	float3 c = _rgbToHsv(c0.rgb);
	c += (float3)(amount);
	c = _hsvToRgb(c);
	c = frac(c);
	return float4(c, c0.a);
}
